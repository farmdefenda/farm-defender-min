import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen.dart';
import 'free_roam_game_screen.dart';
import 'how_to_play_screen.dart';
import '../state/game_state.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    final titleSize = isPortrait ? 32.0 : 42.0;
    final spacing = isPortrait ? 30.0 : 60.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a2f1a), Color(0xFF2d4a2d), Color(0xFF1a3a1a)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title with Fredoka game font
                  Text(
                    '🐔 FARM DEFENDER 🐔',
                    style: GoogleFonts.fredoka(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD93D),
                      shadows: const [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(3, 3),
                        ),
                        Shadow(
                          blurRadius: 20,
                          color: Color(0xFF4a7c3f),
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Protect your farm from critters!',
                    style: GoogleFonts.fredoka(
                      fontSize: isPortrait ? 14 : 18,
                      color: const Color(0xFFB8D4B8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Game Mode Selection
                  _MenuButton(
                    icon: Icons.shield_rounded,
                    label: 'TOWER DEFENSE',
                    color: const Color(0xFF4CAF50),
                    subtitle: 'Tap towers to throw eggs',
                    onPressed: () {
                      // Reset game state and start fresh
                      ref
                          .read(gameProvider.notifier)
                          .startLevel(1, mode: GameMode.towerDefense);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    icon: Icons.touch_app_rounded,
                    label: 'FREE ROAM',
                    color: const Color(0xFFE91E63),
                    subtitle: 'Drag & intercept critters',
                    onPressed: () {
                      // Reset game state and start fresh
                      ref
                          .read(gameProvider.notifier)
                          .startLevel(1, mode: GameMode.freeRoam);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FreeRoamGameScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _MenuButton(
                    icon: Icons.help_outline_rounded,
                    label: 'HOW TO PLAY',
                    color: const Color(0xFF2196F3),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HowToPlayScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _MenuButton(
                    icon: Icons.info_outline_rounded,
                    label: 'ABOUT',
                    color: const Color(0xFFFF9800),
                    onPressed: () {
                      _showAboutDialog(context);
                    },
                  ),

                  SizedBox(height: spacing),

                  // Farm facts
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4a7c3f),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Farm Fact: Chickens can recognize over 100 different faces!',
                            style: GoogleFonts.fredoka(
                              color: const Color(0xFFB8D4B8),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d4a2d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🌾 About Farm Defender',
          style: TextStyle(color: Color(0xFFFFD93D)),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A farm defense game where you protect your farm from mischievous foxes and wolves!',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text('Version 1.0.0', style: TextStyle(color: Color(0xFFB8D4B8))),
            Text(
              'Built with Flutter & Flame',
              style: TextStyle(color: Color(0xFFB8D4B8)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final String? subtitle;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null;
    return SizedBox(
      width: 280,
      height: hasSubtitle ? 70 : 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: color.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                if (hasSubtitle)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
