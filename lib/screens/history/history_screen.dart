import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/scan_history_model.dart';

class HistoryScreen extends StatefulWidget {
  final List<ScanHistory> historyItems;

  const HistoryScreen({super.key, required this.historyItems});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isGalleryView = true;
  ScanHistory? selectedItem;

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

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A5694);

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
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildToggle(primaryBlue),
              Expanded(
                child: isGalleryView
                    ? _buildGalleryView()
                    : _buildListView(primaryBlue),
              ),
            ],
          ),
          if (selectedItem != null) _buildPopupOverlay(selectedItem!),
        ],
      ),
    );
  }

  Widget _buildToggle(Color primaryBlue) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _toggleBtn("List View", !isGalleryView, primaryBlue),
          _toggleBtn("Visual Gallery", isGalleryView, primaryBlue),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool active, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isGalleryView = (text == "Visual Gallery")),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: active ? Colors.white : color.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: widget.historyItems
            .map((item) => _buildGridItem(item))
            .toList(),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                    child: Image.asset(
                      item.image,
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
                      color: Color(0xFF1A5694),
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

  Widget _buildListView(Color primaryBlue) {
    return ListView.builder(
      itemCount: widget.historyItems.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = widget.historyItems[index];

        return Dismissible(
          key: Key(item.dateTime.toString() + item.fishName),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            setState(() => widget.historyItems.removeAt(index));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${item.fishName} removed from history"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: _buildListTile(item, primaryBlue),
        );
      },
    );
  }

  Widget _buildListTile(ScanHistory item, Color primaryBlue) {
    return GestureDetector(
      onTap: () => setState(() => selectedItem = item),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
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
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.cover,
                      height: 190,
                      width: double.infinity,
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
                            color: const Color(0xFF1A5694),
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
                        _btn(
                          "Full Report",
                          const Color(0xFF1A5694),
                          Colors.white,
                        ),
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
              color: Color(0xFF1A5694),
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
