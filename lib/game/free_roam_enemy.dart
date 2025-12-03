import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'free_roam_game.dart';

/// Direction from which critter spawns
enum SpawnDirection { top, bottom, left, right }

/// Critter that moves in a straight line across the screen in Free Roam mode
class FreeRoamEnemy extends SpriteAnimationComponent
    with HasGameRef<FreeRoamGame> {
  final double speed;
  double energy;
  double maxEnergy;
  final String critterType;
  final int reward;
  final SpawnDirection spawnDirection;
  late Vector2 velocity;

  FreeRoamEnemy({
    required this.spawnDirection,
    required this.critterType,
    this.speed = 80,
    this.energy = 30,
    this.reward = 2,
    super.position,
  }) : maxEnergy = energy;

  @override
  Future<void> onLoad() async {
    priority = 10;
    size = Vector2.all(FreeRoamGame.tileSize * 0.85);
    anchor = Anchor.center;

    // Load animated sprite
    List<Sprite> sprites;
    if (critterType == 'wolf') {
      sprites = await Future.wait([
        game.loadSprite('wolf_frame1.png'),
        game.loadSprite('wolf_frame2.png'),
        game.loadSprite('wolf_frame3.png'),
        game.loadSprite('wolf_frame4.png'),
      ]);
    } else {
      sprites = await Future.wait([
        game.loadSprite('fox_enemy_frame1.png'),
        game.loadSprite('fox_enemy_frame2.png'),
        game.loadSprite('fox_enemy_frame3.png'),
        game.loadSprite('fox_enemy_frame4.png'),
      ]);
    }

    animation = SpriteAnimation.spriteList(sprites, stepTime: 0.12);

    // Calculate velocity based on spawn direction
    _calculateVelocity();

    // Flip sprite based on movement direction
    if (velocity.x < 0) {
      flipHorizontally();
    }
  }

  void _calculateVelocity() {
    // Move toward opposite side with slight angle toward center
    final centerX = FreeRoamGame.worldWidth / 2;
    final centerY = FreeRoamGame.worldHeight / 2;

    Vector2 target;
    switch (spawnDirection) {
      case SpawnDirection.top:
        // Move down, slightly toward center horizontally
        target = Vector2(
          centerX + (position.x - centerX) * 0.3,
          FreeRoamGame.worldHeight + 50,
        );
        break;
      case SpawnDirection.bottom:
        target = Vector2(
          centerX + (position.x - centerX) * 0.3,
          -50,
        );
        break;
      case SpawnDirection.left:
        target = Vector2(
          FreeRoamGame.worldWidth + 50,
          centerY + (position.y - centerY) * 0.3,
        );
        break;
      case SpawnDirection.right:
        target = Vector2(
          -50,
          centerY + (position.y - centerY) * 0.3,
        );
        break;
    }

    velocity = (target - position).normalized() * speed;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move in straight line
    position += velocity * dt;

    // Check if escaped (reached opposite side)
    if (_hasEscaped()) {
      game.decrementLives();
      removeFromParent();
    }
  }

  bool _hasEscaped() {
    const margin = 60.0;
    return position.x < -margin ||
        position.x > FreeRoamGame.worldWidth + margin ||
        position.y < -margin ||
        position.y > FreeRoamGame.worldHeight + margin;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Health bar background
    final hpBarWidth = size.x * 0.9;
    final hpBarHeight = 5.0;
    final hpBarX = (size.x - hpBarWidth) / 2;
    final hpBarY = -10.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hpBarX, hpBarY, hpBarWidth, hpBarHeight),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF333333),
    );

    // Energy bar fill
    final energyPercent = energy / maxEnergy;
    final energyColor = energyPercent > 0.5
        ? const Color(0xFF4CAF50)
        : (energyPercent > 0.25 ? const Color(0xFFFF9800) : const Color(0xFFF44336));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hpBarX, hpBarY, hpBarWidth * energyPercent, hpBarHeight),
        const Radius.circular(2),
      ),
      Paint()..color = energyColor,
    );
  }

  void takeHit(double amount) {
    energy -= amount;
    FlameAudio.play('enemy_hit.wav', volume: 0.4);

    if (energy <= 0) {
      removeFromParent();
      final eggReward = critterType == 'wolf' ? 4 : 2;
      game.addCritterStop(eggReward);
      FlameAudio.play('enemy_defeat.wav', volume: 0.7);
    }
  }
}

