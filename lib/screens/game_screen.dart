import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.title});

  final String title;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<bool>> _grid;
  int _gridSize = 5;
  bool _listenToLightTaps = false;
  bool _showSizeOverlay = true;
  int _randomizerTicks = 0;
  Random rng = Random();

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    _grid = List.generate(_gridSize, (_) => List.filled(_gridSize, false));
  }

  void _toggleLights(int x, int y) {
    setState(() {
      _grid[x][y] = !_grid[x][y];
      if (x > 0) {
        _grid[x - 1][y] = !_grid[x - 1][y];
      }
      if (x < _gridSize - 1) {
        _grid[x + 1][y] = !_grid[x + 1][y];
      }
      if (y > 0) {
        _grid[x][y - 1] = !_grid[x][y - 1];
      }
      if (y < _gridSize - 1) {
        _grid[x][y + 1] = !_grid[x][y + 1];
      }
    });
  }

  void _randomizeGrid(int delayMs) {
    if (delayMs < 0) {
      _listenToLightTaps = true;
      return;
    }
    setState(() {
      _toggleLights(rng.nextInt(_gridSize), rng.nextInt(_gridSize));
    });
    _randomizerTicks++;
    int nextDelayMs;
    if (_randomizerTicks <= _gridSize * 10) {
      nextDelayMs = 100;
    } else {
      nextDelayMs = (_randomizerTicks - _gridSize * 10) * 100;
    }
    if (nextDelayMs > 1000) nextDelayMs = -1;
    Future.delayed(Duration(milliseconds: delayMs), () {
      _randomizeGrid(nextDelayMs);
    });
  }

  void _checkGameOver() {
    if (_grid.every((row) => row.every((cell) => cell == false))) {
      setState(() {
        _listenToLightTaps = false;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _showSizeOverlay = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.blueAccent, Colors.deepPurple],
                center: Alignment.center,
                radius: 0.8,
              ),
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                padding: const EdgeInsets.all(3),
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.width * 0.95,
                child: _buildGrid(),
              ),
            ),
          ),
          // Overlay
          if (_showSizeOverlay) Positioned.fill(child: _buildOverlay()),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_gridSize, (x) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_gridSize, (y) {
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  onTap: () {
                    if (_listenToLightTaps) {
                      _toggleLights(x, y);
                      _checkGameOver();
                    } else {
                      null;
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: _grid[x][y]
                          ? RadialGradient(
                              colors: [Colors.yellowAccent, Colors.orange],
                              center: Alignment.center,
                              radius: 0.8,
                            )
                          : null,
                      color: _grid[x][y] ? null : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _grid[x][y]
                          ? [
                              BoxShadow(
                                color: Colors.orange.withAlpha(100),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Gridgröße wählen',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          Slider(
            value: _gridSize.toDouble(),
            min: 3,
            max: 8,
            divisions: 5,
            label: '$_gridSize x $_gridSize',
            onChanged: (value) {
              setState(() {
                _gridSize = value.toInt();
                _initializeGrid();
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showSizeOverlay = false;
              });
              _randomizerTicks = 0;
              _randomizeGrid(100);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
