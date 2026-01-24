import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trippified/core/config/env_config.dart';
import 'package:trippified/core/services/supabase_service.dart';
import 'package:trippified/core/theme/app_theme.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase (if configured)
  if (EnvConfig.isConfigured) {
    await SupabaseService.instance.initialize();
  } else {
    debugPrint('Warning: Supabase not configured. Running in demo mode.');
    debugPrint('Missing: ${EnvConfig.missingConfigurations.join(', ')}');
  }

  runApp(const ProviderScope(child: TrippifiedApp()));
}

/// Root widget for the Trippified app
class TrippifiedApp extends StatelessWidget {
  const TrippifiedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trippified',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
