import 'package:estoq/data.dart';
import 'package:estoq/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String delimiter;
  late int minQuant;
  late int maxQuant;
  late bool checkBarcode;
  TextEditingController minController = TextEditingController();
  TextEditingController maxController = TextEditingController();
  SnackBar snackSavedSettings = SnackBar(
      duration: Duration(milliseconds: 800),
      content: Text("Configurações salvas!"));

  String? minInputValidator(String? value) {
    if ((value == "") || (value == null))
      return "Valor inválido";
    else if (int.parse(value) >= maxQuant) {
      return "Esse valor deve ser menor que o máximo";
    } else
      return null;
  }

  String? maxInputValidator(String? value) {
    if ((value == "") || ((value == null)))
      return "Valor inválido";
    else if (int.parse(value) <= minQuant) {
      return "Esse valor deve ser maior que o mínimo";
    } else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    UserSettings settings = Home.of(context)!.settings;
    delimiter = settings.delimiter;
    minController.text = settings.minQuant.toString();
    maxController.text = settings.maxQuant.toString();
    minQuant = int.parse(minController.text);
    maxQuant = int.parse(maxController.text);
    checkBarcode = settings.checkBarcode;
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
                    onChanged: (String? v) {
                      UserSettings settings = Home.of(context)!.settings;
                      if (v != null) {
                        settings.delimiter = v;
                        settings.save();
                        setState(() {
                          delimiter = v;
                        });
                      }
                      ScaffoldMessenger.of(context)
                          .showSnackBar(snackSavedSettings);
                    }),
              ),
            ),
            // Min
            ListTile(
              contentPadding: EdgeInsets.all(4),
              title: Text("Quantidade Mínima"),
              subtitle: Text("Valor mínimo do slider de quantidade"),
              trailing: Container(
                width: 84,
                child: TextFormField(
                  controller: minController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: minInputValidator,
                  onEditingComplete: () {
                    UserSettings settings = Home.of(context)!.settings;
                    settings.minQuant = int.parse(minController.text);
                    settings.save();
                    setState(
                      () {
                        minQuant = settings.minQuant;
                      },
                    );
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackSavedSettings);
                  },
                ),
              ),
            ),
            // Max
            ListTile(
              contentPadding: EdgeInsets.all(4),
              title: Text("Quantidade Máxima"),
              subtitle: Text("Valor máximo do slider de quantidade"),
              trailing: Container(
                width: 84,
                child: TextFormField(
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(),
                  validator: maxInputValidator,
                  onEditingComplete: () {
                    UserSettings settings = Home.of(context)!.settings;
                    settings.maxQuant = int.parse(maxController.text);
                    settings.save();
                    setState(
                      () {
                        maxQuant = settings.maxQuant;
                      },
                    );
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackSavedSettings);
                  },
                ),
              ),
            ),
            // Check
            ListTile(
              contentPadding: EdgeInsets.all(4),
              title: Text("Verificar Código de Barras"),
              subtitle: Text(
                  "Checa se o código de barras é valido na 'Entrada Manual', de acordo com o padrão EAN13"),
              trailing: Container(
                width: 84,
                child: Checkbox(
                  value: checkBarcode,
                  onChanged: (bool? value) {
                    UserSettings settings = Home.of(context)!.settings;
                    if (value != null) {
                      settings.checkBarcode = value;
                      settings.save();
                      setState(
                        () {
                          checkBarcode = value;
                        },
                      );
                    }
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackSavedSettings);
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
