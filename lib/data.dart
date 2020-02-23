import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'dart:io';

// Settings options class
class UserSettings {
  String delimiter;
  String exportPath;

  UserSettings({this.delimiter = ",", this.exportPath = 'estoq/sessions'});
  UserSettings.fromMap(var map) {
    this.delimiter = map["delimiter"];
    this.exportPath = map["exportPath"];
  }

  set changeDelimiter(String value) {
    if ([";", ",", " ", "/", "\t"].contains(value)) {
      this.delimiter = value;
    } else {
      print("Invalid Delimiter");
    }
  }

  void save() async {
    // Saves in main store
    Database db = await getDb();
    var store = StoreRef.main();

    // Easy to put/get simple values or map
    await db.transaction((txn) async {
      await store.record('delimiter').put(txn, this.delimiter);
      await store.record('exportPath').put(txn, this.exportPath);
    });
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
}

// Session data class
class SessionData {
  String name;
  List<Map<String, Object>> entries = [];
  Key key;
  DateTime date = DateTime.now();

  SessionData.empty(String name) {
    this.name = name;
    this.key = Key(name);
    this.date = DateTime.now();
    print(this);
  }
  SessionData.fromRecordSnapShot(var map) {
    this.name = map["name"];
    this.entries = List.from(map["entries"]);
    this.date = DateTime.parse(map["date"]);
    this.key = Key(this.name);
  }

  List<String> get barcodes {
    List<String> _barcodes = [];
    for (final value in this.entries) {
      _barcodes.add(value["barcode"]);
    }
    return _barcodes;
  }

  List<int> get quantities {
    List<int> _quantities = [];
    for (final value in this.entries) {
      _quantities.add(value["quantity"]);
    }
    return _quantities;
  }

  void removeEntry(int index) {
    this.entries.removeAt(index);
  }

  void save() async {
    // Saves in main store
    Database db = await getDb();
    var sessionStore = getSessionStore();

    // Easy to put/get simple values or map
    await db.transaction((txn) async {
      await sessionStore.record(this.key.toString()).put(txn, {
        "name": this.name,
        "entries": this.entries,
        "date": this.date.toString()
      });
    });
  }

  Future<void> export(String delimiter) async {
    final directory = await getExternalStorageDirectory();
    final exportDir = await Directory('${directory.path}/Estoq/').create();
    final file = File(exportDir.path + '${this.name}.txt');
    String content = "";
    for (final Map<String, Object> entry in this.entries) {
      content += entry["barcode"].toString() +
          delimiter +
          entry["quantity"].toString() +
          "\n";
    }
    await file.writeAsString(content);
    print("Saving $content at ${file.path}");
  }

  Future<void> delete() async {
    Database db = await getDb();
    var sessionStore = getSessionStore();

    // Easy to put/get simple values or map
    await db.transaction((txn) async {
      await sessionStore.record(this.key.toString()).delete(txn);
    });
  }

  String toString() {
    String stringRep = "";
    for (final entry in this.entries) {
      stringRep += entry.toString() + "\n";
    }
    return stringRep;
  }
}

class Sessions {
  Map<String, SessionData> data = {};

  Future<void> loadFromDisk() async {
    Database db = await getDb();
    var sessionStore = getSessionStore();
    var finder = Finder(sortOrders: [SortOrder('name')]);
    var results = await sessionStore.find(db, finder: finder);
    Map<String, SessionData> sessions = {};
    for (final map in results) {
      sessions[map.key] = SessionData.fromRecordSnapShot(map);
    }
    this.data = sessions;
  }

  Future<void> remove(SessionData session) async {
    await this.data[session.key.toString()].delete();
    this.data.remove(session.key.toString());
  }

  void add(SessionData session) {
    this.data[session.key.toString()] = session;
    this.data[session.key.toString()].save();
  }

  void saveAll() {
    for (final value in this.data.values) {
      value.save();
    }
  }

  void exportAll(String delimiter) {
    for (final value in this.data.values) {
      value.export(delimiter);
    }
  }

  void addEntry(SessionData session, Map<String, Object> entry) {
    this.data[session.key.toString()].entries.add(entry);
    this.data[session.key.toString()].save();
  }

  void removeEntryAt(SessionData session, int index) {
    this.data[session.key.toString()].entries.removeAt(index);
    this.data[session.key.toString()].save();
  }

  void deleteAll() async {
    // On disk
    var db = await getDb();
    var store = getSessionStore();
    await store.delete(db);
    // Memory
    this.data = {};
  }
}

Future<Database> getDb() async {
  var dir = await getApplicationDocumentsDirectory();
  // make sure it exists
  await dir.create(recursive: true);
  // build the database path
  var dbPath = join(dir.path, 'estoq.db');
  return await databaseFactoryIo.openDatabase(dbPath);
}

StoreRef getSessionStore() {
  return stringMapStoreFactory.store("Sessions");
}

Future<UserSettings> loadUserSettings() async {
  Database db = await getDb();
  var store = StoreRef.main();

  var results = await store.find(db);

  // Only singletons
  if (results.isEmpty) {
    return UserSettings();
  } else {
    return UserSettings.fromMap(results.first);
  }
}
