class Level {
  final List<String> grid;
  final String description;

  const Level({required this.grid, required this.description});
}

class LevelData {
  static final List<Level> levels = [
    // Level 1: Intro (Small 3x3 setup)
    const Level(
      description: "Level 1: The Basics\nPush the box to the target.",
      grid: [
        "#####",
        "#@\$.#",
        "#####",
      ],
    ),
    // Level 2: Simple Push
    const Level(
      description: "Level 2: Long Push\nSometimes the path is straight.",
      grid: [
        "#######",
        "#@ \$ .#",
        "#######",
      ],
    ),
    // Level 3: Corner Warning
    const Level(
      description: "Level 3: Watch the Corners\nDon't get stuck!",
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
      description: "Level 4: Dead Ends\nAvoid pushing boxes against walls.",
      grid: [
        "#######",
        "#     #",
        "#. # .#",
        "# \$ \$ #",
        "#  @  #",
        "#######",
      ],
    ),
    // Level 5: U-Shape
    const Level(
      description: "Level 5: The U-Turn\nNavigate carefully.",
      grid: [
        "#######",
        "# . . #",
        "##   ##",
        "# \$ \$ #",
        "#  @  #",
        "#######",
      ],
    ),
    // Level 6: Two Boxes, Restricted Space
    const Level(
      description: "Level 6: Tight Squeeze\nSpace is limited.",
      grid: [
        "######",
        "# .. #",
        "##\$\$##",
        "# @  #",
        "######",
      ],
    ),
    // Level 7: Classic T-Shape
    const Level(
      description: "Level 7: T-Junction\nDecision time.",
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
      description: "Level 8: The Plaza\nA larger area to cover.",
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
      description: "Level 9: Corner Dance\nKeep moving.",
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
      description: "Level 10: Final Challenge\nProve your mastery!",
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
