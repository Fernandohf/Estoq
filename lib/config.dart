import 'package:estoq/data.dart';
import 'package:estoq/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String delimiter;
  int minQuant;
  int maxQuant;
  TextEditingController minController = TextEditingController();
  TextEditingController maxController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    UserSettings settings = Home.of(context).settings;
    delimiter = settings.delimiter;
    minController.text = settings.minQuant.toString();
    maxController.text = settings.maxQuant.toString();
    return Padding(
        padding: EdgeInsets.all(4),
        child: ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ListTile(
                  title: Text("Delimitador"),
                  subtitle: Text(
                      "Valor usado entre o código de barras e a quantidade"),
                  trailing: DropdownButton(
                      //hint: Text("Delimitador entre o código de barras e a quantidade"),
                      value: delimiter,
                      items: [
                        DropdownMenuItem(
                          value: ",",
                          child: Text(","),
                          key: UniqueKey(),
                        ),
                        DropdownMenuItem(
                          value: "/",
                          child: Text("/"),
                          key: UniqueKey(),
                        ),
                        DropdownMenuItem(
                          value: ";",
                          child: Text(";"),
                          key: UniqueKey(),
                        ),
                        DropdownMenuItem(
                          value: " ",
                          child: Text("ESPAÇO"),
                          key: UniqueKey(),
                        ),
                        DropdownMenuItem(
                          value: "\t",
                          child: Text("TAB"),
                          key: UniqueKey(),
                        ),
                      ],
                      onChanged: (String v) {
                        UserSettings settings = Home.of(context).settings;
                        settings.delimiter = v;
                        settings.save();
                        setState(() {
                          delimiter = v;
                        });
                      }),
                ),
              ),
            ),
            // Min
            Card(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ListTile(
                    title: Text("Quantidae Mínima"),
                    subtitle: Text("Valor mínimo do slider de quantidade"),
                    trailing: TextField(
                      controller: minController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      onSubmitted: (String v) {
                        UserSettings settings = Home.of(context).settings;
                        settings.minQuant = int.parse(minController.text);
                        settings.save();
                        setState(
                          () {
                            minQuant = int.parse(v);
                          },
                        );
                      },
                    )),
              ),
            ),
            // Max
            Card(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ListTile(
                    title: Text("Quantidae Máxima"),
                    subtitle: Text("Valor máximo do slider de quantidade"),
                    trailing: TextField(
                      controller: maxController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      onSubmitted: (String v) {
                        UserSettings settings = Home.of(context).settings;
                        settings.maxQuant = int.parse(maxController.text);
                        settings.save();
                        setState(
                          () {
                            maxQuant = int.parse(v);
                          },
                          
                        );
                      },
                    )),
              ),
            )
          ],
        ));
  }
}
