import 'package:fish_freshness_detection/screens/history/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/colors.dart';
import '../../../models/scan_history_model.dart';

class HistoryCard extends StatelessWidget {
  final ScanHistory data;

  const HistoryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Fish Icon
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.set_meal, color: AppColors.primary),
          ),
          const SizedBox(width: 14),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Status + Fish Name
                Row(
                  children: [
                    StatusBadge(status: data.status),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        data.fishName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _MetaRow(
                  icon: Icons.schedule,
                  text: DateFormat("yyyy-MM-dd • HH:mm").format(data.dateTime),
                ),

                const SizedBox(height: 4),

                _MetaRow(icon: Icons.location_on, text: data.source),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    );
  }
}
