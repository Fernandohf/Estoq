import 'package:estoq/data.dart';
import 'package:estoq/main.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(4),
        child: ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ListTile(
                  title: Text("Delimitador"),
                  subtitle: Text("Valor usado entre o código de barras e a quantidade"),
                  trailing: DropdownButton(
                      //hint: Text("Delimitador entre o código de barras e a quantidade"),
                      value: ",",
                      items: [
                        DropdownMenuItem(
                          value: ";",
                          child: Text(";"),
                          key: UniqueKey(),
                        ),
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
                      onChanged: (String value) {
                        UserSettings settings = Home.of(context).settings;
                        settings.delimiter = value;
                      }),
                ),
              ),
            )
          ],
        ));
  }
}
