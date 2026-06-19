import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/api_config.dart';
import '../../../widgets/app_inner_bar.dart';
import '../../core/user_session.dart';
import 'history_detail_screen.dart';
import 'services/scan_service.dart';

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
      image: json['imageData'] ?? json['imagePath'] ?? '',
      confidence: (json['percentage'] ?? 0.0).toDouble().round(),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  bool isGalleryView = true;
  ScanHistory? selectedItem;
  late Future<List<ScanHistory>> _historyFuture;

  // Selection mode
  bool _selectMode = false;
  final Set<String> _selectedIds = {};
  bool _isDeleting = false;

  static const primaryBlue = Color(0xFF1A5694);

  String get effectiveUserId =>
      widget.userId.isNotEmpty ? widget.userId : (UserSession.userId ?? '');

  @override
  void initState() {
    super.initState();
    refreshHistory();
  }

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    refreshHistory();
  }

  void refreshHistory() {
    if (!mounted) return;
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
      _historyFuture = ScanService.getUserScanHistory(effectiveUserId)
          .then((rawData) {
            if (rawData is! List) return <ScanHistory>[];
            return rawData
                .map((json) => ScanHistory.fromJson(json as Map<String, dynamic>))
                .toList();
          })
          .catchError((error) {
            debugPrint("History load error: $error");
            return <ScanHistory>[];
          });
    });
  }

  void _enterSelectMode(String id) {
    setState(() {
      _selectMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    setState(() => _isDeleting = true);
    int failed = 0;
    for (final id in _selectedIds.toList()) {
      final ok = await ScanService.deleteScan(id);
      if (!ok) failed++;
    }
    if (!mounted) return;
    setState(() => _isDeleting = false);
    if (failed > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$failed item(s) could not be deleted.")),
      );
    }
    refreshHistory();
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

  Widget _buildHistoryImage(String image,
      {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
    if (image.isEmpty) return placeholder;

    if (image.startsWith('http') || image.startsWith('uploads/')) {
      final cleanPath = image.replaceAll(r'\', '/');
      final serverBase = ApiConfig.baseUrl.replaceAll('/api', '');
      final url = image.startsWith('http') ? image : '$serverBase/$cleanPath';
      return Image.network(url,
          fit: fit, width: width, height: height,
          errorBuilder: (_, __, ___) => placeholder);
    }

    try {
      final base64Data = image.contains(',') ? image.split(',').last : image;
      final bytes = base64Decode(base64Data);
      return Image.memory(bytes,
          fit: fit, width: width, height: height,
          errorBuilder: (_, __, ___) => placeholder);
    } catch (_) {
      return placeholder;
    }
  }

  PreferredSizeWidget _buildAppBar() {
    if (_selectMode) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: primaryBlue),
          onPressed: _exitSelectMode,
        ),
        title: Text(
          "${_selectedIds.length} selected",
          style: GoogleFonts.poppins(
            color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          if (_isDeleting)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              tooltip: "Delete selected",
              onPressed: _selectedIds.isEmpty ? null : _confirmDelete,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
              ),
            ),
          ),
        ),
      );
    }

    return AppInnerBar(
      title: "Scan History",
      showBack: Navigator.canPop(context),
      onBack: () => Navigator.pop(context),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: primaryBlue, size: 22),
          onPressed: refreshHistory,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Future<void> _confirmDelete() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Delete $count scan${count > 1 ? 's' : ''}?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryBlue)),
        content: Text(
          "This action cannot be undone.",
          style: GoogleFonts.poppins(color: Colors.blueGrey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel",
              style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) _deleteSelected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
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
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmpty();
              }

              final items = snapshot.data!;
              return Column(
                children: [
                  _buildToggle(),
                  Expanded(
                    child: isGalleryView
                        ? _buildGalleryView(items)
                        : _buildListView(items),
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

  Widget _buildEmpty() {
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
              child: Icon(Icons.analytics_outlined,
                  size: 74, color: primaryBlue.withOpacity(0.4)),
            ),
            const SizedBox(height: 24),
            Text("No Scan Records Found",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
            const SizedBox(height: 10),
            Text("Scan a fish and the results will appear here.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade500, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 16),
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

  // ─── Gallery view ────────────────────────────────────────────────────────────

  Widget _buildGalleryView(List<ScanHistory> items) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.74,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildGridItem(items[index]),
    );
  }

  Widget _buildGridItem(ScanHistory item) {
    final selected = _selectedIds.contains(item.id);

    return GestureDetector(
      onTap: () {
        if (_selectMode) {
          _toggleSelection(item.id);
        } else {
          setState(() => selectedItem = item);
        }
      },
      onLongPress: () {
        if (!_selectMode) _enterSelectMode(item.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? primaryBlue : Colors.grey.shade100,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: _buildHistoryImage(item.image, fit: BoxFit.cover),
                    ),
                  ),
                  // Status dot (non-select) or checkbox (select mode)
                  if (_selectMode)
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: selected ? primaryBlue : Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? primaryBlue : Colors.grey.shade400),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                            : null,
                      ),
                    )
                  else
                    Positioned(
                      top: 8, right: 8,
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
                  Text(DateFormat('MMM d').format(item.dateTime),
                    style: const TextStyle(fontSize: 8, color: Colors.grey)),
                  Text(
                    item.fishName,
                    style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold, color: primaryBlue),
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

  // ─── List view ───────────────────────────────────────────────────────────────

  Widget _buildListView(List<ScanHistory> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => _buildListTile(items[index]),
    );
  }

  Widget _buildListTile(ScanHistory item) {
    final selected = _selectedIds.contains(item.id);

    return GestureDetector(
      onTap: () {
        if (_selectMode) {
          _toggleSelection(item.id);
        } else {
          setState(() => selectedItem = item);
        }
      },
      onLongPress: () {
        if (!_selectMode) _enterSelectMode(item.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? primaryBlue : Colors.grey.shade100,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox or image
            if (_selectMode)
              Container(
                width: 22, height: 22,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: selected ? primaryBlue : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? primaryBlue : Colors.grey.shade400),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : null,
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildHistoryImage(item.image, width: 60, height: 60),
              ),
            if (!_selectMode) const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fishName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: primaryBlue, fontSize: 15),
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

  // ─── Popup overlay ───────────────────────────────────────────────────────────

  Widget _buildPopupOverlay(ScanHistory item) {
    return GestureDetector(
      onTap: () => setState(() => selectedItem = null),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withOpacity(0.30),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: _buildHistoryImage(item.image,
                        fit: BoxFit.cover, height: 190, width: double.infinity),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text("Finalyze Result",
                          style: GoogleFonts.poppins(
                            fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
                        Text(
                          "${item.confidence}% ${item.status.name.toUpperCase()}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(item.status)),
                        ),
                        const SizedBox(height: 16),
                        _infoRow("Species", item.fishName),
                        _infoRow("Source", item.source),
                        _infoRow("Scanned",
                          DateFormat('MMM d • hh:mm a').format(item.dateTime)),
                        const SizedBox(height: 20),
                        // Full Report button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.description_rounded, size: 18),
                            label: Text("Full Report",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              setState(() => selectedItem = null);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HistoryDetailScreen(item: item),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Close button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => setState(() => selectedItem = null),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              side: BorderSide(color: Colors.grey.shade200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Close",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ),
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
          Text(val,
            style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
        ],
      ),
    );
  }
}
