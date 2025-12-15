// ============================================================================
// FILE: lib/database/database_helper.dart
// PURPOSE: SQLite database operations for dropdowns and form submissions
// ============================================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kDebugMode

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('resident_cert.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // <-- Incremented version to trigger upgrade
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // <-- Added upgrade callback
    );
  }

  // This function is called when the database is upgraded from version 1 to 2.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For development, the simplest upgrade strategy is to drop all tables and recreate.
    await db.execute('DROP TABLE IF EXISTS ris');
    await db.execute('DROP TABLE IF EXISTS villages');
    await db.execute('DROP TABLE IF EXISTS tehsils');
    await db.execute('DROP TABLE IF EXISTS districts');
    await db.execute('DROP TABLE IF EXISTS form_submissions');
    await _createDB(db, newVersion);
  }
  
  // Create all tables
  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE districts (id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
    await db.execute('CREATE TABLE tehsils (id INTEGER PRIMARY KEY, district_id INTEGER NOT NULL, name TEXT NOT NULL, FOREIGN KEY (district_id) REFERENCES districts (id))');
    await db.execute('CREATE TABLE villages (id INTEGER PRIMARY KEY AUTOINCREMENT, tehsil_id INTEGER NOT NULL, name TEXT NOT NULL, FOREIGN KEY (tehsil_id) REFERENCES tehsils (id))');
    await db.execute('CREATE TABLE ris (id INTEGER PRIMARY KEY AUTOINCREMENT, tehsil_id INTEGER NOT NULL, name TEXT NOT NULL, FOREIGN KEY (tehsil_id) REFERENCES tehsils (id))');
    await db.execute('CREATE TABLE form_submissions (id INTEGER PRIMARY KEY AUTOINCREMENT, form_data TEXT NOT NULL, created_at TEXT NOT NULL, synced INTEGER DEFAULT 0)');

    await _insertDummyData(db);
  }

  // Insert complete sample data for all defined tehsils
  Future _insertDummyData(Database db) async {
    // Insert Districts
    await db.insert('districts', {'id': 1, 'name': 'Khordha'});
    await db.insert('districts', {'id': 2, 'name': 'Cuttack'});
    await db.insert('districts', {'id': 3, 'name': 'Puri'});

    // --- KHORDHA (District 1) ---
    await db.insert('tehsils', {'id': 101, 'district_id': 1, 'name': 'Bhubaneswar'});
    await db.insert('villages', {'tehsil_id': 101, 'name': 'Chandrasekharpur'});
    await db.insert('villages', {'tehsil_id': 101, 'name': 'Patia'});
    await db.insert('ris', {'tehsil_id': 101, 'name': 'RI Circle-1 (Bbsr)'});
    await db.insert('ris', {'tehsil_id': 101, 'name': 'RI Circle-2 (Bbsr)'});
    
    await db.insert('tehsils', {'id': 102, 'district_id': 1, 'name': 'Jatni'});
    await db.insert('villages', {'tehsil_id': 102, 'name': 'Jatni Town'});
    await db.insert('villages', {'tehsil_id': 102, 'name': 'Khurda Road'});
    await db.insert('ris', {'tehsil_id': 102, 'name': 'RI Circle-1 (Jatni)'});
    
    await db.insert('tehsils', {'id': 103, 'district_id': 1, 'name': 'Balipatna'});
    await db.insert('villages', {'tehsil_id': 103, 'name': 'Balipatna Village'});
    await db.insert('ris', {'tehsil_id': 103, 'name': 'RI Circle (Balipatna)'});

    await db.insert('tehsils', {'id': 104, 'district_id': 1, 'name': 'Tangi'});
    await db.insert('villages', {'tehsil_id': 104, 'name': 'Tangi Village'});
    await db.insert('ris', {'tehsil_id': 104, 'name': 'RI Circle (Tangi)'});
    
    // --- CUTTACK (District 2) ---
    await db.insert('tehsils', {'id': 201, 'district_id': 2, 'name': 'Cuttack Sadar'});
    await db.insert('villages', {'tehsil_id': 201, 'name': 'Sadar Village 1'});
    await db.insert('ris', {'tehsil_id': 201, 'name': 'RI Circle (Cuttack Sadar)'});

    await db.insert('tehsils', {'id': 202, 'district_id': 2, 'name': 'Banki'});
    await db.insert('villages', {'tehsil_id': 202, 'name': 'Banki Village'});
    await db.insert('ris', {'tehsil_id': 202, 'name': 'RI Circle (Banki)'});

    await db.insert('tehsils', {'id': 203, 'district_id': 2, 'name': 'Athgarh'});
    await db.insert('villages', {'tehsil_id': 203, 'name': 'Athgarh Village'});
    await db.insert('ris', {'tehsil_id': 203, 'name': 'RI Circle (Athgarh)'});

    // --- PURI (District 3) ---
    await db.insert('tehsils', {'id': 301, 'district_id': 3, 'name': 'Puri Sadar'});
    await db.insert('villages', {'tehsil_id': 301, 'name': 'Puri Town'});
    await db.insert('ris', {'tehsil_id': 301, 'name': 'RI Circle (Puri Sadar)'});

    await db.insert('tehsils', {'id': 302, 'district_id': 3, 'name': 'Nimapara'});
    await db.insert('villages', {'tehsil_id': 302, 'name': 'Nimapara Village'});
    await db.insert('ris', {'tehsil_id': 302, 'name': 'RI Circle (Nimapara)'});
  }

  // ========== GET METHODS ==========

  Future<List<Map<String, dynamic>>> getDistricts() async {
    final db = await database;
    return await db.query('districts', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getTehsilsByDistrict(int districtId) async {
    final db = await database;
    return await db.query('tehsils', where: 'district_id = ?', whereArgs: [districtId], orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getVillagesByTehsil(int tehsilId) async {
    final db = await database;
    return await db.query('villages', where: 'tehsil_id = ?', whereArgs: [tehsilId], orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getRIsByTehsil(int tehsilId) async {
    final db = await database;
    return await db.query('ris', where: 'tehsil_id = ?', whereArgs: [tehsilId], orderBy: 'name ASC');
  }

  // ========== FORM SUBMISSION METHODS ==========

  Future<int> saveFormSubmission(Map<String, dynamic> formData) async {
    final db = await database;
    final jsonPayload = jsonEncode(formData);

    if (kDebugMode) {
      print('--- FORM SUBMISSION JSON ---');
      print(jsonPayload);
      print('--------------------------');
    }

    return await db.insert('form_submissions', {
      'form_data': jsonPayload,
      'created_at': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getUnsyncedSubmissions() async {
    final db = await database;
    return await db.query('form_submissions', where: 'synced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(int id) async {
    final db = await database;
    return await db.update('form_submissions', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    _database = null;
    db.close();
  }
}
