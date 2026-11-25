class Validators {
  Validators._();

  static String? notEmpty(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    final error = notEmpty(value, field: 'Email');
    if (error != null) return error;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final error = notEmpty(value, field: 'Password');
    if (error != null) return error;
    if (value!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // Bangladeshi mobile number, e.g. 01754658781
  static String? mobile(String? value) {
    final error = notEmpty(value, field: 'Mobile number');
    if (error != null) return error;
    if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(value!.trim())) {
      return 'Enter a valid 11 digit mobile number';
    }
    return null;
  }
}