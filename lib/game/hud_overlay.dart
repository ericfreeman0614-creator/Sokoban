import 'package:flutter/material.dart';
import 'package:sokoban_game/core/enums.dart';
import 'package:sokoban_game/game/sokoban_game.dart';
import 'package:sokoban_game/levels/level_data.dart';

class HudOverlay extends StatelessWidget {
  final SokobanGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Top Layer: Level Text
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<String>(
                valueListenable: game.levelDescriptionNotifier,
                builder: (context, description, child) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Layer: D-Pad Controls
          Positioned(
            bottom: 40,
            right: 40,
            child: _buildDPad(),
          ),

          // Reset Button
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
              onPressed: () => game.loadLevel(game.currentLevelIndex),
              tooltip: 'Reset Level',
            ),
          ),

          // Level Selector Button
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.list, color: Colors.white, size: 30),
              onPressed: () => _showLevelSelectDialog(context),
              tooltip: 'Select Level',
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Level'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: LevelData.levels.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Level ${index + 1}'),
                  onTap: () {
                    game.loadLevel(index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDPad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildArrowButton(Icons.arrow_upward, Direction.up),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildArrowButton(Icons.arrow_back, Direction.left),
            const SizedBox(width: 60), // Space for Down button implicitly
            _buildArrowButton(Icons.arrow_forward, Direction.right),
          ],
        ),
        _buildArrowButton(Icons.arrow_downward, Direction.down),
      ],
    );
  }

  Widget _buildArrowButton(IconData icon, Direction dir) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 32,
        onPressed: () => game.handleInput(dir),
      ),
    );
  }
}
