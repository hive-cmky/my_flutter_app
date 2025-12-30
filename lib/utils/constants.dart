import 'package:flutter/material.dart';

class AppConstants {
  // ========== API CONFIGURATION ==========
  static const String apiBaseUrl = 'http://10.98.73.80:8080';
  static const String submitEndpoint = '$apiBaseUrl/api/submit';

  // ========== DROPDOWN OPTIONS ==========
  static const List<String> salutations = ['Shri', 'Smt', 'Miss'];
  static const List<String> genders = ['Male', 'Female', 'Transgender'];
  static const List<String> maritalStatuses = ['Married', 'Unmarried', 'Widow'];
  static const List<String> yesNoOptions = ['Yes', 'No'];
  static const List<String> states = ['ODISHA'];

  static const Map<String, String> enclosureDocuments = {
    'Ration Card': '173',
    'Electricity Bill': '177',
    'COPY OF ROR': '4217',
    'EPIC/Aadhaar Card': '4996',
    'Landline Telephone Bill': '5023',
    'Water Connection Bill': '5024',
    'Holding tax receipt': '5025',
    'Lease agreement with house owner': '5026',
    'Certificate from the employer': '5027',
    'First page of Bank Passbook': '5028',
    'Extract of latest Voter list': '5029',
    'NREGS job card': '5031',
    'Other': '240',
  };

  // ========== FILE SIZE LIMITS ==========
  static const double photoMinSizeKB = 5;
  static const double photoMaxSizeKB = 200; 
  static const double documentMaxSizeKB = 512;

  static const List<String> allowedPhotoExtensions = ['jpg', 'jpeg'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'jpg', 'jpeg'];

  static const String declarationText = '''I do hereby declare that the information given by me in this application form is true to the best of my knowledge and I have not suppressed / misrepresented any fact. That, I am solely responsible for the accuracy of the declaration and information furnished and shall be liable for action under section 199, 200 and 420 of Indian Penal Code and other relevant laws/ rules in case of furnishing wrong declaration and information. Also, I am well aware of the fact that the certificate shall be summarily cancelled and all the benefits availed by me shall be summarily withdrawn in case of furnishing wrong declaration and information.''';
}
