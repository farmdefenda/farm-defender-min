import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/farm_defender_game.dart';
import '../state/game_state.dart';
import '../screens/main_menu_screen.dart';
import '../screens/game_screen.dart';

class VictoryOverlay extends ConsumerWidget {
  final FarmDefenderGame game;
  const VictoryOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final farmLevel = gameState.farmLevel;
    final hasNextLevel = gameState.hasNextLevel;
    final nextLevel = hasNextLevel ? FarmLevel.getLevel(farmLevel.level + 1) : null;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a4a1a), Color(0xFF0a2a0a)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD93D), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD93D).withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasNextLevel ? '🏆 FARM CLEARED! 🏆' : '🎉 YOU WON! 🎉',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD93D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${farmLevel.name} Complete!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Critters stopped: ${gameState.crittersStopped}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Text(
                'Lives remaining: ${gameState.lives} ❤️',
                style: const TextStyle(fontSize: 14, color: Colors.white60),
              ),
              const SizedBox(height: 20),

              // Next level preview or final victory
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: hasNextLevel
                    ? Column(
                        children: [
                          const Text(
                            '🌾 Next Farm Awaits! 🌾',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Farm ${nextLevel!.level}: ${nextLevel.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD93D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stop ${nextLevel.stopsToWin} critters to win',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        children: [
                          Text(
                            '🐔 ALL FARMS SAVED! 🪿',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You are a legendary farm defender!\nAll farms are safe from critters!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Buttons
              if (hasNextLevel)
                ElevatedButton.icon(
                  onPressed: () {
                    // Progress to next level
                    ref.read(gameProvider.notifier).startLevel(farmLevel.level + 1);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 28),
                  label: const Text(
                    'NEXT FARM',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD93D),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              
              if (hasNextLevel) const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Replay same level
                        ref.read(gameProvider.notifier).startLevel(farmLevel.level);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const GameScreen()),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('REPLAY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const MainMenuScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('MENU'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

