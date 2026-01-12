import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart' as di;
import 'core/router/app_router.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/signup/presentation/bloc/signup_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<SignupBloc>(create: (_) => di.sl<SignupBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Cadenca',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B82F6), // Sky Blue - Aviation & Medical
            primary: const Color(0xFF3B82F6),
            secondary: const Color(0xFF10B981), // Emerald - Health & Recovery
            tertiary: const Color(0xFFF59E0B), // Amber - Alerts & Warnings
            error: const Color(0xFFEF4444), // Red - Critical Alerts
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(
            0xFFF8FAFC,
          ), // Clean Medical White
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B82F6), // Sky Blue
            primary: const Color(0xFF60A5FA), // Soft Blue - Night-friendly
            secondary: const Color(0xFF10B981), // Emerald
            tertiary: const Color(0xFFF59E0B), // Amber
            error: const Color(0xFFEF4444), // Red
            surface: const Color(0xFF1E293B), // Slate - Cockpit Dark
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(
            0xFF0A0E1A,
          ), // Deep Navy - Night Sky
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
