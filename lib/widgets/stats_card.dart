import 'package:flutter/material.dart';
import '../config/theme.dart';

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final Color? color;

  const StatsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: color ?? AppTheme.navyBlue,
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color ?? AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.corporateGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
