import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../data/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Row(
          children: [
            Text('AfriZone', style: AppText.serif(size: 20, color: Colors.white)),
            Text('Mart', style: AppText.serif(size: 20, color: AppColors.orange)),
          ],
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white70),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            const Text('TUESDAY, 9 JUNE',
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: AppColors.accent2,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Good morning, Adaeze.', style: AppText.serif(size: 30)),
            const SizedBox(height: 6),
            const Text(
                '12 applications and 8 payments are waiting on you today.',
                style: TextStyle(fontSize: 15, color: AppColors.text2)),
            const SizedBox(height: 20),

            // Alert
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x1FFBAC34),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x66FBAC34)),
              ),
              child: const Text(
                  '⚠️  3 applications are over 48 hours old and expire in 6 hours.',
                  style: TextStyle(fontSize: 13, color: AppColors.text)),
            ),
            const SizedBox(height: 20),

            // Stats — 2x2 grid
            Row(
              children: const [
                Expanded(child: StatCard(label: 'Active tasks', value: '34')),
                SizedBox(width: 12),
                Expanded(child: StatCard(label: 'To review', value: '12')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: StatCard(label: 'Awaiting release', value: '₦486k')),
                SizedBox(width: 12),
                Expanded(child: StatCard(label: 'Fill rate', value: '84%')),
              ],
            ),
            const SizedBox(height: 20),

            // Applications
            SectionCard(
              title: 'Applications awaiting review',
              child: Column(
                children: applications.map((a) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.orange,
                          child: Text(
                            a.name.split(' ').map((w) => w[0]).take(2).join(),
                            style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(a.detail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.text3)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TierBadge(a.tier),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Payments
            SectionCard(
              title: 'Payments awaiting release',
              child: Column(
                children: payments.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(p.detail,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.text3)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(p.amount, style: AppText.serif(size: 18)),
                            Text(p.note,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.accent2,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Attention flags
            SectionCard(
              title: 'Needs your attention',
              child: Column(
                children: flags.map((f) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0x21D6493C),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.warning_amber_rounded,
                              size: 16, color: AppColors.danger),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(f,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.text)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
