class Level {
  final List<String> grid;
  final String description;

  const Level({
    required this.grid,
    required this.description,
  });
}

class LevelData {
  static final List<Level> levels = [
    // Level 1: Intro (Small 3x3 setup)
    const Level(
      description: "Level 1: The Basics",
      grid: [
        "#####",
        "#@\$.#",
        "#####",
      ],
    ),
    // Level 2: Simple Push
    const Level(
      description: "Level 2: Push It!",
      grid: [
        "#######",
        "#@ \$ .#",
        "#######",
      ],
    ),
    // Level 3: Corner Warning
    const Level(
      description: "Level 3: Careful with Corners",
      grid: [
        "######",
        "#@ . #",
        "# \$\$ #",
        "#.   #",
        "######",
      ],
    ),
    // Level 4: Dead End Concept
    const Level(
      description: "Level 4: Don't Get Stuck",
      grid: [
        "#######",
        "#     #",
        "#. # .#",
        "#  \$  #",
        "#  @  #",
        "#######",
      ],
    ),
    // Level 5: U-Shape
    const Level(
      description: "Level 5: The Loop",
      grid: [
        "#######",
        "# . . #",
        "### ###",
        "#  \$  #",
        "#  @  #",
        "#######",
      ],
    ),
    // Level 6: Two Boxes, Restricted Space
    const Level(
      description: "Level 6: Tight Space",
      grid: [
        "######",
        "#....#",
        "##\$\$##",
        "# @  #",
        "######",
      ],
    ),
    // Level 7: Classic T-Shape
    const Level(
      description: "Level 7: The T-Block",
      grid: [
        "#######",
        "###.###",
        "###.###",
        "###\$###",
        "#  \$  #",
        "#  @  #",
        "#######",
      ],
    ),
    // Level 8: Larger Map (10x10 scale)
    const Level(
      description: "Level 8: The Maze",
      grid: [
        "##########",
        "#        #",
        "# .####. #",
        "# \$    \$ #",
        "#   @    #",
        "# \$    \$ #",
        "# .####. #",
        "#        #",
        "##########",
      ],
    ),
    // Level 9: Avoiding Corners
    const Level(
      description: "Level 9: Strategic Moves",
      grid: [
        "##########",
        "#.  #   .#",
        "# \$ # \$  #",
        "#   #    #",
        "### @  ###",
        "#   #    #",
        "# \$ # \$  #",
        "#.  #   .#",
        "##########",
      ],
    ),
    // Level 10: Victory Lap (Complex)
    const Level(
      description: "Level 10: Grand Finale",
      grid: [
        "############",
        "##..    ..##",
        "##  \$\$\$\$  ##",
        "##   @    ##",
        "##  \$\$\$\$  ##",
        "##..    ..##",
        "############",
      ],
    ),
  ];
}
