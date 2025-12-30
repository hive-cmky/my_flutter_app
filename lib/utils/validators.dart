class FormValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateOnlyLetters(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    final nameRegExp = RegExp(r"^[a-zA-Z\s]+$");
    if (!nameRegExp.hasMatch(value)) {
      return '$fieldName should contain only letters';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Age is required';
    final age = int.tryParse(value);
    if (age == null || age <= 0 || age > 120) {
      return 'Enter a valid age (1-120)';
    }
    return null;
  }

  static String? validateMonths(String? value) {
    if (value == null || value.isEmpty) return null;
    final months = int.tryParse(value);
    if (months == null || months < 0 || months > 11) {
      return 'Months must be 0-11';
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return 'Mobile is required';
    if (value.length != 10) return 'Mobile must be 10 digits';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validateAadhaar(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length != 12) return 'Aadhaar must be 12 digits';
    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length != 6) return 'PIN must be 6 digits';
    return null;
  }
}
