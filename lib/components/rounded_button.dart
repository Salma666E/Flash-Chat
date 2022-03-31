import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {required this.title,
      this.icon,
      required this.colour,
      required this.onPressed});

  final Color colour;
  final icon;
  final String title;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 5.0,
        color: colour,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          height: 42.0,
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(icon,
                        color: Colors.grey[700],
                        fit: BoxFit.fitHeight,
                        height: 32,
                        width: 32),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
