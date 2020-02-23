import 'package:flutter/material.dart';
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
          SessionCard(sessionData),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text("Realmente quer remover a sessão?"),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Não",
                                style: TextStyle(color: Colors.redAccent),
                              )),
                          FlatButton(
                              onPressed: () async {
                                Sessions sessions = Home.of(context).sessions;
                                await sessions.remove(sessionData);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Sim",
                                style: TextStyle(color: Colors.blueAccent),
                              )),
                        ],
                      ));
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
              ),
              FlatButton(
                onPressed: () {
                  print("Export this session");
                }, // TODO append to entry
                child: Icon(Icons.arrow_upward, color: Colors.blueAccent),
              ),
              FlatButton(
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
  SessionCard(this.sessionData);

  @override
  _SessionCardState createState() => _SessionCardState(sessionData);
}

class _SessionCardState extends State<SessionCard> {
  SessionData sessionData;
  _SessionCardState(this.sessionData);

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
                                  return EntryTileItem({
                                    "barcode": barcodes[index],
                                    "quantity": quantities[index],
                                  }, index, sessionData);
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

class EntryTileItem extends StatefulWidget {
  final Map<String, Object> entry;
  final int index;
  final SessionData sessionData;
  EntryTileItem(this.entry, this.index, this.sessionData);

  @override
  _EntryTileItemState createState() =>
      _EntryTileItemState(this.entry, this.index, this.sessionData);
}

class _EntryTileItemState extends State<EntryTileItem> {
  Map<String, Object> entry;
  final int index;
  SessionData sessionData;
  _EntryTileItemState(this.entry, this.index, this.sessionData);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: Dismissible(
        onDismissed: (DismissDirection direcion) {
          Sessions sessions = Home.of(context).sessions;
          sessions.removeEntryAt(sessionData, index);
          print(sessions.data);
        },
        key: UniqueKey(),
        child: Row(
          children: <Widget>[
            CardText(entry["barcode"], 4),
            CardText(entry["quantity"].toString(), 1,
                aligment: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class CardText extends StatelessWidget {
  final String text;
  final int weight;
  final TextAlign aligment;
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
