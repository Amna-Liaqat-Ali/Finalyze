import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/scan_history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<ScanHistory> history = [
    ScanHistory(
      dateTime: DateTime.now(),
      status: ScanStatus.fresh,
      fishName: 'Surmai (King Mackerel)',
      source: 'Karachi Fish Harbor - Dock 1',
      confidence: 99,
      image: 'assets/images/surmai.jpeg',
    ),
    ScanHistory(
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: ScanStatus.fresh,
      fishName: 'Heera (Red Snapper)',
      source: 'Empress Market',
      confidence: 96,
      image: 'assets/images/heera.jpeg',
    ),
    ScanHistory(
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      status: ScanStatus.moderate,
      fishName: 'Silver Paplet (Pomfret)',
      source: 'Kemari Market Intake',
      confidence: 85,
      image: 'assets/images/paplet.jpeg',
    ),
    ScanHistory(
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      status: ScanStatus.fair,
      fishName: 'Rahu (Local Carp)',
      source: 'Super Highway Mandi',
      confidence: 72,
      image: 'assets/images/rohu.jpeg',
    ),
    ScanHistory(
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      status: ScanStatus.spoiled,
      fishName: 'Mushka (Croaker)',
      source: 'Liaquatabad Market',
      confidence: 91,
      image: 'assets/images/mushka.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2B45), // Deep Navy Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2B45),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 24,
        title: Text(
          "Scan Records",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white70,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white70),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF173652),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Search records...",
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B4D8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00B4D8).withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${history.length} Scans",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00B4D8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                // Group by Date Header
                final bool showHeader =
                    index == 0 ||
                    !_isSameDay(history[index - 1].dateTime, item.dateTime);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader) _buildDateHeader(item.dateTime),
                    _buildThemeCard(item),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateHeader(DateTime date) {
    String label;
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      label = "Today";
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      label = "Yesterday";
    } else {
      label = DateFormat("MMMM d, yyyy").format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildThemeCard(ScanHistory item) {
    Color statusColor;
    String statusText;

    switch (item.status) {
      case ScanStatus.fresh:
        statusColor = const Color(0xFF10B981); // Emerald Green
        statusText = "FRESH";
        break;
      case ScanStatus.moderate:
        statusColor = const Color(0xFFF59E0B); // Amber
        statusText = "MODERATE";
        break;
      case ScanStatus.fair:
        statusColor = const Color(0xFFF97316); // Orange
        statusText = "FAIR";
        break;
      case ScanStatus.spoiled:
        statusColor = const Color(0xFFEF4444); // Red
        statusText = "SPOILED";
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF173652),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              image: item.image.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(item.image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.image.isEmpty
                ? Icon(Icons.set_meal_rounded, color: statusColor, size: 26)
                : null,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fishName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormat("h:mm a").format(item.dateTime),
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: CircleAvatar(
                        radius: 2,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.source,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${item.confidence}%",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
