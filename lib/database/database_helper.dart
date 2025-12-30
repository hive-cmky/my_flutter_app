// ===================================================
// DATABASE HELPER - FIXED VERSION
// Returns 'code' (Organization Unit Code) for API submission
// Returns 'org_code' (same as 'code') for fetching children
// ===================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _lgdDb;
  static Database? _coverageDb;
  static Database? _ricDb;

  DatabaseHelper._init();

  String _cleanName(String fullName) {
    if (fullName.isEmpty) return '';
    final match = RegExp(r'-\s*([^)]+)').firstMatch(fullName);
    if (match != null) return match.group(1)!.trim();
    return fullName.replaceAll(')', '').trim();
  }

  Future<Database> get lgdDatabase async {
    if (_lgdDb != null) return _lgdDb!;
    _lgdDb = await _initDB('lgd_master.db');
    return _lgdDb!;
  }

  Future<Database> get coverageDatabase async {
    if (_coverageDb != null) return _coverageDb!;
    _coverageDb = await _initDB('coverage_location.db');
    return _coverageDb!;
  }

  Future<Database> get ricDatabase async {
    if (_ricDb != null) return _ricDb!;
    _ricDb = await _initDB('ric_master.db');
    return _ricDb!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    if (kDebugMode && await File(path).exists()) {
      await File(path).delete();
    }

    if (!await File(path).exists()) {
      await Directory(dirname(path)).create(recursive: true);
      final data = await rootBundle.load('assets/db/$fileName');
      final bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(path, readOnly: true);
  }

  // ================= DISTRICTS =================
  Future<List<Map<String, String>>> getDistricts() async {
    final db = await lgdDatabase;

    final results = await db.query(
      'Sheet1',
      where: 'LOWER("Administrative Office Unit Level") = ?',
      whereArgs: ['district'],
      orderBy: '"Administrative Office  Entity Name" ASC',
    );

    if (results.isEmpty) return [];

    final List<Map<String, String>> districts = [];

    for (final d in results) {
      final String name = (d['Administrative Office  Entity Name'] as String?) ?? '';
      final String lgdCode = (d['Administrative Entity Code'] as String?) ?? '';
      final String orgCode = (d['Organization Unit Code'] as String?) ?? '';

      if (name.trim().isEmpty) continue;

      districts.add({
        'name': _cleanName(name),
        'code': orgCode.trim(),           // ✅ Organization Unit Code (for API)
        'org_code': orgCode.trim(),       // ✅ Same, for fetching children
        'lgd_code': lgdCode.trim(),       // ✅ Keep this for reference
      });
    }

    return districts;
  }

  // ================= TEHSILS =================
  Future<List<Map<String, String>>> getTehsils(String districtOrgCode) async {
    if (districtOrgCode.isEmpty) return [];

    final db = await lgdDatabase;

    final results = await db.rawQuery('''
      SELECT *
      FROM Sheet1
      WHERE LOWER("Administrative Office Unit Level") = 'tehsil'
        AND "Parent Org Unit Code" IN (
          SELECT "Organization Unit Code"
          FROM Sheet1
          WHERE "Organization Unit Code" = ?
             OR (
               LOWER("Administrative Office Unit Level") = 'sub division'
               AND "Parent Org Unit Code" = ?
             )
        )
      ORDER BY "Administrative Office  Entity Name" ASC
    ''', [districtOrgCode, districtOrgCode]);

    if (results.isEmpty) return [];

    final List<Map<String, String>> tehsils = [];

    for (final d in results) {
      final String name = (d['Administrative Office  Entity Name'] as String?) ?? '';
      final String lgdCode = (d['Administrative Entity Code'] as String?) ?? '';
      final String orgCode = (d['Organization Unit Code'] as String?) ?? '';

      if (name.trim().isEmpty) continue;

      tehsils.add({
        'name': _cleanName(name),
        'code': orgCode.trim(),           // ✅ Organization Unit Code (for API)
        'org_code': orgCode.trim(),       // ✅ Same, for fetching children
        'lgd_code': lgdCode.trim(),       // ✅ Keep this for reference
      });
    }

    return tehsils;
  }

  // ================= RI / REVENUE CIRCLE =================
  Future<List<Map<String, String>>> getRIs(String tehsilOrgCode) async {
    if (tehsilOrgCode.isEmpty) return [];

    final db = await lgdDatabase;

    final results = await db.query(
      'Sheet1',
      where: '''
        LOWER("Administrative Office Unit Level") = 'revenue circle'
        AND "Parent Org Unit Code" = ?
      ''',
      whereArgs: [tehsilOrgCode],
      orderBy: '"Administrative Office  Entity Name" ASC',
    );

    if (results.isEmpty) return [];

    final List<Map<String, String>> ris = [];

    for (final d in results) {
      final String name = (d['Administrative Office  Entity Name'] as String?) ?? '';
      final String lgdCode = (d['Administrative Entity Code'] as String?) ?? '';
      final String orgCode = (d['Organization Unit Code'] as String?) ?? '';

      if (name.trim().isEmpty) continue;

      ris.add({
        'name': _cleanName(name),
        'code': orgCode.trim(),           // ✅ Organization Unit Code (for API)
        'org_code': orgCode.trim(),       // ✅ Same, for fetching children (villages)
        'lgd_code': lgdCode.trim(),       // ✅ Keep this for reference
      });
    }

    return ris;
  }

  // ================= VILLAGES =================
  Future<List<Map<String, String>>> getVillages(String riOrgCode) async {
    if (riOrgCode.trim().isEmpty) return [];

    final db = await ricDatabase;

    final results = await db.rawQuery('''
      SELECT
        "Coverage Entity Name",
        "Coverage Entity Code"
      FROM Sheet1
      WHERE TRIM("Organization Unit Code") = ?
        AND "Coverage Entity Type" IS NOT NULL
        AND LOWER("Coverage Entity Type") LIKE '%village%'
      ORDER BY "Coverage Entity Name" ASC
    ''', [riOrgCode.trim()]);

    if (results.isEmpty) return [];

    final List<Map<String, String>> villages = [];

    for (final row in results) {
      final String name = (row['Coverage Entity Name'] as String?) ?? '';
      final String code = (row['Coverage Entity Code'] as String?) ?? '';

      if (name.trim().isEmpty) continue;

      villages.add({
        'name': name.trim(),
        'code': code.trim(),              // ✅ Coverage Entity Code (for API)
        'village_id': code.trim(),        // ✅ Same, kept for compatibility
      });
    }

    return villages;
  }

  // ================= COVERAGE LOCATION =================
  Future<Map<String, String>?> getCoverageLocation(String tehsilName) async {
    if (tehsilName.isEmpty) return null;

    final db = await coverageDatabase;

    print('🔍 DEBUG: Searching coverage for tehsil: "$tehsilName"');

    try {
      // Clean the tehsil name for matching
      final cleanedTehsilName = tehsilName.trim().toLowerCase();

      // Get all rows for matching
      final allRows = await db.query('coverage_location');

      // Try to find a match
      for (final row in allRows) {
        final locationName = row['Coverage Location Name']?.toString() ?? '';
        final locationId = row['Coverage Location ID']?.toString() ?? '';

        // Extract tehsil name from pattern: "Office of the Tehsildar(Tehsil- ANGUL )"
        final patternMatch = RegExp(r'Tehsil-\s*([^)]+)', caseSensitive: false)
            .firstMatch(locationName);

        if (patternMatch != null) {
          final extractedTehsil = patternMatch.group(1)?.trim() ?? '';
          final extractedTehsilLower = extractedTehsil.toLowerCase();

          // Compare tehsil names (case-insensitive)
          if (extractedTehsilLower == cleanedTehsilName) {
            print('✅ DEBUG: Found exact match for "$tehsilName"');

            // ✅ FIX: Remove ".0" from the ID for API
            String cleanId = locationId;
            if (cleanId.endsWith('.0')) {
              cleanId = cleanId.substring(0, cleanId.length - 2);
            }

            print('   - Original ID: $locationId');
            print('   - Clean ID: $cleanId');
            print('   - Location Name: $locationName');

            return {
              'id': cleanId,        // ✅ "1588130" instead of "1588130.0"
              'name': locationName.trim(),
            };
          }
        }
      }

      // If exact pattern match fails, try partial match
      for (final row in allRows) {
        final locationName = row['Coverage Location Name']?.toString() ?? '';
        final locationId = row['Coverage Location ID']?.toString() ?? '';

        if (locationName.toLowerCase().contains(cleanedTehsilName)) {
          print('✅ DEBUG: Found partial match for "$tehsilName"');

          // ✅ FIX: Remove ".0" from the ID for API
          String cleanId = locationId;
          if (cleanId.endsWith('.0')) {
            cleanId = cleanId.substring(0, cleanId.length - 2);
          }

          return {
            'id': cleanId,        // ✅ "1588130" instead of "1588130.0"
            'name': locationName.trim(),
          };
        }
      }

      print('❌ DEBUG: No coverage location found for "$tehsilName"');
      return null;

    } catch (e) {
      print('❌ ERROR in getCoverageLocation: $e');
      return null;
    }
  }
}
