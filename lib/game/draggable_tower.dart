import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'free_roam_game.dart';
import 'free_roam_enemy.dart';

/// A tower that can be dragged around to intercept critters in Free Roam mode
class DraggableTower extends SpriteComponent
    with HasGameRef<FreeRoamGame>, DragCallbacks {
  final String towerType;
  late double power;
  late double interceptCooldown;
  double _cooldownTimer = 0;
  bool isDragging = false;

  // Visual feedback
  late CircleComponent _rangeIndicator;
  static const double collisionRadius = 30.0;

  DraggableTower({
    super.position,
    this.towerType = 'chicken',
  });

  @override
  Future<void> onLoad() async {
    if (towerType == 'goose') {
      sprite = await game.loadSprite('goose_tower.png');
      power = 25; // Goose has more stopping power
      interceptCooldown = 0.8; // Slightly slower
    } else {
      sprite = await game.loadSprite('chicken_tower.png');
      power = 15; // Chicken has moderate stopping power
      interceptCooldown = 0.5; // Faster intercepts
    }

    size = Vector2.all(FreeRoamGame.tileSize * 1.2); // Slightly larger for easier dragging
    anchor = Anchor.center;
    priority = 20;

    // Add range indicator (shows collision area)
    _rangeIndicator = CircleComponent(
      radius: collisionRadius,
      paint: Paint()..color = const Color(0x00000000), // Invisible by default
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_rangeIndicator);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update cooldown
    if (_cooldownTimer > 0) {
      _cooldownTimer -= dt;
    }

    // Check for collisions with critters when not on cooldown
    if (_cooldownTimer <= 0) {
      _checkCritterCollisions();
    }

    // Keep tower within bounds
    _clampPosition();
  }

  void _clampPosition() {
    final halfSize = size.x / 2;
    position.x = position.x.clamp(halfSize, FreeRoamGame.worldWidth - halfSize);
    position.y = position.y.clamp(halfSize, FreeRoamGame.worldHeight - halfSize);
  }

  void _checkCritterCollisions() {
    final critters = game.world.children.whereType<FreeRoamEnemy>().toList();

    for (final critter in critters) {
      final distance = position.distanceTo(critter.position);
      if (distance < collisionRadius + critter.size.x / 2) {
        // Intercept the critter!
        _interceptCritter(critter);
        break; // Only intercept one critter per cooldown
      }
    }
  }

  void _interceptCritter(FreeRoamEnemy critter) {
    critter.takeHit(power);
    _cooldownTimer = interceptCooldown;

    // Play intercept sound (lower volume for chicken)
    if (towerType == 'goose') {
      FlameAudio.play('goose_honk.wav', volume: 0.4);
    } else {
      FlameAudio.play('chicken_cluck.wav', volume: 0.25);
    }

    // Play egg splat sound on hit
    FlameAudio.play('egg_splat.wav', volume: 0.6);

    // Visual feedback - brief flash
    _showInterceptEffect();
  }

  void _showInterceptEffect() {
    // Show range indicator briefly
    _rangeIndicator.paint.color = towerType == 'goose'
        ? const Color(0x44FFD700) // Golden for goose
        : const Color(0x44FF6B6B); // Red for chicken

    // Reset after short delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!isRemoved) {
        _rangeIndicator.paint.color = const Color(0x00000000);
      }
    });
  }

  // Drag callbacks
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    isDragging = true;
    // Show range while dragging
    _rangeIndicator.paint.color = const Color(0x224CAF50);
    priority = 100; // Bring to front while dragging
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
    _clampPosition();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    isDragging = false;
    _rangeIndicator.paint.color = const Color(0x00000000);
    priority = 20;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    isDragging = false;
    _rangeIndicator.paint.color = const Color(0x00000000);
    priority = 20;
  }
}

