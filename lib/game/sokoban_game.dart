import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart'; // For World and CameraComponent in 1.7.3
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; // For Colors
import 'package:sokoban_game/core/game_controller.dart';
import 'package:sokoban_game/core/enums.dart';
import 'package:sokoban_game/levels/level_data.dart';
// import 'package:flame/events.dart'; // For TapCallbacks // Unnecessary import
import 'package:sokoban_game/effects/victory_effect.dart';

class SokobanGame extends FlameGame with KeyboardEvents {
  // HasTappables is deprecated in newer flame, use TapCallbacks logic on components or HasTappableComponents
  // actually in 1.7.3 it might be HasTappablesBridge or similar, or just TapCallbacks mixin on components + HasTappables on Game?
  // Let's check Flame versions. standard is TapCallbacks in recent versions.
  // We'll use HUD buttons which are PositionComponents with TapCallbacks.

  final GameController controller = GameController();
  int currentLevelIndex = 0;
  late final CameraComponent cameraComponent;
  late final World worldComponent;

  // Notifiers for HUD
  final ValueNotifier<String> levelDescriptionNotifier = ValueNotifier("");

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

    // HUD is now handled by Flutter Overlay

    loadLevel(currentLevelIndex);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _zoomToFit();
  }

  void loadLevel(int index) {
    if (index >= LevelData.levels.length) {
      debugPrint("All levels completed!");
      return;
    }

    currentLevelIndex = index;
    Level level = LevelData.levels[index];

    controller.loadLevel(level.grid);
    levelDescriptionNotifier.value = level.description;

    _buildLevel();
    _zoomToFit();
  }

  void _zoomToFit() {
    if (controller.cols == 0 || controller.rows == 0) return;

    // Calculate level dimensions
    double levelWidth = controller.cols * tileSize;
    double levelHeight = controller.rows * tileSize;

    // Add some padding (e.g. 10% or fixed pixels) to edges
    // Level is centered, so we just need to ensure levelWidth fits in canvasWidth with margin
    double padding = 50.0;

    double availableWidth = size.x - padding * 2;
    double availableHeight = size.y - padding * 2;

    if (availableWidth <= 0 || availableHeight <= 0) return;

    double zoomX = availableWidth / levelWidth;
    double zoomY = availableHeight / levelHeight;

    // Use the smaller zoom to fit both dimensions
    double zoom = (zoomX < zoomY) ? zoomX : zoomY;

    // Clamp zoom to reasonable values if needed, but for "fit" we usually just take it.
    // Maybe cap max zoom so small levels aren't huge? e.g. max 1.5 or 2.0
    if (zoom > 1.5) zoom = 1.5;

    cameraComponent.viewfinder.zoom = zoom;
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

  void handleInput(Direction dir) {
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
          debugPrint("Level Complete!");
          // Auto-advance for now or wait for user input?
          // Let's wait for user input (any key/tap) to advance, but maybe show a message?
          // For now, next input advances.
        }
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        handleInput(Direction.up);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        handleInput(Direction.down);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        handleInput(Direction.left);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        handleInput(Direction.right);
      }

      // Cheats for debug
      if (event.logicalKey == LogicalKeyboardKey.keyN) {
        loadLevel(currentLevelIndex + 1);
      }
      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        loadLevel(currentLevelIndex);
      }
    }
    return KeyEventResult.handled;
  }
}
