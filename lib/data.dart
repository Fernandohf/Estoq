import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

// Settings options class
class UserSettings {
  String delimiter = ",";
  String exportPath = 'estoq/sessions';

  UserSettings({this.delimiter, this.exportPath});

  String toString() {
    return "delimiter: $delimiter \n exportPath: $exportPath";
  }
}

// Data row class
class EntryData {
  String barCode;
  int quantity;

  EntryData(this.barCode, this.quantity);

  String toString() {
    return "$barCode , $quantity";
  }
}

// Session data class
class SessionData {
  String name;
  List<EntryData> entries = [];
  final Key key = UniqueKey();
  final DateTime date = DateTime.now();

  SessionData({this.name, this.entries});
  SessionData.empty({this.name});

  List<String> get barcodes {
    List<String> _barcodes = [];
    for (final value in this.entries) {
      _barcodes.add(value.barCode);
    }
    return _barcodes;
  }

  List<int> get quantities {
    List<int> _quantities = [];
    for (final value in this.entries) {
      _quantities.add(value.quantity);
    }
    return _quantities;
  }

  String toString() {
    String stringRep = "";
    for (final entry in this.entries) {
      stringRep += entry.toString() + "\n";
    }
    return stringRep;
  }
}

// Load saved data from disk
List<SessionData> loadSessionDatabByKey(Key key) {
  return [
    SessionData(
        name: "aa",
        entries: [EntryData("78912173131", 5), EntryData("1241242412", 2)]),
    SessionData(
      name: "aa",
    )
  ];
}

List<SessionData> loadSessionsData() {
  return [
    SessionData(
        name: "aa",
        entries: [EntryData("78912173131", 5), EntryData("1241242412", 2)]),
    SessionData(
      name: "bb",
      entries: []
    )
  ];
}

void saveSessionData() {
  //TODO
}
