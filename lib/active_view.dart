import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'session_view.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'main.dart';

bool isBarcode(String barcode) {
  // Verify weather the barcode is valid or not
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  bool checkLastDigit(String barcode) {
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
    if (lastDigit.toString() == barcode[barcode.length - 1]) {
      return true;
    } else {
      return false;
    }
  }

  // check if is numeric and last digit checks
  if (isNumeric(barcode) && checkLastDigit(barcode)) {
    return true;
  } else {
    return false;
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
      _ActiveSessionScreenState(sessionData, camera);
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen>
    with SingleTickerProviderStateMixin {
  final CameraDescription camera;
  SessionData sessionData;
  String lastBarcode = "";
  int sliderValue = 1;
  int activeTab = 0;
  CameraController _camController;
  TabController _tabController;
  TextEditingController _textEditingController;
  Future<void> _initializeControllerFuture;
  double previewWidth;
  double previewHeight = 150;
  int borderTB = 45;
  int borderLR = 0;
  // Add configuration to differenret formats
  static final barcodeDetectorOptions = BarcodeDetectorOptions();
  final barcodeDectector =
      FirebaseVision.instance.barcodeDetector(barcodeDetectorOptions);
  _ActiveSessionScreenState(this.sessionData, this.camera);

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
    _camController = CameraController(camera, ResolutionPreset.high);
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
              Tab(icon: Icon(Icons.camera_alt), text: "Scanear"),
              Tab(icon: Icon(Icons.space_bar), text: "Manual"),
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
                    BarcodeScanner(
                        camera,
                        _camController,
                        _initializeControllerFuture,
                        updateSize,
                        borderLR,
                        borderTB),
                    ManualInputForm(_textEditingController),
                  ],
                ),
              ),
              Expanded(
                  child: SafeArea(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                    SessionCard(sessionData, false),
                  ]))),
              Container(
                height: 60,
                alignment: Alignment.bottomCenter,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Text(
                        //   'Quant',
                        //   style: TextStyle(fontSize: 14),
                        // ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8, 0, 8),
                          child: Icon(Icons.filter_9_plus,),
                        ),
                        QuantitySlider(updateSliderValue),
                        RaisedButton(
                          onPressed: () async {
                            // Check if camera is active
                            if (_tabController.index == 0) {
                              // Take Picture
                              try {
                                await _initializeControllerFuture;
                                // Store the picture in the temp directory.

                                final path = join(
                                  //  (await getTemporaryDirectory()).path,
                                  (await getApplicationDocumentsDirectory())
                                      .path,
                                  '${DateTime.now()}.png',
                                );

                                // Attempt to take a picture and log where it's been saved.
                                await _camController.takePicture(path);
                                Size previewSize = Size(
                                    previewWidth - 2 * borderLR,
                                    previewHeight - 2 * borderTB);
                                File imgFie =
                                    await resizeToPreview(path, previewSize);
                                // String newPath = await _resizePhoto(
                                //     path, borderLR, borderTB, imgSize);

                                final image =
                                    FirebaseVisionImage.fromFile(imgFie);
                                List<Barcode> results =
                                    await barcodeDectector.detectInImage(image);
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
                                              Image.file(imgFie),
                                              Text(
                                                "*Verifique se a image esta em foco.",
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ));
                                  lastBarcode = "";
                                } else {
                                  lastBarcode = results.first.rawValue;
                                }
                              } catch (e) {
                                // If an error occurs, log the error to the console.
                                print(e);
                              }
                            }
                            // Not on camera tab
                            else {
                              // Check barcode
                              if (isBarcode(_textEditingController.text)) {
                                lastBarcode = _textEditingController.text;
                                _textEditingController.text = "";
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) => new AlertDialog(
                                          title: Text(
                                            "Código de barras inválido!",
                                            style: TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          titlePadding: EdgeInsets.all(5),
                                        ));
                                lastBarcode = "";
                              }
                            }
                            if (lastBarcode.isNotEmpty) {
                              // Join data and save it
                              print("Slider:  $sliderValue");
                              print("barcode:  $lastBarcode");

                              // update
                              Map<String, Object> entry = {
                                "barcode": lastBarcode,
                                "quantity": sliderValue.toInt()
                              };
                              Sessions sessions = Home.of(context).sessions;
                              sessions.addEntry(sessionData, entry);

                              //
                              print("Adicionando entry");
                              print(sessions.data);
                              setState(() {});
                            }
                          },
                          child: Text(
                            "Adicionar",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blueAccent,
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
// Future<String> extractBarcode(String imgPath){
//   ImageProperties properties =
//       await FlutterNativeImage.getImageProperties(imgPath);
//       detector.detect(image)

// }

Future<File> resizeToPreview(String filePath, Size previewSize) async {
  ImageProperties properties =
      await FlutterNativeImage.getImageProperties(filePath);
  double ratio = properties.height / previewSize.width;
  Size scaledSize = Size(previewSize.width * ratio, previewSize.height * ratio);
  int xOff = ((properties.width - scaledSize.height) / 2).round();
  int yOff = ((properties.height - scaledSize.width) / 2).round();

  File croppedFile = await FlutterNativeImage.cropImage(filePath, xOff, yOff,
      scaledSize.height.round(), scaledSize.width.round());
  print("Cropped image saved at: $croppedFile.path");
  return croppedFile;
}

class BarcodeScanner extends StatefulWidget {
  final CameraDescription camera;
  final CameraController cameraController;
  final Future<void> _initializeControllerFuture;
  final Function updateSize;
  final int borderTB;
  final int borderLR;

  BarcodeScanner(
      this.camera,
      this.cameraController,
      this._initializeControllerFuture,
      this.updateSize,
      this.borderLR,
      this.borderTB);

  @override
  _BarcodeScannerState createState() {
    return _BarcodeScannerState(camera, cameraController,
        _initializeControllerFuture, updateSize, borderLR, borderTB);
  }
}

class _BarcodeScannerState extends State {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  Function barcodeCallback;
  final CameraDescription camera;
  final Function updateSize;
  final int borderTB;
  final int borderLR;
  IconData torchIcon = Icons.highlight;
  bool torchOn = false;
  _BarcodeScannerState(
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
                // Torch widget TODO waiting for camera plugin update
                Positioned.fill(
                    child: Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        if (torchOn) {
                          torchIcon = Icons.highlight_off;
                          torchOn = false;
                          // _controller.flash(torchOn);
                          // Turn the torch on:
                        } else {
                          torchIcon = Icons.highlight;
                          torchOn = true;
                          // _controller.flash(torchOn);
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

class QuantitySlider extends StatefulWidget {
  final Function valueCallback;
  QuantitySlider(this.valueCallback);
  @override
  _QuantitySliderState createState() {
    return _QuantitySliderState(valueCallback);
  }
}

class _QuantitySliderState extends State {
  Function valueCallback;
  int _value = 1;
  _QuantitySliderState(this.valueCallback);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Slider(
            value: _value.toDouble(),
            min: 1.0,
            max: 10.0,
            divisions: 9,
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
            }));
  }
}

// Define a custom Form widget.
class ManualInputForm extends StatefulWidget {
  final TextEditingController textController;
  ManualInputForm(this.textController);
  @override
  _ManualInputFormState createState() =>
      _ManualInputFormState(this.textController);
}

// This class holds the data related to the Form.
class _ManualInputFormState extends State<ManualInputForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final TextEditingController textController;
  _ManualInputFormState(this.textController);

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(children: <Widget>[
      TextFormField(
        autofocus: true,
        keyboardType: TextInputType.number,
        controller: textController,
        decoration: InputDecoration(labelText: "Código de Barras"),
      ),
    ]));
  }
}
