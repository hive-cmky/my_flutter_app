// ============================================================================
// CONSTANTS - App-wide constants
// Contains: Colors, Text Styles, Dropdown Options, Size Constants
// ============================================================================

import 'package:flutter/material.dart';

class AppConstants {
  // ========== COLORS ==========
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF64B5F6);
  static final Color sectionHeaderColor = Colors.blue[100]!;
  static final Color scaffoldBackgroundColor = Colors.grey[50]!;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;

  // ========== TEXT STYLES ==========
  static const TextStyle sectionHeaderStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static const TextStyle requiredIndicatorStyle = TextStyle(
    color: Colors.red,
    fontSize: 14,
  );

  // ========== DROPDOWN OPTIONS ==========
  static const List<String> salutations = ['Shri', 'Smt', 'Miss'];
  static const List<String> genders = ['Male', 'Female', 'Transgender'];
  static const List<String> maritalStatuses = ['Married', 'Unmarried', 'Widow'];
  static const List<String> yesNoOptions = ['Yes', 'No'];
  static const List<String> states = ['ODISHA'];

  // ========== FILE SIZE LIMITS ==========
  static const double photoMinSizeKB = 20;
  static const double photoMaxSizeKB = 250;
  static const double documentMaxSizeKB = 512;

  // ========== FILE EXTENSIONS ==========
  static const List<String> allowedPhotoExtensions = ['jpg', 'jpeg'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'jpg', 'jpeg'];

  // ========== VALIDATION LENGTHS ==========
  static const int mobileNumberLength = 10;
  static const int aadhaarNumberLength = 12;
  static const int pinCodeLength = 6;

  // ========== SPACING ==========
  static const double defaultPadding = 16.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;

  // ========== BORDER RADIUS ==========
  static const double defaultBorderRadius = 8.0;

  // ========== BUTTON HEIGHT ==========
  static const double buttonHeight = 50.0;

  // ========== ERROR MESSAGES ==========
  static const String requiredFieldError = 'This field is required';
  static const String invalidEmailError = 'Enter a valid email address';
  static const String invalidMobileError = 'Mobile number must be 10 digits';
  static const String invalidAadhaarError = 'Aadhaar must be 12 digits';
  static const String invalidPinError = 'PIN must be 6 digits';
  static const String onlyLettersError = 'Must contain only letters';
  static const String photoRequiredError = 'Please upload your photo';
  static const String agreementRequiredError = 'Please agree to the declaration';

  // ========== SUCCESS MESSAGES ==========
  static const String formSubmittedSuccess = 'Application submitted successfully!';

  // ========== DECLARATION TEXT ==========
  static const String declarationText = '''I do hereby declare that the information given by me in this application form is true to the best of my knowledge and I have not suppressed / misrepresented any fact. That, I am solely responsible for the accuracy of the declaration and information furnished and shall be liable for action under section 199, 200 and 420 of Indian Penal Code and other relevant laws/ rules in case of furnishing wrong declaration and information. Also, I am well aware of the fact that the certificate shall be summarily cancelled and all the benefits availed by me shall be summarily withdrawn in case of furnishing wrong declaration and information.''';
}
