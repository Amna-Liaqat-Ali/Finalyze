import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/screens/services/auth_service.dart';
import '../auth/screens/welcome_screen.dart';
import 'user_session.dart';

/// Shared delete-account flow so every entry point (Settings, Edit Profile, ...)
/// behaves identically and stays in sync.
Future<void> confirmDeleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Delete Account",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.redAccent)),
      content: Text(
        "This will permanently delete your account and all scan history. This action cannot be undone.",
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text("Delete",
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  final uid = UserSession.userId ?? '';
  try {
    final response = await AuthService.deleteAccount(uid);
    if (response.statusCode == 200) {
      await UserSession.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete account. Try again.")),
        );
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error. Try again.")),
      );
    }
  }
}
