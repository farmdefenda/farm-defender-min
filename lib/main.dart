import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Full screen mode
  await Flame.device.fullScreen();

  // Allow both portrait and landscape orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Immersive mode for better gameplay
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const ProviderScope(child: FarmDefenderApp()));
}

class FarmDefenderApp extends ConsumerWidget {
  const FarmDefenderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using Fredoka One - a fun, rounded game font
    // 100% free for commercial use (OFL license)
    final textTheme = GoogleFonts.fredokaTextTheme(ThemeData.dark().textTheme);

    return MaterialApp(
      title: 'Farm Defender Mini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4a7c3f),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: textTheme,
      ),
      home: const MainMenuScreen(),
    );
  }
}
