import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    String formattedValue;
    if (digitsOnly.length <= 2) {
      formattedValue = digitsOnly;
    } else {
      formattedValue = '${digitsOnly.substring(0, digitsOnly.length - 2)}.${digitsOnly.substring(digitsOnly.length - 2)}';
    }

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
