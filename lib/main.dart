import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportsync/core/router/app_router.dart';
import 'package:sportsync/core/theme/app_colors.dart';
import 'package:sportsync/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase not yet configured for this platform (e.g. iOS).
    // Run FlutterFire CLI to add platform support: `flutterfire configure`
    debugPrint('Firebase init skipped: $e');
  }
  runApp(
    const ProviderScope(
      child: SportSyncApp(),
    ),
  );
}

class SportSyncApp extends ConsumerWidget {
  const SportSyncApp({super.key});

  // Apple system font stack. iOS/macOS resolve to SF Pro; web uses the CSS
  // system font; Android falls through to Roboto via fontFamilyFallback.
  static const String _fontFamily = '-apple-system';
  static const List<String> _fontFallback = [
    'BlinkMacSystemFont',
    'SF Pro Text',
    'SF Pro Display',
    'system-ui',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.white,
        onSurface: const Color(0xFF1A1A1A),
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      useMaterial3: true,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
    );

    // Re-derive the text theme so every Material widget inherits the
    // system font + our weight conventions. AppTextStyles still applies on
    // top for explicit usage.
    final textTheme = base.textTheme.apply(
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
    );

    return MaterialApp.router(
      title: 'SportSync',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: base.copyWith(
        textTheme: textTheme.copyWith(
          // Display tier — heavy, tight tracking
          displayLarge: textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
          ),
          displayMedium: textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
          displaySmall: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
          // Headlines
          headlineLarge: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
          headlineMedium: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          headlineSmall: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          // Titles (used by AppBars, list tile headers, etc.)
          titleLarge: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleMedium: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleSmall: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          // Body — readable, lighter weight
          bodyLarge: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          bodySmall: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          // Labels — buttons, chips
          labelLarge: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          labelMedium: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          labelSmall: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
