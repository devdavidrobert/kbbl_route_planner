// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  await Firebase.initializeApp();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<SalesBloc>()),
        BlocProvider(create: (_) => di.sl<RoutePlanBloc>()),
      ],
      child: MaterialApp(
        title: 'Sales App',
        theme: ThemeData(primarySwatch: Colors.blue),
        navigatorKey: navigatorKey,
        onGenerateRoute: AppRoutes.generateRoute,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data == null) {
                return const LoginPage();
              }
              context.read<AuthBloc>().add(AuthLoginRequested());
              return BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  print('AuthBloc state changed: $state');
                  if (state is AuthLoggedOut) {
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        AppRoutes.login, (_) => false);
                  } else if (state is AuthProfileComplete) {
                    print('Navigating to HomePage for user: ${state.user.id}');
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (_) => false,
                      arguments: {'userId': state.user.id},
                    );
                  } else if (state is AuthProfileIncomplete) {
                    print(
                        'Navigating to ProfileUpdatePage for user: ${state.user.id}');
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      AppRoutes.profileUpdate,
                      (_) => false,
                      arguments: {'user': state.user, 'profile': state.profile},
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is AuthError) {
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
                                    .add(AuthLoginRequested());
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
