import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
  const RoundedTextField(
      {required this.hint,
      this.obscureText = false,
      required this.validator,
      this.myKeyboardType = TextInputType.text,
      required this.onChangedFunction,
      Key? key})
      : super(key: key);
  final Function(String) onChangedFunction;
  final TextInputType myKeyboardType;
  final bool obscureText;
  final String hint;
  final validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: myKeyboardType,
      textAlign: TextAlign.left,
      onChanged: onChangedFunction,
      obscureText: obscureText,
      validator: validator,
      decoration:
          kTextFieldDecoration.copyWith(hintText: 'Enter here your $hint'),
    );
  }
}
