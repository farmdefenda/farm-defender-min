import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Game modes available
enum GameMode {
  towerDefense, // Classic mode: click towers to shoot, critters follow path
  freeRoam, // Action mode: drag towers to intercept critters from all directions
}

/// Configuration for each farm level
class FarmLevel {
  final int level;
  final String name;
  final int stopsToWin;
  final int maxCritterSpawns;
  final double baseSpeed;
  final double spawnInterval;
  final int lives;
  final int startingEggs; // Eggs you start with
  final int maxEggs; // Maximum eggs you can hold

  const FarmLevel({
    required this.level,
    required this.name,
    required this.stopsToWin,
    required this.maxCritterSpawns,
    required this.baseSpeed,
    required this.spawnInterval,
    required this.lives,
    required this.startingEggs,
    required this.maxEggs,
  });

  /// All available farm levels
  /// Balance: Tight margins, later farms = FASTER critters
  static const List<FarmLevel> allLevels = [
    FarmLevel(
      level: 1,
      name: "Sunny Meadow",
      stopsToWin: 30,
      maxCritterSpawns: 35,
      baseSpeed: 50,
      spawnInterval: 2.0,
      lives: 5,
      startingEggs: 20, // Generous start
      maxEggs: 30,
    ),
    FarmLevel(
      level: 2,
      name: "Green Pastures",
      stopsToWin: 50,
      maxCritterSpawns: 60,
      baseSpeed: 65,
      spawnInterval: 1.8,
      lives: 5,
      startingEggs: 25,
      maxEggs: 40,
    ),
    FarmLevel(
      level: 3,
      name: "Golden Fields",
      stopsToWin: 80,
      maxCritterSpawns: 95,
      baseSpeed: 80,
      spawnInterval: 1.5,
      lives: 6,
      startingEggs: 30,
      maxEggs: 50,
    ),
    FarmLevel(
      level: 4,
      name: "Harvest Valley",
      stopsToWin: 120,
      maxCritterSpawns: 140,
      baseSpeed: 95,
      spawnInterval: 1.2,
      lives: 7,
      startingEggs: 35,
      maxEggs: 60,
    ),
    FarmLevel(
      level: 5,
      name: "Final Stand",
      stopsToWin: 200,
      maxCritterSpawns: 220,
      baseSpeed: 110,
      spawnInterval: 1.0,
      lives: 8,
      startingEggs: 40,
      maxEggs: 80,
    ),
  ];

  static FarmLevel getLevel(int level) {
    final index = (level - 1).clamp(0, allLevels.length - 1);
    return allLevels[index];
  }
}

class GameState {
  final int lives;
  final int crittersStopped;
  final bool isGameOver;
  final bool isVictory;
  final int currentFarmLevel;
  final int eggs; // Current egg count
  final GameMode gameMode; // Current game mode

  const GameState({
    this.lives = 5,
    this.crittersStopped = 0,
    this.isGameOver = false,
    this.isVictory = false,
    this.currentFarmLevel = 1,
    this.eggs = 20,
    this.gameMode = GameMode.towerDefense,
  });

  FarmLevel get farmLevel => FarmLevel.getLevel(currentFarmLevel);
  int get stopsToWin => farmLevel.stopsToWin;
  int get maxCritterSpawns => farmLevel.maxCritterSpawns;
  int get maxEggs => farmLevel.maxEggs;
  bool get hasNextLevel => currentFarmLevel < FarmLevel.allLevels.length;

  GameState copyWith({
    int? lives,
    int? crittersStopped,
    bool? isGameOver,
    bool? isVictory,
    int? currentFarmLevel,
    int? eggs,
    GameMode? gameMode,
  }) {
    return GameState(
      lives: lives ?? this.lives,
      crittersStopped: crittersStopped ?? this.crittersStopped,
      isGameOver: isGameOver ?? this.isGameOver,
      isVictory: isVictory ?? this.isVictory,
      currentFarmLevel: currentFarmLevel ?? this.currentFarmLevel,
      eggs: eggs ?? this.eggs,
      gameMode: gameMode ?? this.gameMode,
    );
  }
}

class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() => const GameState();

  GameState get currentState => state;

  void reset() {
    state = const GameState();
  }

  void startLevel(int level, {GameMode mode = GameMode.towerDefense}) {
    final farmLevel = FarmLevel.getLevel(level);
    state = GameState(
      currentFarmLevel: level,
      lives: farmLevel.lives,
      crittersStopped: 0,
      isGameOver: false,
      isVictory: false,
      eggs: farmLevel.startingEggs,
      gameMode: mode,
    );
  }

  void decrementLives() {
    if (state.isGameOver || state.isVictory) return;
    final newLives = state.lives - 1;
    state = state.copyWith(lives: newLives);
    if (newLives <= 0) {
      state = state.copyWith(isGameOver: true);
    }
  }

  /// Use eggs for attack - returns true if enough eggs
  bool useEggs(int count) {
    if (state.isGameOver || state.isVictory) return false;
    if (state.eggs < count) return false;

    state = state.copyWith(eggs: state.eggs - count);
    return true;
  }

  /// Earn eggs from stopping critters
  void earnEggs(int count) {
    if (state.isGameOver || state.isVictory) return;
    final newEggs = (state.eggs + count).clamp(0, state.maxEggs);
    state = state.copyWith(eggs: newEggs);
  }

  void addCritterStop() {
    if (state.isGameOver || state.isVictory) return;
    final newStops = state.crittersStopped + 1;
    state = state.copyWith(crittersStopped: newStops);

    // Earn eggs for stopping critters (fox = 2 eggs, wolf = 4 eggs handled in critter)
    // Base reward is handled separately

    // Check for victory
    if (newStops >= state.stopsToWin) {
      state = state.copyWith(isVictory: true);
    }
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);
