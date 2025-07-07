import 'package:flutter/material.dart';

class LightTile extends StatelessWidget {
  final bool isOn;
  final VoidCallback onTap;
  final Color lightColor;

  const LightTile({required this.isOn, required this.onTap, required this.lightColor, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          boxShadow: isOn
              ? [BoxShadow(color: lightColor.withAlpha(128), blurRadius: 24, spreadRadius: 1)]
              : [
                  BoxShadow(
                    color: Colors.grey.shade800.withAlpha(128),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
          gradient: isOn
              ? RadialGradient(
                  colors: [lightColor, lightColor.withAlpha(100)],
                  center: Alignment.center,
                  radius: 0.8,
                )
              : RadialGradient(
                  colors: [lightColor.withAlpha(64), lightColor.withAlpha(32)],
                  center: Alignment.center,
                  radius: 0.8,
                ),
          color: isOn ? null : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
