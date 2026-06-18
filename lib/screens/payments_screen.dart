import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../data/mock_data.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final Set<int> _released = {};

  @override
  Widget build(BuildContext context) {
    final pending = [
      for (var i = 0; i < payments.length; i++)
        if (!_released.contains(i)) payments[i]
    ];
    final totalAwaiting = pending.fold<int>(
        0,
        (sum, p) =>
            sum +
            int.parse(p.amount.replaceAll('₦', '').replaceAll(',', '')));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total awaiting release
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AWAITING RELEASE',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('₦${totalAwaiting.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}',
                    style: AppText.serif(size: 34, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pending payments
          SectionCard(
            title: 'Pending · ${pending.length}',
            child: Column(
              children: pending
                  .asMap()
                  .entries
                  .map((entry) {
                    final idx = entry.key;
                    final origIdx = payments.indexOf(entry.value);
                    final p = entry.value;
                    final isReleased = _released.contains(origIdx);
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: idx < pending.length - 1 ? 12 : 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.navy)),
                                const SizedBox(height: 4),
                                Text(p.detail,
                                    style: const TextStyle(
                                        fontSize: 13, color: AppColors.text2)),
                                const SizedBox(height: 8),
                                Text(p.amount,
                                    style: AppText.serif(
                                        size: 16, color: AppColors.navy)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: isReleased
                                ? null
                                : () =>
                                    setState(() => _released.add(origIdx)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              p.note == 'review first'
                                  ? 'Review & release'
                                  : 'Release payment',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // This week — chart + tax summary
          SectionCard(
            title: 'This week · all categories',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weeklySpend.map((d) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 120 * d.pct / 100,
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(d.day,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.text3)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
    );
  }

  Widget _fact(String value, String label) {
    return Row(
      children: [
        Text(value, style: AppText.serif(size: 22)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 14, color: AppColors.text2)),
      ],
    );
  }
}
