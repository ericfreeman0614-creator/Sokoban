
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; // For Colors
import 'package:sokoban_game/core/game_controller.dart';
import 'package:sokoban_game/core/enums.dart';
import 'package:sokoban_game/levels/level_data.dart';
import 'package:flame/events.dart'; // For TapCallbacks
import 'package:sokoban_game/effects/victory_effect.dart';

class SokobanGame extends FlameGame with KeyboardEvents, HasTappables { 
  // HasTappables is deprecated in newer flame, use TapCallbacks logic on components or HasTappableComponents
  // Actually in 1.7.3 it might be HasTappablesBridge or similar, or just TapCallbacks mixin on components + HasTappables on Game?
  // Let's check Flame versions. standard is TapCallbacks in recent versions.
  // We'll use HUD buttons which are PositionComponents with TapCallbacks.
  
  final GameController controller = GameController();
  int currentLevelIndex = 0;
  late final CameraComponent cameraComponent;
  late final World worldComponent;
  
  final double tileSize = 64.0;
  Vector2 gridOffset = Vector2.zero();
  
  // Component groups
  final Component staticLayer = Component();
  final Component dynamicLayer = Component();

  @override
  Color backgroundColor() => const Color(0xFF222222);

  @override
  Future<void> onLoad() async {
    // Setup World & Camera
    worldComponent = World();
    cameraComponent = CameraComponent(world: worldComponent);
    cameraComponent.viewfinder.anchor = Anchor.center;
    
    add(worldComponent);
    add(cameraComponent);
    
    worldComponent.add(staticLayer);
    worldComponent.add(dynamicLayer);
    
    // Add HUD
    add(HudButtonComponent(
      button: CircleComponent(
        radius: 30, 
        paint: Paint()..color = Colors.white.withOpacity(0.5)
      ),
      margin: const EdgeInsets.only(right: 40, bottom: 60),
      onPressed: () => _handleInput(Direction.right),
    ));
    
    add(HudButtonComponent(
      button: CircleComponent(
        radius: 30, 
        paint: Paint()..color = Colors.white.withOpacity(0.5)
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 60),
      onPressed: () => _handleInput(Direction.left),
    ));

    add(HudButtonComponent(
      button: CircleComponent(
        radius: 30, 
        paint: Paint()..color = Colors.white.withOpacity(0.5)
      ),
      margin: const EdgeInsets.only(bottom: 20, right: 100), // Approximate center-ish
      // We need more precise layout for D-Pad but this is a start.
      // better to align relative to screen edges.
      // Let's mostly rely on keyboard for now but add simple buttons for "Reset" or "Next".
      onPressed: () => _handleInput(Direction.down),
    ));
    
     add(HudButtonComponent(
      button: CircleComponent(
        radius: 30, 
        paint: Paint()..color = Colors.white.withOpacity(0.5)
      ),
      margin: const EdgeInsets.only(top: 40, right: 40), // Top Right? No.
      // D-Pad logic is complex with just margins.
      // Let's implement TapCallbacks on the game background? No.
      onPressed: () => _handleInput(Direction.up),
    ));


    loadLevel(currentLevelIndex);
  }

  void loadLevel(int index) {
    if (index >= LevelData.levels.length) {
      print("All levels completed!");
      return;
    }
    
    currentLevelIndex = index;
    controller.loadLevel(LevelData.levels[index]);
    
    _buildLevel();
  }

  void _buildLevel() {
    staticLayer.removeWhere((_) => true);
    dynamicLayer.removeWhere((_) => true);

    int rows = controller.rows;
    int cols = controller.cols;
    
    double totalWidth = cols * tileSize;
    double totalHeight = rows * tileSize;
    
    gridOffset = Vector2(-totalWidth / 2, -totalHeight / 2);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        Vector2 pos = gridOffset + Vector2(c * tileSize, r * tileSize);
        
        MapElement el = controller.grid[r][c];
        
        if (el == MapElement.wall) {
          staticLayer.add(RectangleComponent(
            position: pos,
            size: Vector2.all(tileSize),
            paint: Paint()..color = Colors.grey[800]!,
          ));
        } else {
          // Floor
          staticLayer.add(RectangleComponent(
            position: pos,
            size: Vector2.all(tileSize),
            paint: Paint()..color = const Color(0xFF333333), // Darker floor
          ));
          
          if (el == MapElement.target || 
              el == MapElement.boxOnTarget || 
              el == MapElement.playerOnTarget) {
            staticLayer.add(CircleComponent(
              radius: tileSize * 0.15,
              position: pos + Vector2.all(tileSize * 0.35),
              paint: Paint()..color = Colors.redAccent.withOpacity(0.6),
            ));
          }
        }
      }
    }
    
    _updateDynamicLayer();
  }

  void _updateDynamicLayer() {
    dynamicLayer.removeWhere((_) => true);
    
    for (int r = 0; r < controller.rows; r++) {
      for (int c = 0; c < controller.cols; c++) {
         Vector2 pos = gridOffset + Vector2(c * tileSize, r * tileSize);
         MapElement el = controller.grid[r][c];

         if (el == MapElement.player || el == MapElement.playerOnTarget) {
           dynamicLayer.add(RectangleComponent(
             position: pos + Vector2.all(tileSize * 0.1),
             size: Vector2.all(tileSize * 0.8),
             paint: Paint()..color = Colors.blueAccent,
           ));
         } else if (el == MapElement.box) {
           dynamicLayer.add(RectangleComponent(
             position: pos + Vector2.all(tileSize * 0.05),
             size: Vector2.all(tileSize * 0.9),
             paint: Paint()..color = Colors.orange,
           ));
         } else if (el == MapElement.boxOnTarget) {
           dynamicLayer.add(RectangleComponent(
             position: pos + Vector2.all(tileSize * 0.05),
             size: Vector2.all(tileSize * 0.9),
             paint: Paint()..color = Colors.greenAccent, 
           ));
         }
      }
    }
  }


  void _handleInput(Direction dir) {
    if (controller.isLevelComplete) {
       // Transition to next level
       loadLevel(currentLevelIndex + 1);
       return;
    }

    bool moved = controller.movePlayer(dir);
    if (moved) {
      _updateDynamicLayer();
      if (controller.isLevelComplete) {
        // Check if it was the last level
        if (currentLevelIndex == LevelData.levels.length - 1) {
           // Grand Victory
           overlays.add('Victory');
           worldComponent.add(VictoryEffect()); // Add visuals
        } else {
           // Maybe mini-fanfare?
           print("Level Complete!");
        }
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) _handleInput(Direction.up);
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) _handleInput(Direction.down);
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _handleInput(Direction.left);
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) _handleInput(Direction.right);
      
      // Cheats for debug
      if (event.logicalKey == LogicalKeyboardKey.keyN) loadLevel(currentLevelIndex + 1);
      if (event.logicalKey == LogicalKeyboardKey.keyR) loadLevel(currentLevelIndex);
    }
    return KeyEventResult.handled;
  }
}
