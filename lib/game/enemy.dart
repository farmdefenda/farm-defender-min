import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' show Curves;
import 'farm_defender_game.dart';

class Enemy extends SpriteAnimationComponent with HasGameRef<FarmDefenderGame> {
  final double speed;
  double energy;
  double maxEnergy;
  final List<Vector2> waypoints;
  final String critterType;
  final int reward;
  int _currentWaypointIndex = 0;

  Enemy({
    required this.waypoints,
    required this.critterType,
    this.speed = 70,
    this.energy = 30,
    this.reward = 10,
    super.position,
  }) : maxEnergy = energy;

  @override
  Future<void> onLoad() async {
    priority = 10;
    size = Vector2.all(FarmDefenderGame.tileSize * 0.85);
    anchor = Anchor.center;

    // Load animated sprite from actual assets
    List<Sprite> sprites;
    if (critterType == 'wolf') {
      sprites = await Future.wait([
        game.loadSprite('wolf_frame1.png'),
        game.loadSprite('wolf_frame2.png'),
        game.loadSprite('wolf_frame3.png'),
        game.loadSprite('wolf_frame4.png'),
      ]);
    } else {
      // Fox
      sprites = await Future.wait([
        game.loadSprite('fox_enemy_frame1.png'),
        game.loadSprite('fox_enemy_frame2.png'),
        game.loadSprite('fox_enemy_frame3.png'),
        game.loadSprite('fox_enemy_frame4.png'),
      ]);
    }

    animation = SpriteAnimation.spriteList(sprites, stepTime: 0.12);

    if (waypoints.isNotEmpty) {
      _moveToNextWaypoint();
    }
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

  void _moveToNextWaypoint() {
    if (_currentWaypointIndex >= waypoints.length) {
      _onReachEnd();
      return;
    }

    final target = waypoints[_currentWaypointIndex];
    _currentWaypointIndex++;

    final distance = position.distanceTo(target);
    if (distance < 1) {
      _moveToNextWaypoint();
      return;
    }

    final duration = distance / speed;

    // Flip sprite based on movement direction
    if (target.x < position.x) {
      flipHorizontally();
    }

    add(
      MoveToEffect(
        target,
        EffectController(duration: duration, curve: Curves.linear),
        onComplete: _moveToNextWaypoint,
      ),
    );
  }

  void _onReachEnd() {
    game.decrementLives();
    removeFromParent();
  }

  void takeHit(double amount) {
    energy -= amount;
    FlameAudio.play('enemy_hit.wav', volume: 0.4);

    if (energy <= 0) {
      removeFromParent();
      // Egg rewards: fox = 2 eggs, wolf = 4 eggs
      final eggReward = critterType == 'wolf' ? 4 : 2;
      game.addCritterStop(eggReward);
      FlameAudio.play('enemy_defeat.wav', volume: 0.7);
    }
  }
}
