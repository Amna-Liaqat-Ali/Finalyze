import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/api_config.dart';
import 'services/scan_service.dart';

// Structured representation of categories matching your AI analysis metrics
enum ScanStatus { fresh, fair, moderate, spoiled }

class ScanHistory {
  final String id;
  final String fishName;
  final String source;
  final DateTime dateTime;
  final ScanStatus status;
  final String image;
  final int confidence;

  ScanHistory({
    required this.id,
    required this.fishName,
    required this.source,
    required this.dateTime,
    required this.status,
    required this.image,
    required this.confidence,
  });

  // Maps backend JSON documents safely into local state objects
  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    ScanStatus parsedStatus;
    switch (json['category'].toString().toLowerCase()) {
      case 'fresh':
        parsedStatus = ScanStatus.fresh;
        break;
      case 'fair':
        parsedStatus = ScanStatus.fair;
        break;
      case 'moderate':
        parsedStatus = ScanStatus.moderate;
        break;
      default:
        parsedStatus = ScanStatus.spoiled;
    }

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse("${json['scanDate']} ${json['scanTime']}");
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return ScanHistory(
      id: json['_id'] ?? '',
      fishName: json['fishName'] ?? 'Unknown Species',
      source: json['area'] ?? 'General Port',
      dateTime: parsedDate,
      status: parsedStatus,
      image: json['imagePath'] ?? '',
      confidence: (json['percentage'] ?? 0.0).toDouble().round(),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isGalleryView = true;
  ScanHistory? selectedItem;
  late Future<List<ScanHistory>> _historyFuture;

  static const primaryBlue = Color(0xFF1A5694);

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = ScanService.getUserScanHistory(
        widget.userId,
      ).then((data) => data.map((json) => ScanHistory.fromJson(json)).toList());
    });
  }

  Color _getStatusColor(ScanStatus status) {
    switch (status) {
      case ScanStatus.fresh:
        return const Color(0xFF2CB88E);
      case ScanStatus.fair:
        return const Color(0xFF1E88E5);
      case ScanStatus.moderate:
        return Colors.orange;
      case ScanStatus.spoiled:
        return Colors.redAccent;
    }
  }

  String _getAbsoluteImageUrl(String targetPath) {
    final cleanPath = targetPath.replaceAll(r'\', '/');
    final String serverBase = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$serverBase/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Scan History",
          style: GoogleFonts.poppins(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryBlue),
            onPressed: _refreshHistory,
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<ScanHistory>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error fetching records: ${snapshot.error}"),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Professional, Clean Empty State View UI Block
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.analytics_outlined,
                            size: 74,
                            color: primaryBlue.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "No Scan Records Found",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Your fresh catch evaluation updates will appear here once you perform a batch image classification scan from the dashboard framework terminal.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 160,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _refreshHistory,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              size: 18,
                              color: primaryBlue,
                            ),
                            label: Text(
                              "Check Again",
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: primaryBlue.withOpacity(0.3),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final historyItems = snapshot.data!;

              return Column(
                children: [
                  _buildToggle(),
                  Expanded(
                    child: isGalleryView
                        ? _buildGalleryView(historyItems)
                        : _buildListView(historyItems),
                  ),
                ],
              );
            },
          ),
          if (selectedItem != null) _buildPopupOverlay(selectedItem!),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _toggleBtn("List View", !isGalleryView),
          _toggleBtn("Visual Gallery", isGalleryView),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isGalleryView = (text == "Visual Gallery")),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: active ? Colors.white : primaryBlue.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryView(List<ScanHistory> items) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items.map((item) => _buildGridItem(item)).toList(),
      ),
    );
  }

  Widget _buildGridItem(ScanHistory item) {
    double itemWidth = (MediaQuery.of(context).size.width - 32 - 24) / 3;
    return GestureDetector(
      onTap: () => setState(() => selectedItem = item),
      child: Container(
        width: itemWidth,
        height: itemWidth * 1.35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.network(
                      _getAbsoluteImageUrl(item.image),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: _getStatusColor(item.status),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d').format(item.dateTime),
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                  Text(
                    item.fishName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<ScanHistory> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildListTile(item);
      },
    );
  }

  Widget _buildListTile(ScanHistory item) {
    return GestureDetector(
      onTap: () => setState(() => selectedItem = item),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                _getAbsoluteImageUrl(item.image),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fishName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy • hh:mm a').format(item.dateTime),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(item.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.status.name.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(item.status),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupOverlay(ScanHistory item) {
    return GestureDetector(
      onTap: () => setState(() => selectedItem = null),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 310,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: Image.network(
                      _getAbsoluteImageUrl(item.image),
                      fit: BoxFit.cover,
                      height: 190,
                      width: double.infinity,
                      errorBuilder: (c, e, s) => Container(
                        height: 190,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          "Finalyze Result",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        Text(
                          "${item.confidence}% ${item.status.name.toUpperCase()}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(item.status),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _infoRow("Species", item.fishName),
                        _infoRow("Source", item.source),
                        _infoRow(
                          "Scanned",
                          DateFormat('hh:mm a').format(item.dateTime),
                        ),
                        const SizedBox(height: 25),
                        _btn("Full Report", primaryBlue, Colors.white),
                        const SizedBox(height: 10),
                        _btn(
                          "Close",
                          Colors.grey.shade100,
                          Colors.grey.shade700,
                          isDismiss: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(
            val,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String txt, Color bg, Color textCol, {bool isDismiss = false}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => isDismiss ? setState(() => selectedItem = null) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          txt,
          style: TextStyle(color: textCol, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
