import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lights_out/utils/app_constants.dart';
import 'package:lights_out/widgets/game_setup_overlay.dart';

import '../Widgets/light_tile.dart';
import '../widgets/game_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.title});

  final String title;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showSizeOverlay = true;
  int _gridSize = 5;
  late List<List<List<bool>>> _history;
  int _frameIndex = 0;
  bool _listenToLightTaps = false;
  final Random _rng = Random();
  int _randomizerTicks = 0;
  late double _hue;

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

  Future<void> _handleGridSizeChanged(int value) async {
    setState(() {
      _gridSize = value;
    });
    await _setupNewGame();
  }

  Future<void> _handleStart() async {
    if (mounted) {
      setState(() {
        _showSizeOverlay = false;
      });
    }
    await _setupNewGame(start: true);
  }

  Future<void> _setupNewGame({bool start = false}) async {
    _history = [List.generate(_gridSize, (_) => List.filled(_gridSize, false))];
    _frameIndex = 0;
    _randomizerTicks = 0;
    _hue = _rng.nextDouble() * 360;
    if (start) {
      await _randomizeGrid(100);
      _listenToLightTaps = true;
    }
  }

  Future<void> _randomizeGrid(int delayMs) async {
    // Toggle random tile
    setState(() {
      final x = _rng.nextInt(_gridSize);
      final y = _rng.nextInt(_gridSize);
      _toggleCell(_grid, x, y);
      _toggleCell(_grid, x - 1, y);
      _toggleCell(_grid, x + 1, y);
      _toggleCell(_grid, x, y - 1);
      _toggleCell(_grid, x, y + 1);
    });
    // Recursive logic
    _randomizerTicks++;
    int nextDelayMs;
    if (_randomizerTicks <= _gridSize * 10) {
      nextDelayMs = 100;
    } else {
      // A slowly fading duration grow
      nextDelayMs = (_randomizerTicks - _gridSize * 10) * (100 - _gridSize * 10);
    }
    // Recursive with end condition
    if (nextDelayMs <= 1000) {
      await Future.delayed(Duration(milliseconds: delayMs));
      await _randomizeGrid(nextDelayMs);
    }
  }

  void _toggleLights(int x, int y) {
    if (_frameIndex < _history.length - 1) {
      _history = _history.sublist(0, _frameIndex + 1);
    }
    _history.add(_deepCopy(_grid));
    _frameIndex++;
    _toggleCell(_grid, x, y);
    _toggleCell(_grid, x - 1, y);
    _toggleCell(_grid, x + 1, y);
    _toggleCell(_grid, x, y - 1);
    _toggleCell(_grid, x, y + 1);
    setState(() {});
  }

  void _toggleCell(List<List<bool>> grid, int x, int y) {
    if (x < 0 || x >= _gridSize || y < 0 || y >= _gridSize) return;
    grid[x][y] = !grid[x][y];
    _hue = (_hue + 2) % 360;
  }

  void _goBack() {
    if (_frameIndex > 0) setState(() => _frameIndex--);
  }

  void _goForward() {
    if (_frameIndex < _history.length - 1) setState(() => _frameIndex++);
  }

  Future<void> _gameOverCheck() async {
    if (_grid.every((row) => row.every((cell) => cell == false))) {
      setState(() {
        _listenToLightTaps = false;
      });
      // Play a final done animation
      await Future.delayed(Duration(milliseconds: 1000));
      for (int i = 0; i < (_gridSize / 2).ceil() + 1; i++) {
        if (i > 0) {
          _switchLightCircle(false, i - 1);
        }
        _switchLightCircle(true, i);
        await Future.delayed(Duration(milliseconds: 1000));
      }
      _switchLightCircle(false, (_gridSize / 2).ceil());
      _endGame();
    }
  }

  _switchLightCircle(bool glowing, int offset) {
    setState(() {
      for (int i = offset; i < _gridSize - offset; i++) {
        _grid[offset][i] = glowing;
        _grid[i][offset] = glowing;
        if (offset != _gridSize - offset) {
          _grid[_gridSize - 1 - offset][i] = glowing;
          _grid[i][_gridSize - 1 - offset] = glowing;
        }
      }
    });
  }

  void _endGame() {
    setState(() {
      _randomizerTicks = 1000;
      _showSizeOverlay = true;
      _listenToLightTaps = false;
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
          if (_showSizeOverlay)
            Positioned.fill(
              child: GameSetupOverlay(
                gridSize: _gridSize,
                onGridSizeChanged: _handleGridSizeChanged,
                onStart: _handleStart,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameFrame() {
    return Column(
      children: [
        const Spacer(),
        GameButton(text: 'Aufgeben', onPressed: _endGame),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GameButton(icon: Icons.arrow_back, onPressed: _goBack),
            const SizedBox(width: 32),
            GameButton(icon: Icons.arrow_forward, onPressed: _goForward),
          ],
        ),
        const Spacer(),
      ],
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
                child: LightTile(
                  isOn: _grid[x][y],
                  onTap: () {
                    if (_listenToLightTaps) {
                      _toggleLights(x, y);
                      _gameOverCheck();
                    }
                  },
                  lightColor: _getLightColor,
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
