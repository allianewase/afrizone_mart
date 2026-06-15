import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../data/mock_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Set<int> _decided = {};

  @override
  Widget build(BuildContext context) {
    final pending = [
      for (var i = 0; i < applications.length; i++)
        if (!_decided.contains(i)) applications[i]
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: Row(
          children: [
            Text('Afrizone', style: AppText.serif(size: 20, color: Colors.white)),
            Text('Part Time', style: AppText.serif(size: 20, color: AppColors.orange)),
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

            // Stats — 2x2 grid with deltas
            Row(
              children: const [
                Expanded(
                    child: StatCard(
                        label: 'Active tasks',
                        value: '34',
                        delta: '▲ 6 this week')),
                SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                        label: 'To review',
                        value: '12',
                        delta: '▼ 2 since yesterday')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                    child: StatCard(
                        label: 'Awaiting release',
                        value: '₦486k',
                        delta: '↔ No change')),
                SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                        label: 'Fill rate',
                        value: '84%',
                        delta: '▲ 3% vs last week')),
              ],
            ),
            const SizedBox(height: 20),

            // Applications with Approve/Skip
            SectionCard(
              title: 'Applications awaiting review',
              action: CardLink('View all →'),
              child: Column(
                children: pending
                    .asMap()
                    .entries
                    .map((e) {
                      final i = e.key;
                      final a = e.value;
                      final origIdx = applications.indexOf(a);
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: i < pending.length - 1 ? 12 : 0),
                        child: Column(
                          children: [
                            Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.orange,
                                    child: Text(
                                      a.name
                                          .split(' ')
                                          .map((w) => w[0])
                                          .take(2)
                                          .join(),
                                      style: const TextStyle(
                                          color: AppColors.navy,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                fontSize: 12,
                                                color: AppColors.text3)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TierBadge(a.tier),
                                ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              SizedBox(
                                height: 34,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _decided.add(origIdx)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.navy,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Approve',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 34,
                                child: TextButton(
                                  onPressed: () =>
                                      setState(() => _decided.add(origIdx)),
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppColors.text2),
                                  child: const Text('Skip',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Payments with "All 8" link
            SectionCard(
              title: 'Payments awaiting release',
              action: const CardLink('All 8 →'),
              child: Column(
                children: payments
                    .map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(p.detail,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.text3)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(p.amount,
                                      style: AppText.serif(size: 18)),
                                  Text(p.note,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.accent2,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ]),
                      );
                    })
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Attention flags
            SectionCard(
              title: 'Needs your attention',
              child: Column(
                children: flags
                    .map((f) {
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
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.warning_amber_rounded,
                                  size: 16, color: AppColors.danger),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(f,
                                    style: const TextStyle(
                                        fontSize: 13, color: AppColors.text))),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Spend chart with facts
            SectionCard(
              title: 'Spend this week · all categories',
              action: const CardLink('Reports →'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weeklySpend
                          .map((d) {
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 120 * d.pct / 100,
                                      decoration: BoxDecoration(
                                        color: AppColors.orange,
                                        borderRadius: const BorderRadius
                                            .vertical(
                                            top: Radius.circular(4)),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(d.day,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.text3)),
                                  ],
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),
                  _fact('₦1.24M', 'released this week'),
                  const SizedBox(height: 10),
                  _fact('₦62k', 'withholding tax recorded'),
                  const SizedBox(height: 10),
                  _fact('84%', 'fill rate'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _fact(String value, String label) {
    return Row(
        children: [
          Text(value, style: AppText.serif(size: 22)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 14, color: AppColors.text2)),
        ]);
  }
}
