import 'package:estoq/data.dart';
import 'package:estoq/main.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String value;
  @override
  Widget build(BuildContext context) {
    UserSettings settings = Home.of(context).settings;
    value = settings.delimiter;
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
                      value: value,
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
                        setState(() {
                          value = v;  
                        });
                        
                      }),
                ),
              ),
            )
          ],
        ));
  }
}
