import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/auth/auth_bloc.dart';
import '../injection.dart';
import 'routes/router.gr.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => 
            getIt<AuthBloc>()..add(const AuthEvent.authCheckRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.green[800],
          colorScheme: ThemeData().colorScheme.copyWith(secondary: Colors.blueAccent),
          appBarTheme: ThemeData.light().appBarTheme.copyWith(
            brightness: Brightness.dark,
            color: Colors.green[800],
            iconTheme: ThemeData.dark().iconTheme,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue[900],
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        routeInformationParser: router.defaultRouteParser(), 
        routerDelegate: AutoRouterDelegate(router)
      ),
    );
  }
}