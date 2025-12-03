import 'dart:math';
import 'package:flame/components.dart';
import 'farm_defender_game.dart';
import 'enemy.dart';
import '../state/game_state.dart';

class WaveManager extends Component with HasGameRef<FarmDefenderGame> {
  int totalCrittersSpawned = 0;
  Timer? spawnTimer;
  bool isStarted = false;
  final Random _random = Random();

  // Get current farm level settings
  FarmLevel get farmLevel => game.gameNotifier.currentState.farmLevel;
  int get maxSpawns => farmLevel.maxCritterSpawns;

  // Speed based on level's base speed + gradual increase
  double get currentSpeed {
    double base = farmLevel.baseSpeed;
    // Small speed increase as game progresses (less aggressive)
    double increase = (totalCrittersSpawned ~/ 20) * 2.0;
    return (base + increase).clamp(base, base + 30);
  }

  // Energy scales gradually based on level
  double get foxEnergy {
    double base = 20 + (farmLevel.level * 5);
    return base + (totalCrittersSpawned ~/ 15) * 3;
  }

  double get wolfEnergy {
    double base = 40 + (farmLevel.level * 10);
    return base + (totalCrittersSpawned ~/ 12) * 5;
  }

  // Spawn interval from level config, gradually speeds up
  double get spawnInterval {
    double base = farmLevel.spawnInterval;
    double decrease = (totalCrittersSpawned ~/ 25) * 0.1;
    return (base - decrease).clamp(0.8, base);
  }

  // Bulk spawning increases gradually
  int get bulkCount {
    int threshold1 = maxSpawns ~/ 5;  // After 20% spawned
    int threshold2 = maxSpawns ~/ 3;  // After 33% spawned
    
    if (totalCrittersSpawned < threshold1) return 1;
    if (totalCrittersSpawned < threshold2) return 2;
    return 3;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Auto-start spawning when game loads
    _startAutoSpawn();
  }

  void _startAutoSpawn() {
    if (isStarted) return;
    isStarted = true;

    // Start BGM
    game.startBGM();

    // Start spawning with initial interval
    spawnTimer?.stop();
    spawnTimer = Timer(spawnInterval, onTick: _spawnCritter, repeat: true);
    spawnTimer!.start();

    // Small delay before first spawn to let player get ready
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!isRemoved) _spawnCritter();
    });

    print('Farm ${farmLevel.level}: ${farmLevel.name}');
    print('Stop ${farmLevel.stopsToWin} out of $maxSpawns critters to win!');
  }

  void _spawnCritter() {
    final gameState = game.gameNotifier.currentState;

    // Check for victory - stop spawning
    if (gameState.isVictory) {
      spawnTimer?.stop();
      print('Victory! No more critters.');
      return;
    }

    // Check for game over
    if (gameState.isGameOver) {
      spawnTimer?.stop();
      return;
    }

    // Check if we've reached max spawns for this level
    if (totalCrittersSpawned >= maxSpawns) {
      spawnTimer?.stop();
      print('All $maxSpawns critters spawned! Stop ${farmLevel.stopsToWin - gameState.crittersStopped} more to win!');
      return;
    }

    if (game.levelWaypoints.isEmpty) return;

    // Spawn critters in bulk (but don't exceed max)
    int toSpawn = bulkCount;
    if (totalCrittersSpawned + toSpawn > maxSpawns) {
      toSpawn = maxSpawns - totalCrittersSpawned;
    }

    for (int i = 0; i < toSpawn; i++) {
      totalCrittersSpawned++;

      // Wolf chance increases with level and progress
      final double wolfChance = (0.1 + farmLevel.level * 0.05 + totalCrittersSpawned * 0.002)
          .clamp(0.1, 0.4);
      final bool isWolf = _random.nextDouble() < wolfChance;
      final String type = isWolf ? 'wolf' : 'fox';

      // Calculate stats with slight randomness
      final double speedVariation = 0.9 + _random.nextDouble() * 0.2;
      final double energyVariation = 0.95 + _random.nextDouble() * 0.1;

      final double critterEnergy = (isWolf ? wolfEnergy : foxEnergy) * energyVariation;
      final double speed = currentSpeed * speedVariation * (isWolf ? 0.75 : 1.0);

      // Position offset for bulk spawns
      final startPosition = game.levelWaypoints.first.clone();
      startPosition.x -= i * 25;

      game.world.add(Enemy(
        waypoints: List.from(game.levelWaypoints),
        position: startPosition,
        energy: critterEnergy,
        speed: speed,
        reward: isWolf ? 3 : 1,
        critterType: type,
      ));
    }

    // Adjust spawn timer speed as game progresses
    if (totalCrittersSpawned % 10 == 0) {
      spawnTimer?.stop();
      spawnTimer = Timer(spawnInterval, onTick: _spawnCritter, repeat: true);
      spawnTimer!.start();
    }
  }

  @override
  void update(double dt) {
    spawnTimer?.update(dt);
  }
}
