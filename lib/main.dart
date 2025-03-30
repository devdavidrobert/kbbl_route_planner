// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';
import 'injection.dart' as di;
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/route_plan/route_plan_bloc.dart';
import 'presentation/blocs/sales/sales_bloc.dart';
import 'presentation/pages/login_page.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure logging with more detail
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
      if (record.stackTrace != null) {
        print('Stack trace:\n${record.stackTrace}');
      }
    }
  });

  final logger = Logger('main');
  logger.info('Starting application');

  try {
    logger.info('Initializing Firebase');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Auth and wait for it to be ready
    await Future.delayed(const Duration(milliseconds: 100));
    FirebaseAuth.instance;
    await Future.delayed(const Duration(milliseconds: 100));

    logger.info('Firebase initialized successfully');

    logger.info('Initializing dependencies');
    await di.init();
    logger.info('Dependencies initialized successfully');

    runApp(MyApp());
  } catch (e, stackTrace) {
    logger.severe('Error during initialization', e, stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final _logger = Logger('MyApp');

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.getIt<AuthBloc>()),
        BlocProvider(create: (_) => di.getIt<SalesBloc>()),
        BlocProvider(create: (_) => di.getIt<RoutePlanBloc>()),
      ],
      child: MaterialApp(
        title: 'Sales App',
        theme: ThemeData(primarySwatch: Colors.blue),
        navigatorKey: navigatorKey,
        onGenerateRoute: AppRoutes.generateRoute,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              _logger.severe('Firebase auth state error: ${snapshot.error}');
              return const LoginPage();
            }

            if (snapshot.connectionState == ConnectionState.active) {
              final user = snapshot.data;
              if (user == null) {
                _logger.info('No user signed in');
                return const LoginPage();
              }

              _logger.info('User signed in: ${user.email}');
              
              return BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  _logger.info('AuthBloc state changed: $state');
                  if (state is AuthSuccess) {
                    _logger.info('Navigating to HomePage for user: ${state.profile.userId}');
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (_) => false,
                      arguments: {
                        'userId': state.profile.userId,
                        'region': state.profile.region,
                        'territory': state.profile.territory,
                      },
                    );
                  } else if (state is AuthNeedsProfile) {
                    _logger.info('Navigating to ProfileUpdatePage for user: ${state.user.id}');
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      AppRoutes.profileUpdate,
                      (_) => false,
                      arguments: {'user': state.user},
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is AuthFailure) {
                    return Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${state.message}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<AuthBloc>()
                                    .add(SignInWithGooglePressed());
                              },
                              child: const Text('Retry'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                              },
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              );
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
