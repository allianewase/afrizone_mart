import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/sign_in_screen.dart';

void main() {
  runApp(const AfrizoneAdminApp());
}

class AfrizoneAdminApp extends StatelessWidget {
  const AfrizoneAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfriZoneMart Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SignInScreen(),
    );
  }
}
