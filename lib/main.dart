import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'active_view.dart';
import 'dart:async';
import 'data.dart';
import 'home.dart';

// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// Main
Future<void> main() async{
  CameraDescription camera = await getCamera();
  // get data saved locally
  runApp(Home());
}
