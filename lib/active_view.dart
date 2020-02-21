import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'session_view.dart';
import 'main.dart';

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
  _ActiveSessionScreenState(this.sessionData, this.camera);

  void updateSliderValue(int value) {
    this.sliderValue = value;
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _camController = CameraController(camera, ResolutionPreset.medium);
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
    // Dispose of the controller when the widget is disposed.
    _camController.dispose();
    _tabController.dispose();
    _textEditingController.dispose();
    // Sessions sessions = Home.of(context).sessions;
    // sessions.saveAll();
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
              Expanded(
                flex: 4,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    BarcodeScanner(
                        camera, _camController, _initializeControllerFuture),
                    ManualInputForm(_textEditingController),
                  ],
                ),
              ),
              Expanded(
                  flex: 5,
                  child: SafeArea(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                        SessionCard(sessionData, true),
                      ]))),
              Container(
                height: 80,
                alignment: Alignment.bottomCenter,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Quantidade',
                          style: TextStyle(fontSize: 18),
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
                                  (await getTemporaryDirectory()).path,
                                  '${DateTime.now()}.png',
                                );

                                // Attempt to take a picture and log where it's been saved.
                                await _camController.takePicture(path);
                                print("Picture saved: $path");

                                // Load picture
                                Image image = Image.file(File(path));

                                // TODO ML toolkit
                              } catch (e) {
                                // If an error occurs, log the error to the console.
                                print(e);
                              }
                            }
                            // Not on camera tab
                            else {
                              lastBarcode = _textEditingController.text;
                              print(lastBarcode);
                              // Empty text
                              _textEditingController.text = "";
                            }
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
                            setState(() {});
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

class BarcodeScanner extends StatefulWidget {
  final CameraDescription camera;
  final CameraController cameraController;
  final Future<void> _initializeControllerFuture;

  BarcodeScanner(
      this.camera, this.cameraController, this._initializeControllerFuture);

  @override
  _BarcodeScannerState createState() {
    return _BarcodeScannerState(
        camera, cameraController, _initializeControllerFuture);
  }
}

class _BarcodeScannerState extends State {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  Function barcodeCallback;
  final CameraDescription camera;
  _BarcodeScannerState(
      this.camera, this._controller, this._initializeControllerFuture);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width;
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
                  width: size,
                  height: size,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Container(
                          width: size,
                          height: size / _controller.value.aspectRatio,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            // child: CustomPainter(
                            //   painter: ,
                            //   foregroundPainter: new GuidelinePainter(), // TODO painting
                            child: CameraPreview(_controller),
                          ), // this is my CameraPreview
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      border: Border(
                        top: BorderSide(color: Colors.black45, width: 45),
                        left: BorderSide(color: Colors.black45, width: 25),
                        right: BorderSide(color: Colors.black45, width: 25),
                        bottom: BorderSide(color: Colors.black45, width: 45),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Divider(
                    color: Colors.redAccent,
                    thickness: 3,
                    indent: 40,
                    endIndent: 40,
                  )
                ),
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
