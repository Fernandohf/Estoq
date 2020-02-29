import 'package:camera/camera.dart';
import 'package:estoq/config.dart';
import 'package:flutter/material.dart';
import 'session_view.dart';
import 'active_view.dart';
import 'config.dart';
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


void navigateToSettings(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          "Configurações",
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        // centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SettingsScreen()
    );
  }));
}


Future<void> navigateToActiveSession(BuildContext context, sessionData) async{
  CameraDescription camera = await getCamera();
  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
    return ActiveSessionScreen(sessionData, camera);
  }));
}
