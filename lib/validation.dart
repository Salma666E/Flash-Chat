class Validation {
  static String? validateName(String? value) {
    String? _message;

    if (value!.isEmpty)
      _message = 'Please enter your name is required!';
    else if (value.length < 3) _message = 'Name must be more than 2 characters';

    return _message;
  }

  static String? validateEmail(String? value) {
    String? _message;

    String _emailPattern = r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.com$';
    // r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(_emailPattern);

    if (value!.isEmpty)
      _message = 'Your email address is required!';
    else if (!regex.hasMatch(value.trim()))
      _message = 'Please provide a valid email address!';

    return _message;
  }

  static String? validatePassword(String? value) {
    String? _message;

    if (value!.isEmpty)
      _message = 'Your password is required!';
    else if (value.length < 6)
      _message = 'Your password must be at least 6 characters!';
    else if (value.length > 32)
      _message = 'Your password must be at most 32 characters!';

    return _message;
  }
}
