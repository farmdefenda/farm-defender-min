import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/farm_defender_game.dart';
import '../state/game_state.dart';

class HUDOverlay extends ConsumerStatefulWidget {
  final FarmDefenderGame game;
  const HUDOverlay({super.key, required this.game});

  @override
  ConsumerState<HUDOverlay> createState() => _HUDOverlayState();
}

class _HUDOverlayState extends ConsumerState<HUDOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Auto-hide instruction banner after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _fadeController.forward().then((_) {
          if (mounted) {
            setState(() => _showInstructions = false);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final farmLevel = gameState.farmLevel;
    final progress = gameState.crittersStopped / farmLevel.stopsToWin;
    final isLowOnEggs = gameState.eggs < 5;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Stack(
      children: [
        // Top-left: Lives badge - compact
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${gameState.lives}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Top-center: Farm name & progress - compact
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Farm name - smaller
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌾', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          'Farm ${farmLevel.level}: ${farmLevel.name}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFB8D4B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Progress counter
                    Text(
                      '${gameState.crittersStopped} / ${farmLevel.stopsToWin}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD93D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Mini progress bar
                    SizedBox(
                      width: 80,
                      height: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.black45,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFFD93D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Top-right: Eggs count & Pause button
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Eggs badge
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLowOnEggs
                        ? Colors.red.shade900.withValues(alpha: 0.8)
                        : Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: isLowOnEggs
                        ? Border.all(color: Colors.red, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🥚', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${gameState.eggs}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isLowOnEggs
                                  ? Colors.red.shade300
                                  : const Color(0xFFFFD93D),
                            ),
                          ),
                          Text(
                            'max ${farmLevel.maxEggs}',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Pause button
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => widget.game.pauseGame(),
                    icon: const Icon(Icons.pause_rounded),
                    color: Colors.white,
                    iconSize: 24,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Instruction banner - fades out after 5 seconds
        if (_showInstructions)
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLowOnEggs
                        ? Colors.red.shade900.withValues(alpha: 0.85)
                        : Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                    border: isLowOnEggs
                        ? Border.all(color: Colors.red, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    isLowOnEggs
                        ? '⚠️ Low on eggs! Stop critters to earn more!'
                        : '🐔 Tap chicken (1 egg) or 🪿 goose (2 eggs) to throw!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isLowOnEggs ? FontWeight.bold : FontWeight.w500,
                      color:
                          isLowOnEggs ? Colors.white : const Color(0xFFB8D4B8),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Low eggs warning - only shows when instructions are hidden AND eggs are low
        if (!_showInstructions && isLowOnEggs)
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1.5),
                ),
                child: const Text(
                  '⚠️ Low on eggs!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

        // Bottom: Attack buttons - positioned outside play area
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomPadding + 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Chicken Attack Button
              _AttackButton(
                label: '🐔',
                subLabel: '1 egg',
                color: const Color(0xFFFF8A65),
                enabled: gameState.eggs >= 1,
                onPressed: () => widget.game.fireChicken(),
              ),
              // Goose Attack Button
              _AttackButton(
                label: '🪿',
                subLabel: '2 eggs',
                color: const Color(0xFF81C784),
                enabled: gameState.eggs >= 2,
                onPressed: () => widget.game.fireGoose(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Attack button widget for triggering tower attacks
class _AttackButton extends StatelessWidget {
  final String label;
  final String subLabel;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const _AttackButton({
    required this.label,
    required this.subLabel,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.85)
              : Colors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                enabled ? color : Colors.grey.shade600,
            width: 2,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 28,
                color: enabled ? Colors.white : Colors.white54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: enabled ? Colors.white : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
