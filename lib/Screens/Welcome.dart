import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // same soft background
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),

            // App Title
            Text(
              'Welcome to',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A2647),
                  ),
            ),
            const SizedBox(height: 8),

            Text(
              'VIT WiFi Logger',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF144272),
                  ),
            ),
            const SizedBox(height: 16),

            // Subtitle / Tagline
            Text(
              'Log in to VIT WiFi easily\nand manage your access hassle-free.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
            ),

            const Spacer(),

            // Next Button
            GestureDetector(
              onTap: () {
                context.read<AuthBloc>().add(CompleteWelcomeEvent());
              },
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF144272),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
