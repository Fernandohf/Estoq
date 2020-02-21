import 'package:flutter/material.dart';
import 'dart:async';
import 'home.dart';
import 'data.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// Main
Future<void> main() async {
  // Load user data
  WidgetsFlutterBinding.ensureInitialized();
  Sessions sessions = Sessions();
  await sessions.loadFromDisk();
  UserSettings settings = await loadUserSettings();

  runApp(Home(child: HomeScreen(), settings: settings, sessions: sessions));
}

class Home extends InheritedWidget {
  final Widget child;
  final UserSettings settings;
  final Sessions sessions;
  Home({this.child, this.settings, this.sessions}) : super(child: child);

  static Home of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType());
  }

  @override
  bool updateShouldNotify(Home oldWidget) {
    return true;
  }
}
