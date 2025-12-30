import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edistrict_odisha/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// This test file allows for independent verification of the DatabaseHelper methods.
// To run, open this file and click the green 'play' icon next to the main() function.
// The results of each database query will be printed to the Run console.

void main() {
  // Required for sqflite to work in a desktop test environment (Windows/Linux/Mac)
  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  test('Test getDistricts() - Fetches all districts', () async {
    final dbHelper = DatabaseHelper.instance;
    final districts = await dbHelper.getDistricts();

    debugPrint('--- RESULTS FOR getDistricts() ---');
    expect(districts, isNotEmpty, reason: 'Expected to fetch districts, but got an empty list.');
    for (var district in districts) {
      debugPrint('District: ${district['name']}, Org Code: ${district['org_code']}');
    }
    debugPrint('--- END OF getDistricts() ---\n');
  });

  test('Test getTehsils() - Fetches tehsils for a specific district', () async {
    final dbHelper = DatabaseHelper.instance;
    const String sampleDistrictOrgCode = '4'; // Org Code for Khordha based on LGD DB

    final tehsils = await dbHelper.getTehsils(sampleDistrictOrgCode);

    debugPrint('--- RESULTS FOR getTehsils(org_code: $sampleDistrictOrgCode) ---');
    expect(tehsils, isNotEmpty, reason: 'Expected to fetch tehsils for district org_code=$sampleDistrictOrgCode');
    for (var tehsil in tehsils) {
      debugPrint('Tehsil: ${tehsil['name']}, Org Code: ${tehsil['org_code']}');
    }
    debugPrint('--- END OF getTehsils() ---\n');
  });

  test('Test getRIs() - Fetches RIs for a specific tehsil', () async {
    final dbHelper = DatabaseHelper.instance;
    const String sampleTehsilOrgCode = '590'; // Org Code for Bhubaneswar tehsil

    final ris = await dbHelper.getRIs(sampleTehsilOrgCode);

    debugPrint('--- RESULTS FOR getRIs(org_code: $sampleTehsilOrgCode) ---');
    expect(ris, isNotEmpty, reason: 'Expected to fetch RIs for tehsil org_code=$sampleTehsilOrgCode');
    for (var ri in ris) {
      debugPrint('RI: ${ri['name']}, Org Code: ${ri['org_code']}');
    }
    debugPrint('--- END OF getRIs() ---\n');
  });

  test('Test getVillages() - Fetches villages for a specific RI', () async {
    final dbHelper = DatabaseHelper.instance;
    // Org Code for Bhubaneswar Circle-I (from ric_master)
    const String sampleRiOrgCode = '12130101001';

    final villages = await dbHelper.getVillages(sampleRiOrgCode);

    debugPrint('--- RESULTS FOR getVillages(org_code: $sampleRiOrgCode) ---');
    expect(villages, isNotEmpty, reason: 'Expected to fetch villages for RI org_code=$sampleRiOrgCode');
    for (var village in villages) {
      debugPrint('Village: ${village['name']}, Village ID: ${village['village_id']}');
    }
    debugPrint('--- END OF getVillages() ---\n');
  });

  test('Test getCoverageLocation() - Fetches apply-to office', () async {
    final dbHelper = DatabaseHelper.instance;
    const String sampleTehsilName = 'Bhubaneswar';

    final location = await dbHelper.getCoverageLocation(sampleTehsilName);

    debugPrint('--- RESULTS FOR getCoverageLocation(tehsil: $sampleTehsilName) ---');
    expect(location, isNotNull, reason: 'Coverage location for $sampleTehsilName should not be null');
    debugPrint('Coverage Location: $location');
    debugPrint('--- END OF getCoverageLocation() ---\n');
  });
}
