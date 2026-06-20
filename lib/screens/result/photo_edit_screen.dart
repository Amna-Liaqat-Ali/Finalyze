import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'review_screen.dart';

class PhotoEditScreen extends StatefulWidget {
  final File image;
  const PhotoEditScreen({super.key, required this.image});

  @override
  State<PhotoEditScreen> createState() => _PhotoEditScreenState();
}

enum _Tool { none, crop, enhance }

enum _DragHandle { tl, tr, bl, br, rect }

class _PhotoEditScreenState extends State<PhotoEditScreen> {
  _Tool _activeTool = _Tool.none;

  // Actual image dimensions (loaded async for precise crop mapping)
  int _imgW = 1, _imgH = 1;
  bool _dimensionsLoaded = false;

  // Crop rect in normalized image coords (0..1)
  double _cropL = 0.08, _cropT = 0.08, _cropR = 0.92, _cropB = 0.92;

  // Drag state
  _DragHandle? _dragging;
  double _dragStartL = 0, _dragStartT = 0, _dragStartR = 0, _dragStartB = 0;
  Offset _dragStartPos = Offset.zero;

  // Enhance values
  double _brightness = 0.0;   // -0.4 to 0.4 (0 = no change)
  double _contrast = 1.0;     // 0.7 to 1.5 (1.0 = no change)
  double _saturation = 1.0;   // 0.5 to 1.8 (1.0 = no change)

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    final bytes = await widget.image.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() {
      _imgW = frame.image.width;
      _imgH = frame.image.height;
      _dimensionsLoaded = true;
    });
    frame.image.dispose();
    codec.dispose();
  }

  /// Compute the display rect of the image inside the container (BoxFit.contain).
  Rect _imageDisplayRect(Size container) {
    if (_imgW == 0 || _imgH == 0) return Rect.fromLTWH(0, 0, container.width, container.height);
    final imgAspect = _imgW / _imgH;
    final conAspect = container.width / container.height;
    double dw, dh;
    if (imgAspect > conAspect) {
      dw = container.width;
      dh = container.width / imgAspect;
    } else {
      dh = container.height;
      dw = container.height * imgAspect;
    }
    final ox = (container.width - dw) / 2;
    final oy = (container.height - dh) / 2;
    return Rect.fromLTWH(ox, oy, dw, dh);
  }

  /// Convert normalized crop rect to pixel rect in the display area.
  Rect _cropDisplayRect(Size container) {
    final d = _imageDisplayRect(container);
    return Rect.fromLTRB(
      d.left + _cropL * d.width,
      d.top + _cropT * d.height,
      d.left + _cropR * d.width,
      d.top + _cropB * d.height,
    );
  }

  /// 5x4 color matrix for real-time ColorFiltered preview.
  List<double> _buildMatrix() {
    final b = _brightness;
    final c = _contrast;
    final s = _saturation;

    final sr = (1 - s) * 0.2126;
    final sg = (1 - s) * 0.7152;
    final sb = (1 - s) * 0.0722;

    return [
      c * (sr + s), c * sg,       c * sb,       0, b * 255,
      c * sr,       c * (sg + s), c * sb,       0, b * 255,
      c * sr,       c * sg,       c * (sb + s), 0, b * 255,
      0,            0,            0,            1, 0,
    ];
  }

  void _onPanStart(DragStartDetails d, Size size) {
    final crop = _cropDisplayRect(size);
    const hit = 28.0;
    final pos = d.localPosition;

    if ((pos - crop.topLeft).distance < hit) {
      _dragging = _DragHandle.tl;
    } else if ((pos - crop.topRight).distance < hit) {
      _dragging = _DragHandle.tr;
    } else if ((pos - crop.bottomLeft).distance < hit) {
      _dragging = _DragHandle.bl;
    } else if ((pos - crop.bottomRight).distance < hit) {
      _dragging = _DragHandle.br;
    } else if (crop.contains(pos)) {
      _dragging = _DragHandle.rect;
    } else {
      _dragging = null;
      return;
    }

    _dragStartPos = pos;
    _dragStartL = _cropL;
    _dragStartT = _cropT;
    _dragStartR = _cropR;
    _dragStartB = _cropB;
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    if (_dragging == null) return;
    final disp = _imageDisplayRect(size);
    if (disp.width == 0 || disp.height == 0) return;

    final delta = d.localPosition - _dragStartPos;
    final dx = delta.dx / disp.width;
    final dy = delta.dy / disp.height;
    const minSize = 0.08;

    setState(() {
      switch (_dragging!) {
        case _DragHandle.tl:
          _cropL = (_dragStartL + dx).clamp(0.0, _cropR - minSize);
          _cropT = (_dragStartT + dy).clamp(0.0, _cropB - minSize);
        case _DragHandle.tr:
          _cropR = (_dragStartR + dx).clamp(_cropL + minSize, 1.0);
          _cropT = (_dragStartT + dy).clamp(0.0, _cropB - minSize);
        case _DragHandle.bl:
          _cropL = (_dragStartL + dx).clamp(0.0, _cropR - minSize);
          _cropB = (_dragStartB + dy).clamp(_cropT + minSize, 1.0);
        case _DragHandle.br:
          _cropR = (_dragStartR + dx).clamp(_cropL + minSize, 1.0);
          _cropB = (_dragStartB + dy).clamp(_cropT + minSize, 1.0);
        case _DragHandle.rect:
          final w = _dragStartR - _dragStartL;
          final h = _dragStartB - _dragStartT;
          _cropL = (_dragStartL + dx).clamp(0.0, 1.0 - w);
          _cropT = (_dragStartT + dy).clamp(0.0, 1.0 - h);
          _cropR = _cropL + w;
          _cropB = _cropT + h;
      }
    });
  }

  Future<void> _onContinue() async {
    setState(() => _isProcessing = true);
    try {
      final bytes = await widget.image.readAsBytes();
      img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) return;

      // Apply crop if modified from default
      final cropChanged = _cropL > 0.005 || _cropT > 0.005 || _cropR < 0.995 || _cropB < 0.995;
      if (cropChanged) {
        final x = (_cropL * decoded.width).round().clamp(0, decoded.width - 1);
        final y = (_cropT * decoded.height).round().clamp(0, decoded.height - 1);
        final w = ((_cropR - _cropL) * decoded.width).round().clamp(1, decoded.width - x);
        final h = ((_cropB - _cropT) * decoded.height).round().clamp(1, decoded.height - y);
        decoded = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
      }

      // Apply enhance
      if (_brightness != 0.0 || _contrast != 1.0 || _saturation != 1.0) {
        decoded = img.adjustColor(
          decoded,
          brightness: _brightness,
          contrast: _contrast,
          saturation: _saturation,
        );
      }

      final tmpDir = await getTemporaryDirectory();
      final tmpFile = File('${tmpDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tmpFile.writeAsBytes(img.encodeJpg(decoded, quality: 92));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ReviewScreen(image: tmpFile)),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _resetEdits() => setState(() {
    _cropL = 0.08; _cropT = 0.08; _cropR = 0.92; _cropB = 0.92;
    _brightness = 0.0; _contrast = 1.0; _saturation = 1.0;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
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
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cancel',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: Colors.white70, size: 22),
            tooltip: 'Reset',
            onPressed: _resetEdits,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Image area
          Expanded(child: _buildImageArea()),
          // Tool tabs
          _buildToolTabs(),
          // Sliders (only in enhance mode)
          if (_activeTool == _Tool.enhance) _buildEnhanceSliders(),
          // Bottom action bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final size = constraints.biggest;
      return GestureDetector(
        onPanStart: _activeTool == _Tool.crop ? (d) => _onPanStart(d, size) : null,
        onPanUpdate: _activeTool == _Tool.crop ? (d) => _onPanUpdate(d, size) : null,
        onPanEnd: _activeTool == _Tool.crop ? (_) => setState(() => _dragging = null) : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Slight dark background for letterboxed areas
            Container(color: const Color(0xFF0E0E0E)),
            // Image with color filter for live enhance preview
            ColorFiltered(
              colorFilter: ColorFilter.matrix(_buildMatrix()),
              child: Image.file(widget.image, fit: BoxFit.contain),
            ),
            // Crop overlay
            if (_activeTool == _Tool.crop && _dimensionsLoaded)
              CustomPaint(
                painter: _CropPainter(
                  cropRect: _cropDisplayRect(size),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildToolTabs() {
    return Container(
      color: const Color(0xFF181818),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _toolTab(Icons.crop_rounded, "Crop", _Tool.crop),
          _toolTab(Icons.auto_fix_high_rounded, "Enhance", _Tool.enhance),
        ],
      ),
    );
  }

  Widget _toolTab(IconData icon, String label, _Tool tool) {
    final active = _activeTool == tool;
    return GestureDetector(
      onTap: () => setState(() => _activeTool = active ? _Tool.none : tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2CB88E).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? const Color(0xFF2CB88E) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? const Color(0xFF2CB88E) : Colors.white38, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: active ? const Color(0xFF2CB88E) : Colors.white38,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhanceSliders() {
    return Container(
      color: const Color(0xFF141414),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Column(
        children: [
          _enhanceSlider("Brightness", _brightness, -0.4, 0.4, Icons.brightness_6_rounded,
              (v) => setState(() => _brightness = v)),
          _enhanceSlider("Contrast", _contrast - 1.0, -0.3, 0.5, Icons.contrast_rounded,
              (v) => setState(() => _contrast = 1.0 + v)),
          _enhanceSlider("Saturation", _saturation - 1.0, -0.5, 0.8, Icons.color_lens_rounded,
              (v) => setState(() => _saturation = 1.0 + v)),
        ],
      ),
    );
  }

  Widget _enhanceSlider(String label, double value, double min, double max, IconData icon, ValueChanged<double> onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF2CB88E),
                inactiveTrackColor: Colors.white10,
                thumbColor: const Color(0xFF2CB88E),
                overlayColor: const Color(0x222CB88E),
                trackHeight: 2.5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: const Color(0xFF0E0E0E),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Row(
        children: [
          // Reset
          GestureDetector(
            onTap: _resetEdits,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.restart_alt_rounded, color: Colors.white38, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          // Continue
          Expanded(
            child: GestureDetector(
              onTap: _isProcessing ? null : _onContinue,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0891B2).withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Continue",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  final Rect cropRect;
  const _CropPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Dark mask outside crop
    final mask = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(mask, Paint()..color = Colors.black.withOpacity(0.58));

    // Crop border
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Rule-of-thirds grid
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 0.8;
    final w3 = cropRect.width / 3;
    final h3 = cropRect.height / 3;
    for (int i = 1; i <= 2; i++) {
      canvas.drawLine(
        Offset(cropRect.left + w3 * i, cropRect.top),
        Offset(cropRect.left + w3 * i, cropRect.bottom),
        grid,
      );
      canvas.drawLine(
        Offset(cropRect.left, cropRect.top + h3 * i),
        Offset(cropRect.right, cropRect.top + h3 * i),
        grid,
      );
    }

    // Teal corner handles
    final handle = Paint()
      ..color = const Color(0xFF2CB88E)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const arm = 20.0;
    _corner(canvas, handle, cropRect.topLeft, arm, 1, 1);
    _corner(canvas, handle, cropRect.topRight, arm, -1, 1);
    _corner(canvas, handle, cropRect.bottomLeft, arm, 1, -1);
    _corner(canvas, handle, cropRect.bottomRight, arm, -1, -1);

    // Corner dots
    final dot = Paint()..color = const Color(0xFF2CB88E);
    for (final c in [cropRect.topLeft, cropRect.topRight, cropRect.bottomLeft, cropRect.bottomRight]) {
      canvas.drawCircle(c, 5, dot);
    }
  }

  void _corner(Canvas c, Paint p, Offset o, double arm, double sx, double sy) {
    c.drawLine(o, o + Offset(arm * sx, 0), p);
    c.drawLine(o, o + Offset(0, arm * sy), p);
  }

  @override
  bool shouldRepaint(_CropPainter old) => old.cropRect != cropRect;
}
