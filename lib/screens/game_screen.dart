import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lights_out/utils/app_constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.title});

  final String title;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _gridSize = 5;
  bool _listenToLightTaps = false;
  bool _showSizeOverlay = true;
  int _randomizerTicks = 0;
  final Random _rng = Random();
  late double _hue;
  late List<List<List<bool>>> _history;
  int _frameIndex = 0;

  Color get _getLightColor => HSLColor.fromAHSL(
    1,
    _hue,
    AppConstants.lightSaturation,
    AppConstants.lightLuminosity,
  ).toColor();

  Color get _getBackgroundColor => HSLColor.fromAHSL(
    1,
    (_hue + 180) % 360,
    AppConstants.lightSaturation,
    AppConstants.lightLuminosity,
  ).toColor();

  List<List<bool>> get _grid => _history[_frameIndex];

  List<List<bool>> _deepCopy(List<List<bool>> source) =>
      source.map((row) => List<bool>.from(row)).toList();

  @override
  void initState() {
    super.initState();
    _setupNewGame();
  }

  void _setupNewGame({bool randomized = false}) {
    final empty = List.generate(_gridSize, (_) => List.filled(_gridSize, false));
    _history = [_deepCopy(empty)];
    _hue = _rng.nextDouble() * 360;
    _frameIndex = 0;
    _randomizerTicks = 0;
    if (randomized) {
      _randomizeGrid(100);
    }
  }

  void _endGame() {
    setState(() {
      _randomizerTicks = 1000;
      _showSizeOverlay = true;
      _listenToLightTaps = false;
    });
  }

  void _handleGameOver() {
    if (_grid.every((row) => row.every((cell) => cell == false))) {
      setState(() {
        _listenToLightTaps = false;
      });
      Future.delayed(Duration(seconds: 3), () => _endGame());
    }
  }

  void _toggleCell(List<List<bool>> grid, int x, int y) {
    if (x < 0 || x >= _gridSize || y < 0 || y >= _gridSize) return;
    grid[x][y] = !grid[x][y];
  }

  void _toggleLights(int x, int y) {
    if (_frameIndex < _history.length - 1) {
      _history = _history.sublist(0, _frameIndex + 1);
    }
    final newGrid = _deepCopy(_grid);
    _hue = (_hue + 10) % 360;
    _toggleCell(newGrid, x, y);
    _toggleCell(newGrid, x - 1, y);
    _toggleCell(newGrid, x + 1, y);
    _toggleCell(newGrid, x, y - 1);
    _toggleCell(newGrid, x, y + 1);
    setState(() {
      _history.add(newGrid);
      _frameIndex++;
    });
  }

  void _goBack() {
    if (_frameIndex > 0) {
      setState(() => _frameIndex--);
    }
  }

  void _goForward() {
    if (_frameIndex < _history.length - 1) {
      setState(() => _frameIndex++);
    }
  }

  void _randomizeGrid(int delayMs) {
    if (delayMs < 0) {
      _listenToLightTaps = true;
      return;
    }
    setState(() {
      final x = _rng.nextInt(_gridSize);
      final y = _rng.nextInt(_gridSize);
      _toggleCell(_grid, x, y);
      _toggleCell(_grid, x - 1, y);
      _toggleCell(_grid, x + 1, y);
      _toggleCell(_grid, x, y - 1);
      _toggleCell(_grid, x, y + 1);
    });
    _randomizerTicks++;
    int nextDelayMs;
    if (_randomizerTicks <= _gridSize * 10) {
      nextDelayMs = 100;
    } else {
      nextDelayMs = (_randomizerTicks - _gridSize * 10) * (100 - _gridSize * 10);
    }
    if (nextDelayMs > 1000) nextDelayMs = -1;
    Future.delayed(Duration(milliseconds: delayMs), () {
      _randomizeGrid(nextDelayMs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [_getLightColor, _getBackgroundColor],
                center: Alignment.center,
                radius: 0.95,
              ),
            ),
            child: _buildGameFrame(),
          ),
          if (_showSizeOverlay) Positioned.fill(child: _buildOverlay()),
        ],
      ),
    );
  }

  Widget _buildGameFrame() {
    return Column(
      children: [
        const Spacer(),
        _buildGiveUpButton(),
        const SizedBox(height: 32),
        AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              padding: const EdgeInsets.all(3),
              child: _buildGrid(),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildNavButtons(),
        const Spacer(),
      ],
    );
  }

  Widget _buildGiveUpButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: _endGame,
      child: const Text('Aufgeben'),
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
                      _handleGameOver();
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
                              colors: [_getLightColor, _getLightColor.withAlpha(100)],
                              center: Alignment.center,
                              radius: 0.8,
                            )
                          : RadialGradient(
                              colors: [_getLightColor.withAlpha(64), _getLightColor.withAlpha(32)],
                              center: Alignment.center,
                              radius: 0.8,
                            ),
                      color: _grid[x][y] ? null : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _grid[x][y]
                          ? [
                              BoxShadow(
                                color: _getLightColor.withAlpha(32),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
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

  Widget _buildNavButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _goBack,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black54,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 20),
          ),
          child: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 32),
        ElevatedButton(
          onPressed: _goForward,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black54,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 20),
          ),
          child: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.black.withAlpha(200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Gridgröße', style: TextStyle(color: Colors.white, fontSize: 24)),
          Slider(
            value: _gridSize.toDouble(),
            min: 3,
            max: 8,
            divisions: 5,
            label: '$_gridSize x $_gridSize',
            onChanged: (value) {
              setState(() {
                _gridSize = value.toInt();
                _setupNewGame();
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showSizeOverlay = false;
              });
              _setupNewGame(randomized: true);
            },
            child: const Text('Start', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
