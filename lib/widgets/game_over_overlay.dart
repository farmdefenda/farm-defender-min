import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/farm_defender_game.dart';
import '../state/game_state.dart';
import '../screens/main_menu_screen.dart';
import '../screens/game_screen.dart';

class GameOverOverlay extends ConsumerWidget {
  final FarmDefenderGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final farmLevel = gameState.farmLevel;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4a1a1a), Color(0xFF2a1010)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.red.shade800, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '😢 GAME OVER 😢',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${farmLevel.name} Failed',
                style: const TextStyle(fontSize: 16, color: Colors.white54),
              ),
              const SizedBox(height: 16),
              Text(
                'Stopped: ${gameState.crittersStopped} / ${farmLevel.stopsToWin}',
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      '💡 Tip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD93D),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap faster on your chicken and goose!\nThe goose has more stopping power!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Retry same level
                        ref.read(gameProvider.notifier).startLevel(farmLevel.level);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const GameScreen()),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('TRY AGAIN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

