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
}

// Load saved data from disk
List<SessionData> loadSessionDatabByKey(Key key) {
  return [
    SessionData(name: "aa", entries: [EntryData("78912173131", 5)])
  ];
}

List<SessionData> loadSessionsData() {
  return [
    SessionData(name: "aa", entries: [EntryData("78912173131", 5)])
  ];
}

void saveSessionData()
{
  //TODO
}
