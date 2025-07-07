import 'package:flutter/material.dart';

class GameButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final IconData? icon;

  const GameButton({
    super.key, required this.onPressed, this.text, this.icon
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 20),
      ),
      child: text != null ? Text(text!) : Icon(icon, size: 28),
    );
  }
}