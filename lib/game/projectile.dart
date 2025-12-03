import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'farm_defender_game.dart';
import 'enemy.dart';

class Projectile extends SpriteComponent with HasGameRef<FarmDefenderGame> {
  final Enemy target;
  final double speed;
  final double power;
  final Vector2 eggSize;
  final bool isGooseEgg;

  Projectile({
    required this.target,
    required super.position,
    this.power = 12,
    this.speed = 350,
    Vector2? eggSize,
    this.isGooseEgg = false,
  }) : eggSize = eggSize ?? Vector2(12, 16);

  @override
  Future<void> onLoad() async {
    // Use actual egg projectile sprite
    sprite = await game.loadSprite('egg_projectile.png');
    size = eggSize;
    anchor = Anchor.center;
    priority = 30;

    // Goose eggs are slightly tinted
    if (isGooseEgg) {
      // Could add a slight blue tint or glow effect here
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (target.isRemoved) {
      removeFromParent();
      return;
    }

    // Move towards target center
    final targetCenter =
        target.position + Vector2(target.size.x / 2, target.size.y / 2);
    final direction = (targetCenter - position).normalized();
    position += direction * speed * dt;

    // Rotate egg to face direction of travel
    angle = direction.screenAngle();

    // Collision check - bigger collision for bigger eggs
    final hitRadius = isGooseEgg ? 22.0 : 16.0;
    if (position.distanceTo(targetCenter) < hitRadius) {
      target.takeHit(power);
      removeFromParent();
      FlameAudio.play('egg_splat.wav', volume: 0.8);
    }
  }
}
