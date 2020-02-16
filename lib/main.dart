import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// Load data
var sessions_names = [
  'Session1',
  'Session1',
  'Session1',
  'Session1',
  'Session1',
  'Session1',
  'Session1'
];
var sessions_content = [
  '798456451351351, 2\n798456451351351, 2\n\n\n\n\n\n\n\n\n\n\nfrfr  \n\n\n\n\n\n\n\n\n\fn\n\n\n\fn\n\n\n\n\n\fn\n\n\n\n\nf\n\n\n\n\n\n\nfr\n\n\n',
  '798456451351351, 3\n',
  'Sessiondwedwedwedwe1',
  'Sedwedwedwedwssion1',
  'Sedwedwedwedssion1',
  'Session1',
  'Session1'
];

class SessionDataEntry {
  String barCode;
  int quantity;

  SessionDataEntry({this.barCode, this.quantity});

  // TODO Widget _getListTile()
}

// StorageClass
class SessionData {
  String name;
  List<SessionDataEntry> entries = [];
  Key key = UniqueKey();
  SessionData({this.name, this.entries});
}

// Constants
const _savepath = 'estoq/sessions';

// main call

// Main
void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estoq',
      home: Scaffold(
          drawer: drawer,
          appBar: AppBar(
            title: Text(
              'Estoq',
              style: TextStyle(fontSize: 25),
            ),
            backgroundColor: Colors.blueAccent,
          ),
          body: _buildSessions(),
          floatingActionButton: ActionButton()),
    );
  }
}

List<SessionData> _loadStoredData()
{
  for ()
}

// TODO fix for new patterns
Widget _buildSessions() {
  return ListView.builder(
    itemBuilder: (BuildContext context, int index) =>
        SessionTileItem(SessionData()),
    itemCount: sessions_names.length,
  );
}

// Session edit screen

void _navigateToSession(BuildContext context, sessionData) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
  Navigator.of(context)
      .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          sessionData.name,
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        // centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SessionView(sessionData),
    );
  }));
}

void _navigateToActiveSession(BuildContext context, sessionData) {
  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
    return ActiveSessionScreen(sessionData);
  }));
}

class SessionView extends StatelessWidget {
  final SessionData sessionData;
  SessionView(this.sessionData);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Card(
              color: Colors.blueGrey[50],
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Text(
                        //   name,
                        //   textAlign: TextAlign.left,
                        //   style: TextStyle(color: Colors.black, fontSize: 20),
                        // ),
                        Expanded(
                          child: Scrollbar(
                            child: ListView(children: <Widget>[
                              Container(
                                child: Text(
                                  sessionData.entries.toString(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ),
                            ]),
                          ),
                        )
                      ]),
                ),
              ),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  print("Remove this session");
                }, // TODO remove entry with confirmaiton dialog
                child: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
              ),
              FlatButton(
                onPressed: () {
                  print("Export this session");
                }, // append to entry
                child: Icon(Icons.arrow_upward, color: Colors.blueAccent),
              ),
              FlatButton(
                onPressed: () {
                  _navigateToActiveSession(context, sessionData);
                }, // append to entry
                child: Icon(Icons.add_circle, color: Colors.blueAccent),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ActiveSessionScreen extends StatelessWidget {
  final SessionData sessionData;
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
                  Placeholder(), // Barcode Widget
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

// class BarcodeScanner extends StatefulWidget {
//   @override
//   _BarcodeScannerState createState() {
//     return _BarcodeScannerState();
//   }
// }

// class _BarcodeScannerState extends State {
//   String _scanCode = "";

//   @override
//   void initState() {
//     super.initState();
//   }

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

class SessionTileItem extends StatelessWidget {
  final String sessionData;
  SessionTileItem(this.sessionData);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(.5),
      child: Card(
        color: Colors.blueGrey[50],
        child: InkWell(
          onTap: () {
            _navigateToSession(context, sessionData);
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      sessionData.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.blueGrey,
                          //fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Container(
                      child: Text(
                        content.substring(0, min(36, content.length)),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.blueGrey[400], fontSize: 12),
                      ),
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(context: context, builder: (_) => new NewSessionDialog());
        // showDialog(context: context, builder: (_) => new NewSessionDialog());
      },
      backgroundColor: Colors.blueAccent,
      child: const Icon(Icons.add),
      tooltip: 'Nova sessão de coleta',
    );
  }
}

var drawer = Drawer(
  child: SafeArea(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
                Text(
                  'Total de coletas: ${sessions_names.length}',
                  style: TextStyle(fontSize: 15, color: Colors.grey[100]),
                ),
              ]),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
          ),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Configurações'),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.arrow_upward),
          title: Text('Exportar'),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('Informações'),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
      ],
    ),
  ),
);

class NewSessionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: Text("Nova Sessão"), children: <Widget>[
      Padding(
          padding: const EdgeInsets.fromLTRB(18, 1, 18, 2),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  initialValue: 'Sessao_${1 + sessions_names.length}',
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                    gapPadding: .3,
                  )),
                ),
                // CheckboxListTile(
                //   title: const Text(
                //     'Perguntar quantidade?',
                //     style: TextStyle(color: Colors.black),
                //   ),
                //   value: false,
                //   onChanged: null, //TODO
                //   secondary: Icon(Icons.format_list_numbered),
                // ),
              ],
            ),
          )),
      ButtonBar(
        alignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('Cancelar', style: TextStyle(color: Colors.redAccent))),
          FlatButton(
              onPressed: null, // TODO
              child: Text(
                'Iniciar',
                style: TextStyle(color: Colors.blueAccent),
              )),
        ],
      )
    ]);
  }
}
