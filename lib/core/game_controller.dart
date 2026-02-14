import 'package:sokoban_game/core/enums.dart';

class GameController {
  List<List<MapElement>> grid = [];
  int rows = 0;
  int cols = 0;
  bool isLevelComplete = false;

  void loadLevel(List<String> levelData) {
    rows = levelData.length;
    cols = levelData[0].length;
    grid = List.generate(rows, (_) => List.filled(cols, MapElement.floor));
    isLevelComplete = false;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Safe access in case strings are different lengths
        String char = (c < levelData[r].length) ? levelData[r][c] : ' ';
        grid[r][c] = _charToElement(char);
      }
    }
  }

  MapElement _charToElement(String char) {
    switch (char) {
      case '#':
        return MapElement.wall;
      case '@':
        return MapElement.player;
      case '+':
        return MapElement.playerOnTarget;
      case '\$':
        return MapElement.box;
      case '*':
        return MapElement.boxOnTarget;
      case '.':
        return MapElement.target;
      default:
        return MapElement.floor;
    }
  }

  // Returns true if move was successful (state changed)
  bool movePlayer(Direction direction) {
    if (isLevelComplete) return false;

    // Find player
    int playerR = -1, playerC = -1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == MapElement.player ||
            grid[r][c] == MapElement.playerOnTarget) {
          playerR = r;
          playerC = c;
          break;
        }
      }
      if (playerR != -1) break;
    }

    if (playerR == -1) return false; // No player found

    int dRow = 0, dCol = 0;
    switch (direction) {
      case Direction.up:
        dRow = -1;
        break;
      case Direction.down:
        dRow = 1;
        break;
      case Direction.left:
        dCol = -1;
        break;
      case Direction.right:
        dCol = 1;
        break;
    }

    int targetR = playerR + dRow;
    int targetC = playerC + dCol;

    if (!_isValidPos(targetR, targetC)) return false;

    MapElement targetCell = grid[targetR][targetC];

    // Case 1: Move into Empty or Target
    if (targetCell == MapElement.floor || targetCell == MapElement.target) {
      _moveEntity(playerR, playerC, targetR, targetC, isPlayer: true);
      return true;
    }

    // Case 2: Push Box
    if (targetCell == MapElement.box || targetCell == MapElement.boxOnTarget) {
      int boxTargetR = targetR + dRow;
      int boxTargetC = targetC + dCol;

      if (!_isValidPos(boxTargetR, boxTargetC)) return false;

      MapElement boxTargetCell = grid[boxTargetR][boxTargetC];

      // Box can only move into floor or target
      if (boxTargetCell == MapElement.floor ||
          boxTargetCell == MapElement.target) {
        // Move box first
        _moveEntity(targetR, targetC, boxTargetR, boxTargetC, isPlayer: false);
        // Then move player
        _moveEntity(playerR, playerC, targetR, targetC, isPlayer: true);
        
        _checkWinCondition();
        return true;
      }
    }

    return false; // Blocked by wall or another box
  }

  void _moveEntity(int fromR, int fromC, int toR, int toC, {required bool isPlayer}) {
    // Determine what's left behind
    MapElement fromCell = grid[fromR][fromC];
    MapElement underFrom = (fromCell == MapElement.playerOnTarget ||
            fromCell == MapElement.boxOnTarget)
        ? MapElement.target
        : MapElement.floor;

    // Determine what's at the destination (underneath the incoming entity)
    MapElement toCell = grid[toR][toC];
    bool toIsTarget =
        (toCell == MapElement.target || toCell == MapElement.boxOnTarget || toCell == MapElement.playerOnTarget);

    // Update 'from' cell
    grid[fromR][fromC] = underFrom;

    // Update 'to' cell
    if (isPlayer) {
      grid[toR][toC] = toIsTarget ? MapElement.playerOnTarget : MapElement.player;
    } else {
      grid[toR][toC] = toIsTarget ? MapElement.boxOnTarget : MapElement.box;
    }
  }

  bool _isValidPos(int r, int c) {
    return r >= 0 && r < rows && c >= 0 && c < cols && grid[r][c] != MapElement.wall;
  }

  void _checkWinCondition() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // If there is a target without a box, or a box not on a target
        if (grid[r][c] == MapElement.box) return; // Box on floor
        if (grid[r][c] == MapElement.target) return; // Empty target
        if (grid[r][c] == MapElement.playerOnTarget) return; // Player on target (blocking it from a box)
         // Note: playerOnTarget means the target is occupied by player, so it's not solved yet.
      }
    }
    isLevelComplete = true;
  }
}
