import 'package:flutter/material.dart';
import 'package:sophos/Screens/HomePage.dart';
import 'package:sophos/Screens/Register.dart';
import 'package:sophos/Screens/Welcome.dart';
import 'package:sophos/Sophos%20Logger/local_storage.dart';
import 'package:sophos/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc()..add(AppStarted()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        
         home: Scaffold(body: AppEntryPoint())),
        // 
      
    );
  }
}

class AppEntryPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle any side effects if needed
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AuthShowWelcomeState) {
            return const WelcomeScreen();
          }

          if (state is InfoCompleted || 
              state is HosteLoggedIn || 
              state is HostelLoggedOut || 
              state is AcademicLoggedIn || 
              state is AcademicLoggedOut ||
              state is HostelAuthenticating ||
              state is AcademicAuthenticating ||
              state is LoginFailed 
             ) {
            return const HomePage();
          }
          
          // AuthUnauthenticatedState or errors
          return const FillInfoScreen();
        },
      ),
    );
  }
}
