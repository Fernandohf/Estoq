import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'data.dart';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'session_view.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'main.dart';

// Features
// Add option to save reference or barcode,instead of only barcode

String? isBarcode(String barcode) {
  String checkLastDigit(String barcode) {
    // EAN13 pattern
    int sum1 = 0;
    int sum2 = 0;
    for (int i = 0; i < barcode.length - 1; i++) {
      if (i % 2 == 0) {
        sum2 += int.parse(barcode[i]);
      } else {
        sum1 += int.parse(barcode[i]);
      }
    }
    int result = sum1 * 3 + sum2;
    int lastDigit =
        (int.parse(result.toString()[result.toString().length - 1]) - 10).abs();
    return lastDigit.toString()[lastDigit.toString().length - 1];
  }

  String checkDigit = checkLastDigit(barcode);
  String lastDigit = barcode.isEmpty ? "" : barcode[barcode.length - 1];
  // check if is numeric and last digit checks
  if (barcode.isEmpty) {
    return "Vazio";
  } else if (barcode.length < 13) {
    return "Muito curto";
  } else if (barcode.length > 13) {
    return "Muito longo";
  } else if (checkDigit != lastDigit) {
    return "Digito verificador $lastDigit inválido, deveria ser $checkDigit";
  } else {
    return null;
  }
}

Future<CameraDescription> getCamera() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  return firstCamera;
}

class ActiveSessionScreen extends StatefulWidget {
  final SessionData sessionData;
  final CameraDescription camera;
  ActiveSessionScreen(this.sessionData, this.camera);

  @override
  _ActiveSessionScreenState createState() =>
      _ActiveSessionScreenState(sessionData: sessionData, camera: camera);
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen>
    with SingleTickerProviderStateMixin {
  final CameraDescription camera;
  final SessionData sessionData;
  late String lastBarcode = "";
  late int sliderValue;
  late int activeTab = 0;
  late CameraController _camController;
  late TabController _tabController;
  late TextEditingController _textEditingController;
  late Future<void> _initializeControllerFuture;
  late double previewWidth;
  late double previewHeight = 160;
  late int borderTB = 30;
  late int borderLR = 0;
  _ActiveSessionScreenState({
    required this.camera,
    required this.sessionData,
  });

  // Add configuration to differenret formats

  Future<void> addEntry(BuildContext context) async {
    // Check if camera is active
    if (_tabController.index == 0) {
      // Take Picture
      try {
        await _initializeControllerFuture;
        // Store the picture in the temp directory.

        final path = join(
          //  (await getTemporaryDirectory()).path,
          (await getApplicationDocumentsDirectory()).path,
          '${DateTime.now()}.png',
        );

        // Attempt to take a picture and log where it's been saved.
        await _camController.takePicture();
        Size previewSize =
            Size(previewWidth - 2 * borderLR, previewHeight - 2 * borderTB);
        File imgFile = await resizeToPreview(path, previewSize);
        // String newPath = await _resizePhoto(
        //     path, borderLR, borderTB, imgSize);

        // final image = FirebaseVisionImage.fromFile(imgFile);
        final InputImage image = InputImage.fromFile(imgFile);

        final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
        // List<Barcode> results = await barcodeDectector.detectInImage(image);
        final List<Barcode> results = await barcodeScanner.processImage(image);

        if (results.isEmpty) {
          showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                    title: Text(
                      "Código de barras não foi detectado!",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    titlePadding: EdgeInsets.all(5),
                    actions: <Widget>[
                      Image.file(imgFile),
                      Text(
                        "*Verifique se a image esta em foco.",
                        textAlign: TextAlign.end,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Ok"))
                    ],
                  ));
          lastBarcode = "";
        } else {
          lastBarcode = results.first.rawValue ?? "";
        }
      } catch (e) {
        // If an error occurs, log the error to the console.
        print(e);
      }
    }
    // On manual input
    else {
      // // Check barcode
      // String barcodeMsg = isBarcode(_textEditingController.text);
      // if (barcodeMsg == null) {
      lastBarcode = _textEditingController.text;
      _textEditingController.text = "";
      // } else {
      //   showDialog(
      //       context: context,
      //       builder: (_) => new AlertDialog(
      //               title: Text(
      //                 "Código de barras inválido\n",
      //               ),
      //               titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      //               actions: <Widget>[
      //                 Column(
      //                   children: <Widget>[
      //                     Padding(
      //                         padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      //                         child: Text(
      //                           barcodeMsg,
      //                           textAlign: TextAlign.left,
      //                         )),
      //                     Align(
      //                         alignment: Alignment.centerRight,
      //                         child: FlatButton(
      //                             onPressed: () {
      //                               Navigator.of(context).pop();
      //                             },
      //                             child: Text("Ok")))
      //                   ],
      //                 )
      //               ]));
      //   lastBarcode = "";
      // }
    }
    if (lastBarcode.isNotEmpty) {
      // Update
      Map<String, Object> entry = {
        "barcode": this.lastBarcode,
        "quantity": this.sliderValue.toInt()
      };
      Sessions sessions = Home.of(context)!.sessions;
      sessions.addEntry(sessionData, entry);
      // Inform user and save it
      SnackBar snackEntry = SnackBar(
          duration: Duration(milliseconds: 400),
          content: Text("Adicionado com sucesso!"));
      ScaffoldMessenger.of(context).showSnackBar(snackEntry);

      // Log
      print("Adicionando entry");
      print(entry);
      setState(() {
        this.lastBarcode = lastBarcode;
        this.sliderValue = sliderValue;
      });
    }
  }

  void updateSize(double width) {
    this.previewWidth = width;
  }

  void updateSliderValue(int value) {
    this.sliderValue = value;
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _camController = CameraController(camera, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.nv21);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    });
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _camController.initialize();
  }

  @override
  void dispose() {
    _camController.dispose();
    _tabController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.blueAccent,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.camera_alt), text: "Camera"),
              Tab(icon: Icon(Icons.space_bar), text: "Manual / Scanner USB"),
            ],
          ),
          title: Text(sessionData.name),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Container(
                height: previewHeight.toDouble(),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    BarcodeScannerWidget(
                        camera,
                        _camController,
                        _initializeControllerFuture,
                        updateSize,
                        borderLR,
                        borderTB),
                    ManualInputForm(_textEditingController, addEntry),
                  ],
                ),
              ),
              Expanded(
                  flex: 2,
                  child: SafeArea(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                        SessionCard(sessionData, false),
                      ]))),
              BottonSlider(updateSliderValue),
            ],
          ),
        ),
        floatingActionButton: AddButton(this.addEntry),
      ),
    );
  }
}

Future<File> resizeToPreview(String filePath, Size previewSize) async {
  ImageProperties properties =
      await FlutterNativeImage.getImageProperties(filePath);
  // Flip image if height > width
  double ratio;
  Size scaledSize;
  int xOff;
  int yOff;
  int xDelta;
  int yDelta;
  // Portrait or Landscape

  if (properties.height! > properties.width!) {
    ratio = properties.width! / previewSize.width;
    scaledSize = Size(previewSize.width * ratio, previewSize.height * ratio);
    yOff = ((properties.height! - scaledSize.height) / 2).round();
    xOff = ((properties.width! - scaledSize.width) / 2).round();
    xDelta = scaledSize.width.round();
    yDelta = scaledSize.height.round();
  } else {
    ratio = properties.height! / previewSize.width;
    scaledSize = Size(previewSize.width * ratio, previewSize.height * ratio);
    xOff = ((properties.width! - scaledSize.height) / 2).round();
    yOff = ((properties.height! - scaledSize.width) / 2).round();
    xDelta = scaledSize.height.round();
    yDelta = scaledSize.width.round();
  }

  File croppedFile =
      await FlutterNativeImage.cropImage(filePath, xOff, yOff, xDelta, yDelta);
  print("Cropped image saved at: $croppedFile.path");
  return croppedFile;
}

class AddButton extends StatelessWidget {
  final Function addFunction;
  const AddButton(this.addFunction, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: FloatingActionButton(
        onPressed: () {
          this.addFunction(context);
        },
        child: Icon(
          Icons.qr_code_2,
          color: Colors.white,
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class BarcodeScannerWidget extends StatefulWidget {
  final CameraDescription camera;
  final CameraController cameraController;
  final Future<void> _initializeControllerFuture;
  final Function updateSize;
  final int borderTB;
  final int borderLR;

  BarcodeScannerWidget(
      this.camera,
      this.cameraController,
      this._initializeControllerFuture,
      this.updateSize,
      this.borderLR,
      this.borderTB);

  @override
  _BarcodeScannerWidgetState createState() {
    return _BarcodeScannerWidgetState(camera, cameraController,
        _initializeControllerFuture, updateSize, borderLR, borderTB);
  }
}

class _BarcodeScannerWidgetState extends State {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  late Function barcodeCallback;
  final CameraDescription camera;
  final Function updateSize;
  final int borderTB;
  final int borderLR;
  IconData torchIcon = Icons.highlight;
  bool torchOn = false;
  _BarcodeScannerWidgetState(
      this.camera,
      this._controller,
      this._initializeControllerFuture,
      this.updateSize,
      this.borderLR,
      this.borderTB);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    setState(() {
      updateSize(width);
    });
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Center(
            child: Stack(
              alignment: FractionalOffset.center,
              children: <Widget>[
                Container(
                  width: width,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Container(
                          width: width,
                          height: width / _controller.value.aspectRatio,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: CameraPreview(_controller),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Black overlay decoration
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      border: Border(
                        top: BorderSide(
                            color: Colors.black45, width: borderTB.toDouble()),
                        left: BorderSide(
                            color: Colors.black45, width: borderLR.toDouble()),
                        right: BorderSide(
                            color: Colors.black45, width: borderLR.toDouble()),
                        bottom: BorderSide(
                            color: Colors.black45, width: borderTB.toDouble()),
                      ),
                    ),
                  ),
                ),
                // Red line
                Positioned.fill(
                    child: Divider(
                  color: Colors.redAccent,
                  thickness: 3,
                  indent: borderLR + 20.0,
                  endIndent: borderLR + 20.0,
                )),
                Positioned.fill(
                    child: Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        if (torchOn) {
                          torchIcon = Icons.highlight_off;
                          torchOn = false;
                          _controller.setFlashMode(FlashMode.torch);
                          // Turn the torch on:
                        } else {
                          torchIcon = Icons.highlight;
                          torchOn = true;
                          _controller.setFlashMode(FlashMode.off);
                        }
                      });
                    },
                    child: Icon(torchIcon, color: Colors.white),
                  ),
                )),
              ],
            ),
          );
        } else {
          // Otherwise, display a loading indicator.
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class BottonSlider extends StatefulWidget {
  late final Function valueCallback;
  BottonSlider(this.valueCallback);
  @override
  _BottonSliderState createState() {
    return _BottonSliderState(valueCallback);
  }
}

class _BottonSliderState extends State {
  Function valueCallback;
  int? _value;
  _BottonSliderState(this.valueCallback);

  @override
  Widget build(BuildContext context) {
    UserSettings settings = Home.of(context)!.settings;
    if (_value == null) {
      _value = settings.minQuant;
    }
    return Container(
        height: 60,
        alignment: Alignment.bottomCenter,
        child: Center(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(_value.toString(),
                            style: TextStyle(
                              color: Colors.blueAccent,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 14.0,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                        child: Icon(
                          Icons.add_box,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                            value: _value!.toDouble(),
                            min: settings.minQuant.toDouble(),
                            max: settings.maxQuant.toDouble(),
                            divisions: settings.maxQuant - settings.minQuant,
                            activeColor: Colors.blueAccent,
                            inactiveColor: Colors.lightBlueAccent,
                            label: '$_value',
                            onChanged: (double newValue) {
                              setState(() {
                                _value = newValue.round();
                                valueCallback(_value);
                              });
                            },
                            semanticFormatterCallback: (double newValue) {
                              return '${newValue.round()}';
                            }),
                      ),
                    ]))));
  }
}

// Define a custom Form widget.
class ManualInputForm extends StatefulWidget {
  final TextEditingController textController;
  final Function submittedFunction;
  ManualInputForm(this.textController, this.submittedFunction);
  @override
  _ManualInputFormState createState() =>
      _ManualInputFormState(this.textController, this.submittedFunction);
}

// This class holds the data related to the Form.
class _ManualInputFormState extends State<ManualInputForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final TextEditingController textController;
  final Function submittedFunction;
  _ManualInputFormState(this.textController, this.submittedFunction);

  @override
  Widget build(BuildContext context) {
    UserSettings settings = Home.of(context)!.settings;
    return TextFormField(
      autofocus: true,
      maxLines: null,
      maxLength: 13,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (String value) {
        this.submittedFunction(context);
      },
      validator: (String? value) {
        return settings.checkBarcode ? isBarcode(value!) : null;
      },

      //onFieldSubmitted: (String value){this.submittedFunction(context);},
      controller: textController,
      decoration: InputDecoration(
          labelText: "Código de Barras",
          suffixIcon: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                textController.text = "";
              })),
    );
  }
}
