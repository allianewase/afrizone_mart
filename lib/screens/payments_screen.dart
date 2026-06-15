import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../data/mock_data.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State {
  // Track which payments have been released (by index).
  final Set<int> _released = {};

  @override
  Widget build(BuildContext context) {
    final pending = [
      for (var i = 0; i < payments.length; i++)
        if (!_released.contains(i)) payments[i],
    ];

    // Parse amounts to calculate total (remove ₦ and ,)
    double total = 0;
    for (var p in pending) {
      final amount = p.amount
          .replaceAll('₦', '')
          .replaceAll(',', '')
          .replaceAll(' ', '');
      total += double.tryParse(amount) ?? 0;
    }
    final totalStr = '₦${total.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        )}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Payments awaiting release', style: AppText.serif(size: 32)),
          const SizedBox(height: 6),
          const Text(
              'Review and release payments to verified workers for completed work.',
              style: TextStyle(fontSize: 15, color: AppColors.text2)),
          const SizedBox(height: 20),

          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL AWAITING RELEASE',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(totalStr,
                    style: AppText.serif(size: 36, color: AppColors.orange)),
                const SizedBox(height: 12),
                Text('${pending.length} pending release',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment list
          if (pending.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 12),
                    Text('All caught up.',
                        style: AppText.serif(size: 22),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text(
                        'No payments awaiting release at this time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.text2)),
                  ],
                ),
              ),
            )
          else
            ...pending.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(p.detail,
                                    style: const TextStyle(
                                        fontSize: 13, color: AppColors.text3)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(p.amount,
                                  style: AppText.serif(size: 20)),
                              const SizedBox(height: 2),
                              Text(p.note,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.accent2,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () =>
                              setState(() => _released.add(
                                    payments.indexOf(p),
                                  )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            p.note == 'review first'
                                ? 'Review & release'
                                : 'Release payment',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
