import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'draggable_tower.dart';
import 'free_roam_enemy.dart';
import '../state/game_state.dart';

/// Free Roam game mode - drag towers to intercept critters from all directions
class FreeRoamGame extends FlameGame with DragCallbacks, HasCollisionDetection {
  final GameNotifier gameNotifier;
  bool bgmStarted = false;
  final Random _random = Random();

  // Towers
  late DraggableTower chickenTower;
  late DraggableTower gooseTower;

  // Spawning
  Timer? spawnTimer;
  int totalCrittersSpawned = 0;
  bool isStarted = false;

  static const double worldWidth = 800;
  static const double worldHeight = 480;
  static const double tileSize = 40;

  FreeRoamGame(this.gameNotifier);

  FarmLevel get farmLevel => gameNotifier.currentState.farmLevel;
  int get maxSpawns => farmLevel.maxCritterSpawns;

  @override
  Color backgroundColor() => const Color(0xFF1a2f1a);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.visibleGameSize = Vector2(worldWidth, worldHeight);
    camera.viewfinder.position = Vector2(worldWidth / 2, worldHeight / 2);
    camera.viewfinder.anchor = Anchor.center;

    await _loadBackground();

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

    await _placeTowers();
    _startSpawning();

    print('Free Roam Mode - ${farmLevel.name}');
    print('Drag your chicken and goose to intercept critters!');
  }

  Future<void> _loadBackground() async {
    // Load farm background
    final bgSprite = await loadSprite('farm_bg.png');
    world.add(
      SpriteComponent(
        sprite: bgSprite,
        size: Vector2(worldWidth, worldHeight),
        position: Vector2.zero(),
        priority: -10,
      ),
    );

    // Add subtle grid overlay
    for (int i = 0; i <= 20; i++) {
      world.add(
        RectangleComponent(
          position: Vector2(i * tileSize, 0),
          size: Vector2(1, worldHeight),
          paint: Paint()..color = const Color(0x10000000),
          priority: -7,
        ),
      );
    }
    for (int i = 0; i <= 12; i++) {
      world.add(
        RectangleComponent(
          position: Vector2(0, i * tileSize),
          size: Vector2(worldWidth, 1),
          paint: Paint()..color = const Color(0x10000000),
          priority: -7,
        ),
      );
    }

    // Add edge indicators to show where critters can spawn
    _addEdgeIndicators();
  }

  void _addEdgeIndicators() {
    final indicatorPaint = Paint()..color = const Color(0x33FF6B6B);

    // Top edge
    world.add(RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(worldWidth, 4),
      paint: indicatorPaint,
      priority: -5,
    ));

    // Bottom edge
    world.add(RectangleComponent(
      position: Vector2(0, worldHeight - 4),
      size: Vector2(worldWidth, 4),
      paint: indicatorPaint,
      priority: -5,
    ));

    // Left edge
    world.add(RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(4, worldHeight),
      paint: indicatorPaint,
      priority: -5,
    ));

    // Right edge
    world.add(RectangleComponent(
      position: Vector2(worldWidth - 4, 0),
      size: Vector2(4, worldHeight),
      paint: indicatorPaint,
      priority: -5,
    ));
  }

  Future<void> _placeTowers() async {
    // Place chicken in the center-left
    chickenTower = DraggableTower(
      position: Vector2(worldWidth * 0.3, worldHeight * 0.5),
      towerType: 'chicken',
    );
    world.add(chickenTower);

    // Place goose in the center-right
    gooseTower = DraggableTower(
      position: Vector2(worldWidth * 0.7, worldHeight * 0.5),
      towerType: 'goose',
    );
    world.add(gooseTower);
  }

  void startBGM() {
    if (!bgmStarted) {
      bgmStarted = true;
      FlameAudio.bgm.play('bgm_farm.mp3', volume: 0.4);
    }
  }

  void stopBGM() {
    if (bgmStarted) {
      FlameAudio.bgm.stop();
      bgmStarted = false;
    }
  }

  void _startSpawning() {
    if (isStarted) return;
    isStarted = true;
    startBGM();

    // Start spawning with initial interval
    spawnTimer?.stop();
    spawnTimer = Timer(
      _getSpawnInterval(),
      onTick: _spawnCritter,
      repeat: true,
    );
    spawnTimer!.start();

    // Delay first spawn
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!isRemoved) _spawnCritter();
    });
  }

  double _getSpawnInterval() {
    double base = farmLevel.spawnInterval;
    double decrease = (totalCrittersSpawned ~/ 20) * 0.15;
    return (base - decrease).clamp(0.6, base);
  }

  void _spawnCritter() {
    final gameState = gameNotifier.currentState;

    if (gameState.isVictory) {
      spawnTimer?.stop();
      return;
    }

    if (gameState.isGameOver) {
      spawnTimer?.stop();
      return;
    }

    if (totalCrittersSpawned >= maxSpawns) {
      spawnTimer?.stop();
      print('All critters spawned!');
      return;
    }

    totalCrittersSpawned++;

    // Random spawn direction
    final direction = SpawnDirection.values[_random.nextInt(4)];

    // Calculate spawn position along the edge
    Vector2 spawnPos;
    switch (direction) {
      case SpawnDirection.top:
        spawnPos = Vector2(
          _random.nextDouble() * (worldWidth - 100) + 50,
          -30,
        );
        break;
      case SpawnDirection.bottom:
        spawnPos = Vector2(
          _random.nextDouble() * (worldWidth - 100) + 50,
          worldHeight + 30,
        );
        break;
      case SpawnDirection.left:
        spawnPos = Vector2(
          -30,
          _random.nextDouble() * (worldHeight - 100) + 50,
        );
        break;
      case SpawnDirection.right:
        spawnPos = Vector2(
          worldWidth + 30,
          _random.nextDouble() * (worldHeight - 100) + 50,
        );
        break;
    }

    // Determine critter type
    final double wolfChance =
        (0.15 + farmLevel.level * 0.05 + totalCrittersSpawned * 0.002)
            .clamp(0.15, 0.4);
    final bool isWolf = _random.nextDouble() < wolfChance;
    final String type = isWolf ? 'wolf' : 'fox';

    // Calculate stats
    final double speedVariation = 0.9 + _random.nextDouble() * 0.2;
    final double baseSpeed = farmLevel.baseSpeed * 0.9; // Slightly slower for free roam
    final double critterEnergy = isWolf
        ? 50 + farmLevel.level * 12
        : 25 + farmLevel.level * 6;

    world.add(FreeRoamEnemy(
      spawnDirection: direction,
      position: spawnPos,
      energy: critterEnergy,
      speed: baseSpeed * speedVariation * (isWolf ? 0.8 : 1.0),
      reward: isWolf ? 4 : 2,
      critterType: type,
    ));

    // Adjust spawn timer as game progresses
    if (totalCrittersSpawned % 10 == 0) {
      spawnTimer?.stop();
      spawnTimer = Timer(_getSpawnInterval(), onTick: _spawnCritter, repeat: true);
      spawnTimer!.start();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    spawnTimer?.update(dt);
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

  void addCritterStop(int eggReward) {
    gameNotifier.addCritterStop();
    gameNotifier.earnEggs(eggReward);

    if (gameNotifier.currentState.isVictory) {
      final state = gameNotifier.currentState;
      print('Victory! Completed ${state.farmLevel.name}!');
      pauseEngine();
      overlays.add('Victory');
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

