import 'package:flutter/material.dart';
import 'data.dart';
import 'navigation.dart';

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