import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'wave_manager.dart';
import 'tower.dart';
import '../state/game_state.dart';

class FarmDefenderGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  final GameNotifier gameNotifier;
  late WaveManager waveManager;
  List<List<int>> grid = [];
  List<Vector2> levelWaypoints = [];
  bool bgmStarted = false;

  // Pre-placed towers
  late Tower chickenTower;
  late Tower gooseTower;
  Tower? selectedTower;

  static const double worldWidth = 800;
  static const double worldHeight = 480;
  static const double tileSize = 40;
  static const int gridCols = 20;
  static const int gridRows = 12;

  FarmDefenderGame(this.gameNotifier);

  @override
  Color backgroundColor() => const Color(0xFF1a2f1a);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.visibleGameSize = Vector2(worldWidth, worldHeight);
    camera.viewfinder.position = Vector2(worldWidth / 2, worldHeight / 2);
    camera.viewfinder.anchor = Anchor.center;

    await _loadMap();

    await FlameAudio.audioCache.loadAll([
      'bgm_farm.mp3',
      'chicken_cluck.wav',
      'goose_honk.wav',
      'click.wav',
      'egg_splat.wav',
      'enemy_defeat.wav',
      'enemy_hit.wav',
      'game_over.wav',
    ]);

    // Pre-place the chicken and goose on the map
    await _placeTowers();

    waveManager = WaveManager();
    world.add(waveManager);

    final farmLevel = gameNotifier.currentState.farmLevel;
    print('FarmDefenderGame loaded - ${farmLevel.name}');
    print('Stop ${farmLevel.stopsToWin} critters to win!');
  }

  Future<void> _placeTowers() async {
    // Chicken covers the left/center path sections
    chickenTower = Tower(
      position: Vector2(5 * tileSize, 5 * tileSize), // Left side of map
      towerType: 'chicken',
    );
    world.add(chickenTower);

    // Goose covers the right path sections - strategic placement required
    gooseTower = Tower(
      position: Vector2(13 * tileSize, 3 * tileSize), // Right side of map
      towerType: 'goose',
    );
    world.add(gooseTower);
  }

  void startBGM() {
    if (!bgmStarted) {
      bgmStarted = true;
      // Play BGM with looping enabled
      FlameAudio.bgm.play('bgm_farm.mp3', volume: 0.4);
    }
  }

  void stopBGM() {
    if (bgmStarted) {
      FlameAudio.bgm.stop();
      bgmStarted = false;
    }
  }

  Future<void> _loadMap() async {
    // Redesigned path: Critters enter from TOP-CENTER and wind through the map
    // This creates more strategic gameplay - can't just camp one spot
    final List<List<int>> mapLayout = [
      [
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
      ], // Entry from top
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1],
      [1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1],
      [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1],
      [
        1,
        1,
        1,
        0,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
      ], // Exit right
      [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1],
      [
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ], // Lower exit
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ];

    grid = mapLayout;
    await _renderMap();

    // Path: Enter top-center, wind down through both sides of map
    levelWaypoints = [
      Vector2(7 * tileSize + tileSize / 2, 0), // Spawn at top
      Vector2(7 * tileSize + tileSize / 2, 1 * tileSize + tileSize / 2),
      Vector2(7 * tileSize + tileSize / 2, 3 * tileSize + tileSize / 2),
      Vector2(
        3 * tileSize + tileSize / 2,
        3 * tileSize + tileSize / 2,
      ), // Go left
      Vector2(
        3 * tileSize + tileSize / 2,
        6 * tileSize + tileSize / 2,
      ), // Down left side
      Vector2(
        11 * tileSize + tileSize / 2,
        6 * tileSize + tileSize / 2,
      ), // Cross to right
      Vector2(
        11 * tileSize + tileSize / 2,
        2 * tileSize + tileSize / 2,
      ), // Up right side
      Vector2(
        15 * tileSize + tileSize / 2,
        2 * tileSize + tileSize / 2,
      ), // Right
      Vector2(
        15 * tileSize + tileSize / 2,
        5 * tileSize + tileSize / 2,
      ), // Down
      Vector2(worldWidth, 5 * tileSize + tileSize / 2), // Exit right
    ];
  }

  Future<void> _renderMap() async {
    final bgSprite = await loadSprite('farm_bg.png');
    world.add(
      SpriteComponent(
        sprite: bgSprite,
        size: Vector2(worldWidth, worldHeight),
        position: Vector2.zero(),
        priority: -10,
      ),
    );

    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        if (grid[row][col] == 0) {
          world.add(
            RectangleComponent(
              position: Vector2(col * tileSize, row * tileSize),
              size: Vector2(tileSize, tileSize),
              paint: Paint()..color = const Color(0xCC8B7355),
              priority: -9,
            ),
          );
          world.add(
            RectangleComponent(
              position: Vector2(col * tileSize + 3, row * tileSize + 3),
              size: Vector2(tileSize - 6, tileSize - 6),
              paint: Paint()..color = const Color(0xCCA0896C),
              priority: -8,
            ),
          );
        }
      }
    }

    for (int i = 0; i <= gridCols; i++) {
      world.add(
        RectangleComponent(
          position: Vector2(i * tileSize, 0),
          size: Vector2(1, worldHeight),
          paint: Paint()..color = const Color(0x15000000),
          priority: -7,
        ),
      );
    }
    for (int i = 0; i <= gridRows; i++) {
      world.add(
        RectangleComponent(
          position: Vector2(0, i * tileSize),
          size: Vector2(worldWidth, 1),
          paint: Paint()..color = const Color(0x15000000),
          priority: -7,
        ),
      );
    }

    // Spawn point marker - critters enter from top-center
    world.add(
      CircleComponent(
        position: Vector2(7 * tileSize + tileSize / 2, tileSize / 2),
        radius: 12,
        paint: Paint()..color = const Color(0xAAFF6B6B),
        anchor: Anchor.center,
        priority: -6,
      ),
    );

    // Exit point marker - critters exit on right side
    world.add(
      CircleComponent(
        position: Vector2(worldWidth - 10, 5 * tileSize + tileSize / 2),
        radius: 12,
        paint: Paint()..color = const Color(0xAA4ECDC4),
        anchor: Anchor.center,
        priority: -6,
      ),
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Don't process taps if game is over or won
    if (gameNotifier.currentState.isGameOver ||
        gameNotifier.currentState.isVictory) {
      return;
    }

    final worldPosition = camera.globalToLocal(event.localPosition);

    // Check if tapped on a tower
    Tower? tappedTower = _getTowerAt(worldPosition);

    if (tappedTower != null) {
      // Select the tower
      selectedTower?.deselect();
      selectedTower = tappedTower;
      tappedTower.select();

      // Immediately throw egg when tapping tower
      bool threw = tappedTower.fireAtNearestCritter();
      if (!threw) {
        // No critters on map - play click sound as feedback
        FlameAudio.play('click.wav', volume: 0.5);
      }
      return;
    }

    // Tapping elsewhere deselects
    selectedTower?.deselect();
    selectedTower = null;
  }

  Tower? _getTowerAt(Vector2 position) {
    final towers = world.children.whereType<Tower>();
    for (final tower in towers) {
      // Tower uses center anchor, so check distance from center
      final distance = tower.position.distanceTo(position);
      if (distance < tileSize / 2 + 10) {
        // Slightly larger hit area for easier tapping
        return tower;
      }
    }
    return null;
  }

  void decrementLives() {
    gameNotifier.decrementLives();
    if (gameNotifier.currentState.isGameOver) {
      print('Game Over!');
      FlameAudio.play('game_over.wav');
      FlameAudio.bgm.stop();
      pauseEngine();
      overlays.add('GameOver');
    }
  }

  /// Try to use eggs for throwing - returns true if successful
  bool tryUseEggs(int count) {
    return gameNotifier.useEggs(count);
  }

  /// Earn eggs from stopping critters
  void earnEggs(int count) {
    gameNotifier.earnEggs(count);
  }

  void addCritterStop(int eggReward) {
    gameNotifier.addCritterStop();
    gameNotifier.earnEggs(eggReward);

    // Check for victory
    if (gameNotifier.currentState.isVictory) {
      final state = gameNotifier.currentState;
      print('Victory! Completed ${state.farmLevel.name}!');
      pauseEngine();
      overlays.add('Victory');
      // Don't stop BGM on victory - it will continue for next level
    }
  }

  void pauseGame() {
    pauseEngine();
    overlays.add('PauseMenu');
  }

  void resumeGame() {
    overlays.remove('PauseMenu');
    resumeEngine();
  }
}
