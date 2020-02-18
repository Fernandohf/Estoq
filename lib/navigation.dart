import 'package:flutter/material.dart';
import 'session_view.dart';
import 'active_view.dart';
// Session edit screen


void navigateToSession(BuildContext context, sessionData) {
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
      body: SessionScreen(sessionData),
    );
  }));
}

void navigateToActiveSession(BuildContext context, sessionData) {
  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
    return ActiveSessionScreen(sessionData);
  }));
}
