import 'package:flutter/material.dart';

class Buttons {
  static Widget primaryButton({
    required String text,
    required void Function() onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 20,
        ),
        textStyle: const TextStyle(
          fontSize: 20,
        ),
        minimumSize: const Size(double.maxFinite, 50),
      ),
      child: Text(text),
    );
  }
}
