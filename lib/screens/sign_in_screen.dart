import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  void _enter(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Brand mark
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('A', style: AppText.serif(size: 24)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('AfriZone',
                              style: AppText.serif(size: 22, color: AppColors.navy)),
                          Text('Mart',
                              style: AppText.serif(size: 22, color: AppColors.orange)),
                        ],
                      ),
                      const Text('Made in Africa, delivered worldwide',
                          style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppColors.text3)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 56),

              // Heading
              Text('Welcome back.', style: AppText.serif(size: 38)),
              const SizedBox(height: 8),
              const Text('Sign in to manage tasks, applications and payments.',
                  style: TextStyle(fontSize: 15, color: AppColors.text2)),

              const SizedBox(height: 32),

              // Email
              const Text('Work email',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.text2,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _field(hint: 'you@afrizone.com'),

              const SizedBox(height: 18),

              // Password
              const Text('Password',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.text2,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _field(hint: '••••••••••', obscure: true),

              const SizedBox(height: 28),

              // Sign in button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _enter(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Sign in',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text('Protected with two-factor authentication',
                    style: TextStyle(fontSize: 12, color: AppColors.text3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({required String hint, bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.text3),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
      ),
    );
  }
}
