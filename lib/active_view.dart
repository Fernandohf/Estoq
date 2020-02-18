import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'data.dart';

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

class ActiveSessionScreen extends StatelessWidget {
  final SessionData sessionData;
  CameraDescription camera;
  ActiveSessionScreen(this.sessionData);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.blueAccent,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.camera_alt), text: "Scanear"),
              Tab(icon: Icon(Icons.space_bar), text: "Manual"),
            ],
          ),
          title: Text('$sessionData.name'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: TabBarView(
                children: [
                  BarcodeScanner(camera), // Barcode Widget
                  ManualInputForm(),
                ],
              ),
            ),
            Container(
              height: 80,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Quantidade',
                      style: TextStyle(fontSize: 18),
                    ),
                    QuantitySlider(),
                    RaisedButton(
                      onPressed: () {
                        return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                // Retrieve the text the that user has entered by using the
                                // TextEditingController.
                                content: Text("dede"),
                              );
                            });
                      },
                      child: Text("OK"),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BarcodeScanner extends StatefulWidget {
  final CameraDescription camera;
  String _scanCode;
  BarcodeScanner(this.camera);

  @override
  _BarcodeScannerState createState() {
    return _BarcodeScannerState(camera);
  }
}

class _BarcodeScannerState extends State {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String _scanCode = "";
  final CameraDescription camera;
  _BarcodeScannerState(this.camera);

  @override
  void initState() {
    super.initState();
    _controller = CameraController(camera, ResolutionPreset.low);
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text("TEST");
  }
}

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> scanBarcodeNormal() async {
//     String barcodeScanRes;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//           "#ff6666", "Cancel", true, ScanMode.BARCODE);
//       print(barcodeScanRes);
//     } on PlatformException {
//       barcodeScanRes = 'Failed to get platform version.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _scanCode = barcodeScanRes;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RaisedButton(
//       onPressed: () {
//         scanBarcodeNormal();
//       },
//       child: Icon(Icons.check),
//     );
//   }
// }

class QuantitySlider extends StatefulWidget {
  @override
  _QuantitySliderState createState() {
    return _QuantitySliderState();
  }
}

class _QuantitySliderState extends State {
  int _value = 1;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Slider(
            value: _value.toDouble(),
            min: 1.0,
            max: 10.0,
            divisions: 10,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.lightBlueAccent,
            label: '$_value',
            onChanged: (double newValue) {
              setState(() {
                _value = newValue.round();
              });
            },
            semanticFormatterCallback: (double newValue) {
              return '${newValue.round()}';
            }));
  }
}

// Define a custom Form widget.
class ManualInputForm extends StatefulWidget {
  @override
  _ManualInputFormState createState() => _ManualInputFormState();
}

// This class holds the data related to the Form.
class _ManualInputFormState extends State<ManualInputForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(children: <Widget>[
      TextFormField(
        autofocus: true,
        keyboardType: TextInputType.number,
        controller: myController,
        decoration: InputDecoration(labelText: "Código de Barras"),
      ),
      // RaisedButton(
      //   onPressed: () {
      //     return showDialog(
      //         context: context,
      //         builder: (context) {
      //           return AlertDialog(
      //             // Retrieve the text the that user has entered by using the
      //             // TextEditingController.
      //             content: Text(myController.text),
      //           );
      //         });
      //   },
      //   child: Text("OK"),
      // )
    ]));
  }
}
