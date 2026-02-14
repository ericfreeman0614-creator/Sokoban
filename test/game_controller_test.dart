import 'package:flutter_test/flutter_test.dart';
import 'package:sokoban_game/core/game_controller.dart';
import 'package:sokoban_game/core/enums.dart';

void main() {
  group('GameController Tests', () {
    late GameController controller;

    setUp(() {
      controller = GameController();
    });

    test('Load Level correctly parses map', () {
      List<String> validLevel = [
        "#####",
        "#@\$.#",
        "#####",
      ];
      controller.loadLevel(validLevel);
      expect(controller.rows, 3);
      expect(controller.cols, 5);
      expect(controller.grid[1][1], MapElement.player);
      expect(controller.grid[1][2], MapElement.box);
      expect(controller.grid[1][3], MapElement.target);
    });

    test('Player moves into empty space', () {
      List<String> level = [
        "#####",
        "# @ #",
        "#####",
      ];
      controller.loadLevel(level); // Player at 1,2
      
      bool moved = controller.movePlayer(Direction.right);
      expect(moved, true);
      expect(controller.grid[1][2], MapElement.floor); // Old pos
      expect(controller.grid[1][3], MapElement.player); // New pos
    });

    test('Player pushes box', () {
      List<String> level = [
        "#######",
        "# @ \$ #",
        "#######",
      ];
      controller.loadLevel(level); // Player at 1,2. Box at 1,4
      
      // Move right (to 1,3) - empty
      controller.movePlayer(Direction.right); 
      
      // Move right (to 1,4) - push box to 1,5
      bool moved = controller.movePlayer(Direction.right);
      
      expect(moved, true);
      expect(controller.grid[1][3], MapElement.floor);
      expect(controller.grid[1][4], MapElement.player);
      expect(controller.grid[1][5], MapElement.box);
    });

    test('Box stops at wall', () {
       List<String> level = [
        "######",
        "# @\$ #", // Player 1,2. Box 1,3. Wall 1,5 (so 1,4 is space)
        "######",
      ];
      // Actually map above: #0, sp1, @2, $3, sp4, #5
      controller.loadLevel(level); 
      
      // Push box to 1,4
      controller.movePlayer(Direction.right);
      expect(controller.grid[1][4], MapElement.box);
      
      // Try to push box into wall (1,5)
      bool moved = controller.movePlayer(Direction.right);
      expect(moved, false);
      expect(controller.grid[1][4], MapElement.box); // Should not move
      expect(controller.grid[1][3], MapElement.player); // Player calcified
    });

    test('Win condition', () {
      List<String> level = [
        "#####",
        "#@\$.#",
        "#####",
      ];
      controller.loadLevel(level);
      
      // Push box right
      controller.movePlayer(Direction.right);
      
      expect(controller.grid[1][3], MapElement.boxOnTarget);
      expect(controller.isLevelComplete, true);
    });
  });
}
