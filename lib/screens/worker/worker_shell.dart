import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../sign_in_screen.dart';

// Get the device location, requesting permission if needed. Returns null (and
// shows a message) if unavailable.
Future<Position?> getLocation(BuildContext context) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turn on location services')));
    return null;
  }
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
  if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
    return null;
  }
  // Try a fresh fix but don't hang forever (emulator GPS can stall); fall back
  // to the last known position.
  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 8)),
    );
  } catch (_) {
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) return last;
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not get your location')));
    return null;
  }
}

// ---- shared helpers ---------------------------------------------------------
String naira(dynamic n) {
  final v = (n is num) ? n : num.tryParse('$n') ?? 0;
  final s = v.toStringAsFixed(0);
  return '₦${s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
}

Color _statusColor(String? s) {
  switch (s) {
    case 'approved':
    case 'verified':
    case 'tier_approved':
    case 'available':
      return AppColors.success;
    case 'pending':
    case 'submitted':
      return AppColors.orange;
    case 'rejected':
    case 'expired':
      return AppColors.danger;
    default:
      return AppColors.text2;
  }
}

Widget pill(String? text) {
  final t = (text ?? '').replaceAll('_', ' ');
  if (t.isEmpty) return const SizedBox.shrink();
  final c = _statusColor(text);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(999)),
    child: Text(t, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

Widget card({required Widget child, EdgeInsets? padding}) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );

// ---- shell ------------------------------------------------------------------
class WorkerShell extends StatefulWidget {
  const WorkerShell({super.key});
  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      WorkerTasksScreen(),
      WorkerApplicationsScreen(),
      WorkerWalletScreen(),
      WorkerProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0x2EFBAC34),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work, color: AppColors.navy), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment, color: AppColors.navy), label: 'Applied'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.navy), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.navy), label: 'Profile'),
        ],
      ),
    );
  }
}

// Common page scaffold: title + pull-to-refresh future list.
class _Page extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget child;
  const _Page({required this.eyebrow, required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Text(eyebrow.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 1, color: AppColors.text3, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(title, style: AppText.serif(size: 34)),
        const SizedBox(height: 18),
        child,
      ],
    );
  }
}

Widget _loading() => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
Widget _error(String m) => card(child: Text(m, style: const TextStyle(color: AppColors.danger)));
Widget _empty(String m) => card(child: Text(m, style: const TextStyle(color: AppColors.text3)));

// ---- Tasks (browse + apply) -------------------------------------------------
class WorkerTasksScreen extends StatefulWidget {
  const WorkerTasksScreen({super.key});
  @override
  State<WorkerTasksScreen> createState() => _WorkerTasksScreenState();
}

class _WorkerTasksScreenState extends State<WorkerTasksScreen> {
  late Future<List> _future;
  @override
  void initState() {
    super.initState();
    _future = ApiService.openTasks();
  }

  void _reload() => setState(() => _future = ApiService.openTasks());

  Future<void> _apply(Map task) async {
    final pitch = await showDialog<String>(
      context: context,
      builder: (_) => _PitchDialog(taskTitle: task['title']),
    );
    if (pitch == null) return;
    try {
      await ApiService.applyToTask(task['id'], pitch);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application sent')));
        _reload();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      eyebrow: 'Find work',
      title: 'Open tasks',
      child: FutureBuilder<List>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return _loading();
          if (snap.hasError) return _error('${snap.error}'.replaceAll('Exception: ', ''));
          final tasks = snap.data ?? [];
          if (tasks.isEmpty) return _empty('No open tasks right now.');
          return Column(
            children: tasks.map((t) {
              final applied = t['applied'] == true;
              final remote = t['is_remote'] == true;
              final pay = t['pay_model'] == 'hourly' ? '${naira(t['rate'])}/hr' : naira(t['rate']);
              return card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(t['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text))),
                      if (t['tier_match'] == true) pill('match'),
                    ]),
                    const SizedBox(height: 4),
                    Text('${remote ? 'Remote' : (t['location'] ?? '')} · $pay',
                        style: const TextStyle(fontSize: 13, color: AppColors.text3)),
                    if ((t['description'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(t['description'], style: const TextStyle(fontSize: 13, color: AppColors.text2)),
                    ],
                    const SizedBox(height: 12),
                    Row(children: [
                      pill(t['required_tier']),
                      const Spacer(),
                      applied
                          ? pill('applied')
                          : SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () => _apply(t),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.navy, foregroundColor: Colors.white, elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: const Text('Apply'),
                              ),
                            ),
                    ]),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _PitchDialog extends StatefulWidget {
  final String taskTitle;
  const _PitchDialog({required this.taskTitle});
  @override
  State<_PitchDialog> createState() => _PitchDialogState();
}

class _PitchDialogState extends State<_PitchDialog> {
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Apply: ${widget.taskTitle}', style: const TextStyle(fontSize: 16)),
      content: TextField(
        controller: _c,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Short pitch / availability (optional)', border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _c.text),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white),
          child: const Text('Send'),
        ),
      ],
    );
  }
}

// ---- My applications --------------------------------------------------------
class WorkerApplicationsScreen extends StatefulWidget {
  const WorkerApplicationsScreen({super.key});
  @override
  State<WorkerApplicationsScreen> createState() => _WorkerApplicationsScreenState();
}

class _WorkerApplicationsScreenState extends State<WorkerApplicationsScreen> {
  late Future<List> _future; // [applications, activeSession]
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List> _load() async {
    final apps = await ApiService.myApplications();
    final active = await ApiService.activeSession();
    return [apps, active];
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _clockIn(Map app) async {
    setState(() => _busy = true);
    try {
      final pos = await getLocation(context);
      if (pos == null) return;
      final res = await ApiService.clockIn(app['task_id'], pos.latitude, pos.longitude);
      if (mounted) {
        final fenced = res['within_geofence'] == true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(fenced ? 'Clocked in (inside geofence)' : 'Clocked in')));
        _reload();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clockOut() async {
    setState(() => _busy = true);
    try {
      final pos = await getLocation(context);
      final res = await ApiService.clockOut(pos?.latitude ?? 0, pos?.longitude ?? 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Clocked out · ${res['hours']}h logged for approval')));
        _reload();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      eyebrow: 'My work',
      title: 'Applications',
      child: FutureBuilder<List>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return _loading();
          if (snap.hasError) return _error('${snap.error}'.replaceAll('Exception: ', ''));
          final apps = (snap.data?[0] ?? []) as List;
          final active = (snap.data?[1] ?? {}) as Map;
          final activeTaskId = active['active'] == true ? active['task_id'] : null;
          return Column(children: [
            if (activeTaskId != null) _activeCard(active),
            if (apps.isEmpty) _empty('You haven\'t applied to any tasks yet.'),
            ...apps.map((a) {
              final pay = a['pay_model'] == 'hourly' ? '${naira(a['rate'])}/hr' : naira(a['rate']);
              final approved = a['status'] == 'approved';
              final isActiveHere = activeTaskId == a['task_id'];
              return card(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a['task_title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
                      const SizedBox(height: 3),
                      Text('${a['location'] ?? 'remote'} · $pay', style: const TextStyle(fontSize: 13, color: AppColors.text3)),
                    ])),
                    pill(a['status']),
                  ]),
                  if (approved && !isActiveHere && activeTaskId == null) ...[
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, height: 40, child: ElevatedButton.icon(
                      onPressed: _busy ? null : () => _clockIn(a),
                      icon: const Icon(Icons.location_on_outlined, size: 18),
                      label: const Text('Clock in'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    )),
                  ],
                ]),
              );
            }),
          ]);
        },
      ),
    );
  }

  Widget _activeCard(Map active) {
    final mins = (active['elapsed_minutes'] ?? 0) as int;
    final hrs = mins ~/ 60, rem = mins % 60;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          const Text('CLOCKED IN', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (active['within_geofence'] == true) pill('verified'),
        ]),
        const SizedBox(height: 10),
        Text(active['task_title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text('${hrs}h ${rem}m elapsed', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, height: 42, child: ElevatedButton(
          onPressed: _busy ? null : _clockOut,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: AppColors.navy, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Clock out', style: TextStyle(fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }
}

// ---- Wallet -----------------------------------------------------------------
class WorkerWalletScreen extends StatefulWidget {
  const WorkerWalletScreen({super.key});
  @override
  State<WorkerWalletScreen> createState() => _WorkerWalletScreenState();
}

class _WorkerWalletScreenState extends State<WorkerWalletScreen> {
  late Future<Map<String, dynamic>> _future;
  @override
  void initState() {
    super.initState();
    _future = ApiService.myWallet();
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      eyebrow: 'Earnings',
      title: 'Wallet',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return _loading();
          if (snap.hasError) return _error('${snap.error}'.replaceAll('Exception: ', ''));
          final b = (snap.data?['balances'] ?? {}) as Map;
          final txns = (snap.data?['transactions'] ?? []) as List;
          return Column(children: [
            card(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('AVAILABLE', style: TextStyle(fontSize: 11, letterSpacing: 1, color: AppColors.text3, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(naira(b['available']), style: AppText.serif(size: 40)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _balCol('Pending', naira(b['pending']))),
                  Expanded(child: _balCol('Withdrawn', naira(b['withdrawn']))),
                ]),
              ]),
            ),
            const SizedBox(height: 4),
            const Align(alignment: Alignment.centerLeft, child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Recent transactions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text2)),
            )),
            if (txns.isEmpty) _empty('No transactions yet.'),
            ...txns.map((t) => card(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text((t['type'] ?? '').toString().toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                      if ((t['note'] ?? '').toString().isNotEmpty)
                        Text(t['note'], style: const TextStyle(fontSize: 12, color: AppColors.text3)),
                    ])),
                    Text(naira(t['amount']),
                        style: TextStyle(fontWeight: FontWeight.w600,
                            color: (num.tryParse('${t['amount']}') ?? 0) < 0 ? AppColors.danger : AppColors.success)),
                  ]),
                )),
          ]);
        },
      ),
    );
  }

  Widget _balCol(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 0.5, color: AppColors.text3, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
      ]);
}

// ---- Profile (KYC + notifications + logout) ---------------------------------
class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});
  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  late Future<List> _future; // [me, notifications]
  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List> _load() async {
    final me = await ApiService.getCurrentUser();
    final notifs = await ApiService.myNotifications();
    return [me['user'] ?? {}, notifs];
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _completeKyc() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => const _KycDialog());
    if (ok == true) _reload();
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Page(
      eyebrow: 'Account',
      title: 'Profile',
      child: FutureBuilder<List>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return _loading();
          if (snap.hasError) return _error('${snap.error}'.replaceAll('Exception: ', ''));
          final me = (snap.data?[0] ?? {}) as Map;
          final notifs = (snap.data?[1] ?? []) as List;
          final kyc = me['kyc_status'] as String?;
          final verified = kyc == 'verified' || kyc == 'tier_approved';
          return Column(children: [
            card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _row('Name', me['name'] ?? '—'),
              _row('Email', me['email'] ?? '—'),
              _row('Tier', (me['tier'] ?? 'not set').toString()),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('KYC', style: TextStyle(color: AppColors.text2)),
                pill(kyc),
              ]),
              if (!verified) ...[
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
                  onPressed: _completeKyc,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white, elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Complete KYC verification'),
                )),
              ],
            ])),
            const Align(alignment: Alignment.centerLeft, child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text2)),
            )),
            if (notifs.isEmpty) _empty('Nothing yet.'),
            ...notifs.map((n) => card(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n['title'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                    if ((n['body'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(n['body'], style: const TextStyle(fontSize: 13, color: AppColors.text3)),
                    ],
                  ]),
                )),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, height: 44, child: OutlinedButton(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.border)),
              child: const Text('Log out'),
            )),
          ]);
        },
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k, style: const TextStyle(color: AppColors.text2)),
          Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.text))),
        ]),
      );
}

class _KycDialog extends StatefulWidget {
  const _KycDialog();
  @override
  State<_KycDialog> createState() => _KycDialogState();
}

class _KycDialogState extends State<_KycDialog> {
  final _id = TextEditingController();
  final _tin = TextEditingController();
  final _bankName = TextEditingController();
  final _bankAcct = TextEditingController();
  String _tier = 'student';
  bool _busy = false;
  String? _err;

  Future<void> _submit() async {
    setState(() { _busy = true; _err = null; });
    try {
      final res = await ApiService.submitKyc({
        'id_number': _id.text.trim(),
        'tin': _tin.text.trim(),
        'bank_name': _bankName.text.trim(),
        'bank_account': _bankAcct.text.trim(),
        'tier': _tier,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('KYC ${res['kyc_status']}')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() { _err = '$e'.replaceAll('Exception: ', ''); _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('KYC verification', style: TextStyle(fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _f(_id, 'ID number (NIN/BVN)'),
          _f(_tin, 'Tax ID (TIN)'),
          _f(_bankName, 'Bank code'),
          _f(_bankAcct, 'Account number'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _tier,
            decoration: const InputDecoration(labelText: 'Worker tier', border: OutlineInputBorder()),
            items: const ['student', 'rider', 'remote', 'promo', 'trade']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _tier = v ?? 'student'),
          ),
          if (_err != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_err!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
        ]),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white),
          child: Text(_busy ? 'Submitting…' : 'Submit'),
        ),
      ],
    );
  }

  Widget _f(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(controller: c, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true)),
      );
}
