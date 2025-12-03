import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/farm_defender_game.dart';
import '../state/game_state.dart';
import '../screens/main_menu_screen.dart';
import '../screens/game_screen.dart';

class PauseMenuOverlay extends ConsumerWidget {
  final FarmDefenderGame game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2d4a2d), Color(0xFF1a3a1a)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF4a7c3f), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⏸️ PAUSED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD93D),
                ),
              ),
              const SizedBox(height: 32),

              _PauseButton(
                icon: Icons.play_arrow_rounded,
                label: 'RESUME',
                color: const Color(0xFF4CAF50),
                onPressed: () => game.resumeGame(),
              ),
              const SizedBox(height: 12),
              _PauseButton(
                icon: Icons.refresh_rounded,
                label: 'RESTART',
                color: const Color(0xFFFF9800),
                onPressed: () {
                  ref.read(gameProvider.notifier).reset();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _PauseButton(
                icon: Icons.home_rounded,
                label: 'MAIN MENU',
                color: const Color(0xFF2196F3),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _PauseButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

