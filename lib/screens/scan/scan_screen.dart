import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/widgets/settings_screen.dart';
import '../result/photo_edit_screen.dart';

class ScanScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final VoidCallback?
  onScanCompleted; // Callback to notify history screen container wrapper to refresh tabs

  const ScanScreen({super.key, required this.cameras, this.onScanCompleted});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  bool _isProcessing = false;

  static const primaryBlue = Color(0xFF1A5694);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.cameras.isNotEmpty) {
      _initCamera(widget.cameras.first);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized)
      return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(cameraController.description);
    }
  }

  Future<void> _initCamera(CameraDescription cameraDescription) async {
    if (_controller != null) await _controller!.dispose();
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
    if (!mounted) return;
    setState(() => _isInitialized = _controller!.value.isInitialized);
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.isTakingPicture ||
        _isProcessing)
      return;

    setState(() => _isProcessing = true);

    try {
      debugPrint(">>>> [STEP 1]: Initiating hardware camera capture frame...");
      final XFile photo = await _controller!.takePicture();
      final File imageFile = File(photo.path);
      debugPrint(">>>> [STEP 2]: Picture written to disk path cache: ${imageFile.path}");

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoEditScreen(image: imageFile),
          ),
        ).then((_) {
          if (widget.onScanCompleted != null) {
            widget.onScanCompleted!();
          }
        });
      }
    } catch (cameraHardwareException) {
      debugPrint(">>>> ❌ [HARDWARE CAPTURE ERROR]: $cameraHardwareException");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint("Flash Mode Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildDecentAppBar(),
      body: Stack(
        children: [
          _isInitialized
              ? SizedBox.expand(child: CameraPreview(_controller!))
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
          _buildViewFinderOverlay(),
          _buildBottomControls(),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4EE3AA)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewFinderOverlay() {
    final frameSize = MediaQuery.of(context).size.width * 0.75;
    const tealFrameColor = Color(0xFF4EE3AA);

    return Center(
      child: SizedBox(
        width: frameSize,
        height: frameSize,
        child: Stack(
          children: [
            _corner(top: 0, left: 0, rot: 0, color: tealFrameColor),
            _corner(top: 0, right: 0, rot: 1.57, color: tealFrameColor),
            _corner(bottom: 0, left: 0, rot: 4.71, color: tealFrameColor),
            _corner(bottom: 0, right: 0, rot: 3.14, color: tealFrameColor),
            Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: tealFrameColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: tealFrameColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleFlash,
                child: _controlIcon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  isActive: _isFlashOn,
                ),
              ),
              const SizedBox(width: 20),
              _statusChip("READY"),
              const SizedBox(width: 20),
              _controlIcon(Icons.hd),
            ],
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _takePicture,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF006D77),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildDecentAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _corner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double rot,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: rot,
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: 4),
              left: BorderSide(color: color, width: 4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlIcon(IconData icon, {bool isActive = false}) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: isActive ? Colors.white.withOpacity(0.3) : Colors.black26,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white24),
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );

  Widget _statusChip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white24),
    ),
    child: Row(
      children: [
        const CircleAvatar(backgroundColor: Color(0xFF4EE3AA), radius: 4),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
