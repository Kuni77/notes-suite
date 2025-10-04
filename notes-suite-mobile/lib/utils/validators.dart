class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Title validation (for notes)
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }

    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }

    if (value.length > 200) {
      return 'Title is too long (max 200 characters)';
    }

    return null;
  }

  // Content validation (for notes)
  static String? validateContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Content is required';
    }

    if (value.length > 50000) {
      return 'Content is too long (max 50,000 characters)';
    }

    return null;
  }
}