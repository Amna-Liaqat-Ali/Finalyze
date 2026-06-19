import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_back_button.dart';

/// Clean, premium AppBar for all inner screens.
/// White background, Poppins bold title, gradient accent bottom line.
class AppInnerBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const AppInnerBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions = const [],
  });

  static const _primaryBlue = Color(0xFF1A5694);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: true,
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
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: AppBackButton(
                  onTap: onBack ?? () => Navigator.maybePop(context),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: _primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 0.1,
        ),
      ),
      actions: actions.isNotEmpty
          ? [
              ...actions,
              const SizedBox(width: 8),
            ]
          : null,
    );
  }
}
