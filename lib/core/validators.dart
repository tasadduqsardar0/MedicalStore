class AppValidators {
  static String? requiredField(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? positiveNumber(String? value, [String message = 'Enter a valid number greater than 0']) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final numVal = num.tryParse(value.trim());
    if (numVal == null || numVal <= 0) {
      return message;
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, [String message = 'Enter a valid number (0 or more)']) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final numVal = num.tryParse(value.trim());
    if (numVal == null || numVal < 0) {
      return message;
    }
    return null;
  }

  static String? positiveInteger(String? value, [String message = 'Enter a whole number greater than 0']) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final intVal = int.tryParse(value.trim());
    if (intVal == null || intVal <= 0) {
      return message;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone can be optional unless required
    }
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.length < 10) {
      return 'Enter a valid phone number (e.g. 03001234567)';
    }
    return null;
  }
}

