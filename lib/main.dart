import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/event/event_bloc.dart';
import 'services/auth_service.dart';
import 'services/event_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/organizer/dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isFirebaseInitialized = false;
  String initErrorMessage = '';

  try {
    // Note: This requires flutterfire configure to be run by the user.
 await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
    isFirebaseInitialized = true;
  } catch (e) {
    isFirebaseInitialized = false;
    initErrorMessage = e.toString();
  }

  runApp(AttendlyApp(
    isFirebaseInitialized: isFirebaseInitialized,
    initErrorMessage: initErrorMessage,
  ));
}

class AttendlyApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  final String initErrorMessage;

  const AttendlyApp({
    super.key,
    required this.isFirebaseInitialized,
    required this.initErrorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFirebaseInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Firebase Initialization Failed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please run `flutterfire configure` to connect the app to your Firebase project.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    initErrorMessage,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        RepositoryProvider<EventService>(
          create: (context) => EventService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
            ),
          ),
          BlocProvider<EventBloc>(
            create: (context) => EventBloc(
              eventService: context.read<EventService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Attendly',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is Authenticated) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
