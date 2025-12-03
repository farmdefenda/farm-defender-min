import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/farm_defender_game.dart';
import '../state/game_state.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/pause_menu_overlay.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late FarmDefenderGame _game;

  @override
  void initState() {
    super.initState();
    // Always create a fresh game instance
    _game = FarmDefenderGame(ref.read(gameProvider.notifier));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'HUD': (BuildContext context, FarmDefenderGame game) {
            return HUDOverlay(game: game);
          },
          'GameOver': (BuildContext context, FarmDefenderGame game) {
            return GameOverOverlay(game: game);
          },
          'PauseMenu': (BuildContext context, FarmDefenderGame game) {
            return PauseMenuOverlay(game: game);
          },
          'Victory': (BuildContext context, FarmDefenderGame game) {
            return VictoryOverlay(game: game);
          },
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}

