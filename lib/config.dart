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
  SnackBar snackSavedSettings = SnackBar(
      duration: Duration(milliseconds: 800),
      content: Text("Configurações salvas!"));
  String minInputValidator(String value) {
    if (value == "")
      return "Valor inválido";
    else if (int.parse(value) >= maxQuant) {
      return "Esse valor deve ser menor que o máximo";
    } else
      return null;
  }

  String maxInputValidator(String value) {
    if (value == "")
      return "Valor inválido";
    else if (int.parse(value) <= minQuant) {
      return "Esse valor deve ser maior que o mínimo";
    } else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    UserSettings settings = Home.of(context).settings;
    delimiter = settings.delimiter;
    minController.text = settings.minQuant.toString();
    maxController.text = settings.maxQuant.toString();
    minQuant = int.parse(minController.text);
    maxQuant = int.parse(maxController.text);
    return Padding(
        padding: EdgeInsets.all(4),
        child: ListView(
          children: <Widget>[
            Container(
              height: 60,
              child: ListTile(
                contentPadding: const EdgeInsets.all(4),
                title: Text("Delimitador"),
                subtitle:
                    Text("Valor usado entre o código de barras e a quantidade"),
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
                      Scaffold.of(context).showSnackBar(snackSavedSettings);
                    }),
              ),
            ),
            // Min
            ListTile(
              contentPadding: EdgeInsets.all(4),
              title: Text("Quantidae Mínima"),
              subtitle: Text("Valor mínimo do slider de quantidade"),
              trailing: Container(
                width: 84,
                child: TextFormField(
                  controller: minController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  autovalidate: true,
                  validator: minInputValidator,
                  onEditingComplete: () {
                    UserSettings settings = Home.of(context).settings;
                    settings.minQuant = int.parse(minController.text);
                    settings.save();
                    setState(
                      () {
                        minQuant = settings.minQuant;
                      },
                    );
                    Scaffold.of(context).showSnackBar(snackSavedSettings);
                  },
                ),
              ),
            ),
            // Max
            ListTile(
              contentPadding: EdgeInsets.all(4),
              title: Text("Quantidae Máxima"),
              subtitle: Text("Valor máximo do slider de quantidade"),
              trailing: Container(
                width: 84,
                child: TextFormField(
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(),
                  autovalidate: true,
                  validator: maxInputValidator,
                  onEditingComplete: () {
                    UserSettings settings = Home.of(context).settings;
                    settings.maxQuant = int.parse(maxController.text);
                    settings.save();
                    setState(
                      () {
                        maxQuant = settings.maxQuant;
                      },
                    );
                    Scaffold.of(context).showSnackBar(snackSavedSettings);
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
