import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '📖 How to Play',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD93D),
                      ),
                    ),
                  ],
                ),
              ),

              // Instructions
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _InstructionCard(
                        icon: '🎯',
                        title: 'Objective',
                        description:
                            'Defend your farm! Stop foxes and wolves from crossing your land. If they reach the exit, you lose lives.',
                      ),
                      const SizedBox(height: 16),
                      _InstructionCard(
                        icon: '🐔',
                        title: 'Chicken Tower',
                        description:
                            'Your basic defender. Throws eggs at critters. Fast throw rate, moderate stopping power. Perfect for quick foxes!',
                      ),
                      const SizedBox(height: 16),
                      _InstructionCard(
                        icon: '🪿',
                        title: 'Goose Tower',
                        description:
                            'The heavy hitter! Slower but has massive stopping power. Great for tough wolves.',
                      ),
                      const SizedBox(height: 16),
                      _InstructionCard(
                        icon: '🦊',
                        title: 'Fox Critter (2 egg reward)',
                        description:
                            'Fast but easy to stop. They dart across the path quickly. Use chickens to catch them!',
                      ),
                      const SizedBox(height: 16),
                      _InstructionCard(
                        icon: '🐺',
                        title: 'Wolf Critter (4 egg reward)',
                        description:
                            'Slow but sturdy. They take many hits to stop. Use geese to chase them away!',
                      ),
                      const SizedBox(height: 16),
                      _InstructionCard(
                        icon: '👆',
                        title: 'Controls',
                        description:
                            '1. Tap tower to SELECT it (shows range)\n2. Tap selected tower to THROW eggs at nearest critter!\n3. Keep tapping to throw more eggs!',
                      ),
                      const SizedBox(height: 16),
                      _InstructionCard(
                        icon: '💡',
                        title: 'Tips',
                        description:
                            '• Chickens throw fast, Geese hit hard\n• Keep tapping selected towers to throw!\n• Watch critter energy bars\n• Earn eggs by stopping critters',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _InstructionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4a7c3f), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD93D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB8D4B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

