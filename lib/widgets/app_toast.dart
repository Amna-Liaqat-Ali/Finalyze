import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _ToastType { success, error, info, warning }

class AppToast {
  static const _blue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);

  static void success(BuildContext context, String message) =>
      _show(context, message, _ToastType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, _ToastType.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, _ToastType.info);

  static void warning(BuildContext context, String message) =>
      _show(context, message, _ToastType.warning);

  static void _show(BuildContext context, String message, _ToastType type) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final _ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 3000), _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bg {
    switch (widget.type) {
      case _ToastType.success:
        return const Color(0xFF2CB88E);
      case _ToastType.error:
        return const Color(0xFFE53935);
      case _ToastType.info:
        return const Color(0xFF1A5694);
      case _ToastType.warning:
        return const Color(0xFFF57C00);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case _ToastType.success:
        return Icons.check_circle_rounded;
      case _ToastType.error:
        return Icons.error_rounded;
      case _ToastType.info:
        return Icons.info_rounded;
      case _ToastType.warning:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 48 + MediaQuery.of(context).viewInsets.bottom,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _bg.withOpacity(0.38),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_icon, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _dismiss,
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white70, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen success overlay shown after login.
class LoginSuccessOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const LoginSuccessOverlay({super.key, required this.onComplete});

  @override
  State<LoginSuccessOverlay> createState() => _LoginSuccessOverlayState();
}

class _LoginSuccessOverlayState extends State<LoginSuccessOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 1200), () async {
      await _fadeCtrl.forward();
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(_fade),
      child: Container(
        color: const Color(0xFF061A30).withOpacity(0.88),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2CB88E).withOpacity(0.5),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 20),
                Text(
                  "Welcome back!",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Login successful",
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
