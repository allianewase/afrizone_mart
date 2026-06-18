import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'home_shell.dart';
import 'worker/worker_shell.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (result['success']) {
        // Route by role: staff -> admin shell, workers -> worker shell.
        final role = (result['user']?['role'] ?? 'worker') as String;
        final isStaff = role == 'task_manager' || role == 'hr_admin' || role == 'super_admin';
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => isStaff ? const HomeShell() : const WorkerShell(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Login failed';
          _isLoading = false;
        });
      }
    }
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
                          Text('Afrizone',
                              style: AppText.serif(size: 22, color: AppColors.navy)),
                          Text('Part Time',
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
              _field(hint: 'you@afrizone.com', controller: _emailController),

              const SizedBox(height: 18),

              // Password
              const Text('Password',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.text2,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _field(hint: '••••••••••', controller: _passwordController, obscure: true),

              const SizedBox(height: 28),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),

              // Sign in button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.text3,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Sign in',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text('Workers and managers sign in here.',
                    style: TextStyle(fontSize: 12, color: AppColors.text3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
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
