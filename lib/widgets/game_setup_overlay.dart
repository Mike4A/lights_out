import 'package:flutter/material.dart';

class GameSetupOverlay extends StatelessWidget {
  final int gridSize;
  final ValueChanged<int> onGridSizeChanged;
  final VoidCallback onStart;

  const GameSetupOverlay({
    super.key,
    required this.gridSize,
    required this.onGridSizeChanged,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Gridgröße', style: TextStyle(color: Colors.white, fontSize: 24)),
          Slider(
            value: gridSize.toDouble(),
            min: 3,
            max: 8,
            divisions: 5,
            label: '$gridSize x $gridSize',
            onChanged: (v) => onGridSizeChanged(v.toInt()),
          ),
          ElevatedButton(
            onPressed: onStart,
            child: const Text('Start', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}