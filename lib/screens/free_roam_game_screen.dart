import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/free_roam_game.dart';
import '../state/game_state.dart';

class FreeRoamGameScreen extends ConsumerStatefulWidget {
  const FreeRoamGameScreen({super.key});

  @override
  ConsumerState<FreeRoamGameScreen> createState() => _FreeRoamGameScreenState();
}

class _FreeRoamGameScreenState extends ConsumerState<FreeRoamGameScreen> {
  late FreeRoamGame _game;

  @override
  void initState() {
    super.initState();
    // Always create a fresh game instance
    _game = FreeRoamGame(ref.read(gameProvider.notifier));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'HUD': (BuildContext context, FreeRoamGame game) {
            return FreeRoamHUDOverlay(game: game);
          },
          'GameOver': (BuildContext context, FreeRoamGame game) {
            return FreeRoamGameOverOverlay(game: game);
          },
          'PauseMenu': (BuildContext context, FreeRoamGame game) {
            return FreeRoamPauseMenuOverlay(game: game);
          },
          'Victory': (BuildContext context, FreeRoamGame game) {
            return FreeRoamVictoryOverlay(game: game);
          },
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}

/// HUD for Free Roam mode - repositioned to avoid overlapping gameplay
class FreeRoamHUDOverlay extends ConsumerStatefulWidget {
  final FreeRoamGame game;

  const FreeRoamHUDOverlay({super.key, required this.game});

  @override
  ConsumerState<FreeRoamHUDOverlay> createState() => _FreeRoamHUDOverlayState();
}

class _FreeRoamHUDOverlayState extends ConsumerState<FreeRoamHUDOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showTip = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Auto-hide tip after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _fadeController.forward().then((_) {
          if (mounted) {
            setState(() => _showTip = false);
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
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Stack(
      children: [
        // Top-left: Lives and FREE ROAM label - compact and out of the way
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('❤️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '${gameState.lives}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'FREE ROAM',
                    style: TextStyle(
                      color: Colors.orange.shade300,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Top-right: Pause button - with proper safe area
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => widget.game.pauseGame(),
                icon: const Icon(Icons.pause_rounded),
                color: Colors.white,
                iconSize: 28,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ),

        // Bottom-left: Progress counter - compact pill shape
        Positioned(
          left: 8,
          bottom: bottomPadding + 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎯', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '${gameState.crittersStopped} / ${gameState.stopsToWin}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                // Compact progress bar
                SizedBox(
                  width: 60,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: gameState.crittersStopped / gameState.stopsToWin,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        gameState.crittersStopped >= gameState.stopsToWin * 0.8
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Instruction tip - fades out after a few seconds
        if (_showTip)
          Positioned(
            left: 8,
            bottom: bottomPadding + 52,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '👆 Drag chicken & goose to intercept!',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Game Over overlay for Free Roam
class FreeRoamGameOverOverlay extends StatelessWidget {
  final FreeRoamGame game;

  const FreeRoamGameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '😢 GAME OVER 😢',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'The critters got through!',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('BACK TO MENU', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pause menu for Free Roam
class FreeRoamPauseMenuOverlay extends StatelessWidget {
  final FreeRoamGame game;

  const FreeRoamPauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '⏸️ PAUSED',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => game.resumeGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('RESUME', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                game.stopBGM();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('QUIT', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Victory overlay for Free Roam
class FreeRoamVictoryOverlay extends ConsumerWidget {
  final FreeRoamGame game;

  const FreeRoamVictoryOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎉 VICTORY! 🎉',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${gameState.farmLevel.name} Complete!',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Critters Stopped: ${gameState.crittersStopped}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            if (gameState.hasNextLevel) ...[
              ElevatedButton(
                onPressed: () {
                  final notifier = ref.read(gameProvider.notifier);
                  notifier.startLevel(
                    gameState.currentFarmLevel + 1,
                    mode: GameMode.freeRoam,
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const FreeRoamGameScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('NEXT LEVEL', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('BACK TO MENU', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
