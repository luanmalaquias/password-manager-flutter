import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDataBase() async {
  String dbpath = await getDatabasesPath();
  String path = join(dbpath, 'Banco.db');
  return openDatabase(path, onCreate: (db, version){
    db.execute('CREATE TABLE credenciais( id INTEGER PRIMARY KEY AUTOINCREMENT, site TEXT, senha TEXT )');
  }, version: 1);
}
