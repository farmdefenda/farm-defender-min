import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/farm_defender_game.dart';
import '../state/game_state.dart';

class HUDOverlay extends ConsumerWidget {
  final FarmDefenderGame game;
  const HUDOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final farmLevel = gameState.farmLevel;
    final progress = gameState.crittersStopped / farmLevel.stopsToWin;

    final isLowOnEggs = gameState.eggs < 5;

    return Stack(
      children: [
        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Lives
                  _StatBadge(
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    value: '${gameState.lives}',
                  ),

                  // Progress to win
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Farm name and level
                          Text(
                            'Farm ${farmLevel.level}: ${farmLevel.name}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFB8D4B8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${gameState.crittersStopped} / ${farmLevel.stopsToWin}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD93D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.black45,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFFFD93D),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Eggs count - prominent display
                  _EggBadge(
                    eggs: gameState.eggs,
                    maxEggs: farmLevel.maxEggs,
                    isLow: isLowOnEggs,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Pause button
        Positioned(
          top: 8,
          right: 8,
          child: SafeArea(
            child: IconButton(
              onPressed: () => game.pauseGame(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black45,
                padding: const EdgeInsets.all(8),
              ),
              icon: const Icon(
                Icons.pause_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),

        // Attack instructions hint
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isLowOnEggs ? Colors.red.shade900.withValues(alpha: 0.8) : Colors.black54,
                borderRadius: BorderRadius.circular(12),
                border: isLowOnEggs ? Border.all(color: Colors.red, width: 2) : null,
              ),
              child: Text(
                isLowOnEggs 
                    ? '⚠️ Low on eggs! Stop critters to earn more!'
                    : '🐔 Tap chicken (2 eggs) or 🪿 goose (3 eggs) to throw!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isLowOnEggs ? FontWeight.bold : FontWeight.w500,
                  color: isLowOnEggs ? Colors.white : const Color(0xFFB8D4B8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EggBadge extends StatelessWidget {
  final int eggs;
  final int maxEggs;
  final bool isLow;

  const _EggBadge({
    required this.eggs,
    required this.maxEggs,
    required this.isLow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.shade900 : Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: isLow ? Border.all(color: Colors.red, width: 2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🥚', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$eggs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isLow ? Colors.red.shade300 : const Color(0xFFFFD93D),
                ),
              ),
              Text(
                'max $maxEggs',
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

