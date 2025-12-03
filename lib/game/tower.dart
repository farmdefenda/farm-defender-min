import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'farm_defender_game.dart';
import 'enemy.dart';
import 'projectile.dart';

class Tower extends SpriteComponent with HasGameRef<FarmDefenderGame> {
  final String towerType;
  late double power;
  late int eggCount; // Number of eggs thrown per throw
  bool isSelected = false;
  
  final Vector2 normalSize = Vector2.all(FarmDefenderGame.tileSize);

  Tower({
    super.position,
    this.towerType = 'chicken',
  });

  @override
  Future<void> onLoad() async {
    if (towerType == 'goose') {
      sprite = await game.loadSprite('goose_tower.png');
      power = 30;      // Goose has higher stopping power
      eggCount = 1;    // Single powerful egg per throw
    } else {
      sprite = await game.loadSprite('chicken_tower.png');
      power = 12;      // Chicken has lower stopping power
      eggCount = 1;    // Single egg per throw
    }

    size = normalSize.clone();
    anchor = Anchor.center;
    // Offset position to center in tile
    position += Vector2(FarmDefenderGame.tileSize / 2, FarmDefenderGame.tileSize / 2);
    priority = 20;
  }

  void select() {
    isSelected = true;
    // No size change - keep tower at normal size
  }

  void deselect() {
    isSelected = false;
    // No size change - keep tower at normal size
  }

  /// Throw eggs at critters anywhere on the map - returns true if threw, false if no eggs or no critters
  bool fireAtNearestCritter() {
    // Get all critters on the map - NO RANGE LIMIT
    final critters = game.world.children.whereType<Enemy>().toList();
    
    if (critters.isEmpty) {
      print('No critters on the map!');
      return false;
    }

    // Calculate how many eggs we want to throw
    final eggsToThrow = eggCount.clamp(1, critters.length.clamp(1, eggCount));
    
    // Check if we have enough eggs
    if (!game.tryUseEggs(eggsToThrow)) {
      print('Not enough eggs! Need $eggsToThrow');
      return false;
    }

    // Sort critters by distance (closest first)
    critters.sort((a, b) => 
      position.distanceTo(a.position).compareTo(position.distanceTo(b.position))
    );
    
    final eggSize = towerType == 'goose' 
        ? Vector2(20, 26)  // Big goose egg
        : Vector2(14, 18); // Chicken egg
    
    for (int i = 0; i < eggsToThrow; i++) {
      // Target different critters if available, otherwise target the same one
      final targetIndex = i < critters.length ? i : 0;
      final target = critters[targetIndex];
      
      // Add slight delay offset for visual effect (staggered throw)
      final offsetX = (i - eggsToThrow / 2) * 5.0;
      
      game.world.add(Projectile(
        target: target,
        position: position.clone() + Vector2(offsetX, 0),
        power: power,
        eggSize: eggSize,
        isGooseEgg: towerType == 'goose',
      ));
    }

    // Play sound once (lower volume for chicken)
    if (towerType == 'goose') {
      FlameAudio.play('goose_honk.wav', volume: 0.5);
    } else {
      FlameAudio.play('chicken_cluck.wav', volume: 0.3);
    }

    return true;
  }
}
