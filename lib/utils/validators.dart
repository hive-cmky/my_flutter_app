class FormValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    value = value.trim();
    if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Mobile number must contain only digits';
    }
    if (!RegExp(r'^[6-9]').hasMatch(value)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    value = value.trim();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    value = value.trim().replaceAll(' ', '');
    if (value.length != 12) {
      return 'Aadhaar must be 12 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Aadhaar must contain only digits';
    }
    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    value = value.trim();
    if (value.length != 6) {
      return 'PIN must be 6 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'PIN must contain only digits';
    }
    return null;
  }

  static String? validateOnlyLetters(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }
    value = value.trim();
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return '$fieldName must contain only letters';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    value = value.trim();
    final ageNum = int.tryParse(value);
    if (ageNum == null) {
      return 'Age must be a number';
    }
    if (ageNum < 1 || ageNum > 120) {
      return 'Age must be between 1 and 120';
    }
    return null;
  }
}