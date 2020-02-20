import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

// Settings options class
class UserSettings {
  String delimiter = ",";
  String exportPath = 'estoq/sessions';

  UserSettings({this.delimiter});

  set changeDelimiter(String value) {
    if ([";", ",", " ", "/", "\t"].contains(value)) {
      this.delimiter = value;
    } else {
      print("Invalid Delimiter");
    }
  }

  String toString() {
    return "delimiter: $delimiter, \n exportPath: $exportPath,";
  }

  Map toMap() {
    return {
      "delimiter": delimiter,
      "exportPath": exportPath,
    };
  }

  void fromMap(Map map) {
    this.delimiter = map["delimiter"];
    this.exportPath = map["exportPath"];
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
  void fromMap(Map map) {
    this.barCode = map["barcode"];
    this.quantity = map["quantity"];
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
  void fromMap(Map map) {
    this.name = map["name"];
    this.entries = map["entries"]; //TODO
  }
}

// Load saved data from disk
List<SessionData> testSessionsData(Key key) {
  return [
    SessionData(
        name: "aa",
        entries: [EntryData("78912173131", 5), EntryData("1241242412", 2)]),
    SessionData(
      name: "aa",
    )
  ];
}

Future<Database> getDb() async {
  var dir = await getApplicationDocumentsDirectory();
  // make sure it exists
  await dir.create(recursive: true);
  // build the database path
  var dbPath = join(dir.path, 'estoq.db');
  return await databaseFactoryIo
      .openDatabase(dbPath);
}

void penSessionsTable(Database db) async {
  // get the application documents directory

}
Future<List<SessionData>> loadSessionsData() async{

  return []
}

void saveSessionData() {
  //TODO
}
