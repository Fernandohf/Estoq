import 'package:flutter/material.dart';
import 'data.dart';
import 'navigation.dart';

class SessionScreen extends StatelessWidget {
  final SessionData sessionData;
  SessionScreen(this.sessionData);

  void removeEntryDataAt(int index) {
    this.sessionData.entries.removeAt(index);
  }

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
                  print("Deleting session");
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text("Realmente quer remover a sessão?"),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {},
                              child: Text(
                                "Não",
                                style: TextStyle(color: Colors.redAccent),
                              )), // TODO
                          FlatButton(
                              onPressed: () {},
                              child: Text(
                                "Sim",
                                style: TextStyle(color: Colors.blueAccent),
                              )), // TODO
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

class SessionCard extends StatelessWidget {
  final SessionData sessionData;
  final bool reverse;
  const SessionCard(this.sessionData, {this.reverse=false});

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
                    child: Scrollbar(child: _buildEntries(sessionData, reverse: reverse)),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

Widget _buildEntries(SessionData data, {bool reverse=false}) {
  if (data.entries.isEmpty) {
    return Center(
        child: Text(
      "Nada aqui... 🙃",
      style: TextStyle(fontSize: 20, color: Colors.grey[500]),
    ));
  } else {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) =>
          EntryTileItem(data.barcodes[index], data.quantities[index], index),
      itemCount: data.entries.length,
      reverse: reverse,
    );
  }
}

class EntryTileItem extends StatelessWidget {
  final String barcode;
  final int quantity;
  final int index;
  EntryTileItem(this.barcode, this.quantity, this.index);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: Dismissible(
        onDismissed: (DismissDirection direcion) {

        },
        key: Key(index.toString()),
        child: Row(
          children: <Widget>[
            CardText(barcode, 4),
            CardText(quantity.toString(), 1, aligment: TextAlign.center),
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
    return Container(
      child: Expanded(
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
      ),
    );
  }
}
