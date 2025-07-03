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
  bool _isToggleEnabled = false;
  bool _showSizeOverlay = true;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    _grid = List.generate(_gridSize, (_) => List.filled(_gridSize, false));
  }

  void _toggleLights(int x, int y) {
    if (!_isToggleEnabled) return;
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
                color: Colors.black,
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
                  onTap: () => _toggleLights(x, y),
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
                _isToggleEnabled = true;
                _showSizeOverlay = false;
              });
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
