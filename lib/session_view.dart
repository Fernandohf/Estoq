import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'data.dart';
import 'navigation.dart';
import 'main.dart';

class SessionScreen extends StatelessWidget {
  final SessionData sessionData;
  SessionScreen(this.sessionData);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SessionCard(sessionData, true),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Realmente quer remover a sessão?"),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Não",
                                  style: TextStyle(color: Colors.redAccent),
                                )),
                            TextButton(
                                onPressed: () async {
                                  Sessions sessions =
                                      Home.of(context)!.sessions;
                                  await sessions.remove(sessionData);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Sim",
                                  style: TextStyle(color: Colors.blueAccent),
                                )),
                          ],
                        );
                      });
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
              ),
              TextButton(
                onPressed: () async {
                  UserSettings settings = Home.of(context)!.settings;
                  String? filePath =
                      await sessionData.export(settings.delimiter);
                  await FlutterShare.shareFile(
                    title: 'Compartilhe o arquivo exportado',
                    text: '${sessionData.name}.txt',
                    filePath: filePath!,
                  );
                  print("Sharing text file $filePath");
                },
                child: Icon(Icons.share, color: Colors.blueAccent),
              ),
              TextButton(
                onPressed: () async {
                  UserSettings settings = Home.of(context)!.settings;
                  await sessionData.export(settings.delimiter);
                  print("Export this session");
                  SnackBar snackExport = SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text("${sessionData.name} foi exportada"));
                  ScaffoldMessenger.of(context).showSnackBar(snackExport);
                },
                child: Icon(Icons.arrow_upward, color: Colors.blueAccent),
              ),
              TextButton(
                onPressed: () {
                  navigateToActiveSession(context, sessionData);
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

class SessionCard extends StatefulWidget {
  final SessionData sessionData;
  final bool dismissable;
  SessionCard(this.sessionData, this.dismissable);

  @override
  _SessionCardState createState() =>
      _SessionCardState(sessionData, dismissable);
}

class _SessionCardState extends State<SessionCard> {
  SessionData sessionData;
  final bool dismissable;

  _SessionCardState(this.sessionData, this.dismissable);

  Widget controlTile(bool dismiss, Map entry, int index) {
    Widget row = Row(
      children: <Widget>[
        CardText(entry["barcode"], 4),
        CardText(entry["quantity"].toString(), 1, aligment: TextAlign.center),
      ],
    );
    if (dismiss) {
      return Dismissible(
          onDismissed: (DismissDirection direcion) {
            setState(() {
              Sessions sessions = Home.of(context)!.sessions;
              // sessions.removeEntryAt(sessionData, index);
              print(sessions.data);
              sessionData.removeEntry(index);
            });

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(milliseconds: 500),
                content: Text(
                    "(${entry["barcode"]}, ${entry["quantity"]}) dismissed")));
          },
          key: UniqueKey(),
          child: row);
    } else {
      return row;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                  Expanded(
                    child: Scrollbar(
                        child: sessionData.entries.isEmpty
                            ? Center(
                                child: Text(
                                "Nada aqui... 🙃",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey[500]),
                              ))
                            : ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  List<String> barcodes;
                                  List<int> quantities;
                                  barcodes = sessionData.barcodes;
                                  quantities = sessionData.quantities;
                                  return controlTile(
                                      dismissable,
                                      {
                                        "barcode": barcodes[index],
                                        "quantity": quantities[index],
                                      },
                                      index);
                                },
                                itemCount: sessionData.entries.length,
                              )),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class CardText extends StatelessWidget {
  final String text;
  final int weight;
  final TextAlign? aligment;
  CardText(this.text, this.weight, {this.aligment});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: weight,
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                textAlign: aligment,
                style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
