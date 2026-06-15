import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'create_task_screen.dart';
import 'payments_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State createState() => _HomeShellState();
}

class _HomeShellState extends State {
  int _index = 0;

  final _titles = ['Dashboard', 'New Task', 'Payments'];

  @override
  Widget build(BuildContext context) {
    // Dashboard already has its own AppBar; the others get a simple one.
    final bodies = [
      const DashboardScreen(),
      const _Scaffolded(title: 'New Task', child: CreateTaskScreen()),
      const _Scaffolded(title: 'Payments', child: PaymentsScreen()),
    ];

    return Scaffold(
      body: bodies[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0x2EFBAC34),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.navy),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.add_box_outlined),
              selectedIcon: Icon(Icons.add_box, color: AppColors.navy),
              label: 'New Task'),
          NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments, color: AppColors.navy),
              label: 'Payments'),
        ],
      ),
    );
  }
}

/// Wraps a screen that needs a simple title bar.
class _Scaffolded extends StatelessWidget {
  final String title;
  final Widget child;
  const _Scaffolded({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(title,
            style: AppText.serif(size: 20, color: Colors.white)),
      ),
      body: child,
    );
  }
}
