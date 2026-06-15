import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A small metric tile, like .stat-card
class StatCard extends StatelessWidget {
  final String label, value;
  final String? delta;
  final Color deltaColor;
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaColor = AppColors.text2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.6,
                  color: AppColors.text3,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: AppText.serif(size: 30)),
          if (delta != null) ...[
            const SizedBox(height: 8),
            Text(delta!,
                style: TextStyle(
                    fontSize: 12, color: deltaColor, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

/// A titled white card, like .card
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(title.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.7,
                        color: AppColors.text3,
                        fontWeight: FontWeight.w700)),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Tier pill, like .badge
class TierBadge extends StatelessWidget {
  final String tier;
  const TierBadge(this.tier, {super.key});

  @override
  Widget build(BuildContext context) {
    final map = {
      'student': [const Color(0x242F9E6B), AppColors.success, 'Student'],
      'rider': [const Color(0x2EFBAC34), AppColors.accent2, 'Rider'],
      'remote': [const Color(0x1A000066), AppColors.navy, 'Remote'],
      'trade': [const Color(0x21D6493C), AppColors.danger, 'Trade'],
    };
    final m = map[tier] ?? map['remote']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: m[0] as Color, borderRadius: BorderRadius.circular(999)),
      child: Text(m[2] as String,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: m[1] as Color)),
    );
  }
}

/// Small "View all →" style link for card headers.
class CardLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const CardLink(this.text, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, color: AppColors.accent2, fontWeight: FontWeight.w600)),
    );
  }
}

BoxDecoration _cardBox() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    );
