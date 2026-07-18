import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/screens/services/auth_service.dart';
import '../../../core/account_actions.dart';
import '../../../core/app_sizes.dart';
import '../../../core/profile_image_store.dart';
import '../../../core/user_session.dart';
import '../../../widgets/app_toast.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;

  File? _profileImage;
  final _picker = ImagePicker();
  bool _isSaving = false;

  static const _blue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: UserSession.name ?? '');
    _emailCtrl = TextEditingController(text: UserSession.email ?? '');
    ProfileImageStore.getImage().then((f) {
      if (mounted && f != null) setState(() => _profileImage = f);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final saved = await ProfileImageStore.saveImage(File(picked.path));
    if (mounted) setState(() => _profileImage = saved ?? File(picked.path));
  }

  Future<void> _removeImage() async {
    await ProfileImageStore.deleteImage();
    if (mounted) setState(() => _profileImage = null);
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: rs(context, 20), vertical: rsh(context, 24)),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: rsh(context, 20)),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: _blue),
              title: Text("Change Photo",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage();
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: Text("Delete Photo",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final uid = UserSession.userId ?? '';

    try {
      final response = await AuthService.updateProfile(
        userId: uid,
        fullName: name,
        email: email != (UserSession.email ?? '') ? email : null,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update local session
        UserSession.name = data['fullName'] ?? name;
        UserSession.email = data['email'] ?? email;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', UserSession.name ?? '');
        await prefs.setString('user_email', UserSession.email ?? '');
        if (!mounted) return;
        AppToast.success(context, "Profile updated successfully");
      } else {
        if (!mounted) return;
        AppToast.error(context, data['message'] ?? "Failed to update profile");
      }
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, "Connection error. Try again.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
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
          icon: Builder(builder: (context) => Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: rs(context, 20))),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Builder(builder: (context) => Icon(Icons.check_rounded, color: Colors.white, size: rs(context, 24))),
            tooltip: 'Save',
            onPressed: _save,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarSection(),
              Padding(
                padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 28), rs(context, 20), rsh(context, 40)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("ACCOUNT DETAILS"),
                    _buildCard([
                      _formField(
                        label: "Full Name",
                        controller: _nameCtrl,
                        icon: Icons.person_rounded,
                        hint: "Your full name",
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? "Name is required" : null,
                      ),
                      _fieldDivider(),
                      _formField(
                        label: "Email Address",
                        controller: _emailCtrl,
                        icon: Icons.email_rounded,
                        hint: "you@example.com",
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return "Email is required";
                          final reg = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
                          if (!reg.hasMatch(v.trim())) return "Enter a valid email";
                          return null;
                        },
                      ),
                    ]),
                    SizedBox(height: rsh(context, 32)),
                    _buildSaveButton(),
                    SizedBox(height: rsh(context, 28)),
                    _sectionLabel("DANGER ZONE"),
                    _buildCard([
                      _tile(
                        icon: Icons.delete_forever_rounded,
                        iconColor: Colors.redAccent,
                        title: "Delete Account",
                        subtitle: "Permanently remove your account and data",
                        onTap: () => confirmDeleteAccount(context),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rsh(context, 32)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D2E5C), Color(0xFF0891B2), Color(0xFF2CB88E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showAvatarOptions,
            child: Stack(
              children: [
                Container(
                  width: rs(context, 96),
                  height: rs(context, 96),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.18), blurRadius: 16),
                    ],
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : Container(
                            color: Colors.white.withOpacity(0.15),
                            child: Icon(Icons.person_rounded,
                                color: Colors.white70, size: rs(context, 50)),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: rs(context, 30),
                    height: rs(context, 30),
                    decoration: BoxDecoration(
                      color: _teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: rs(context, 15)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: rsh(context, 10)),
          Text(UserSession.name ?? 'User',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: rs(context, 17),
                  fontWeight: FontWeight.bold)),
          Text(UserSession.email ?? '',
              style: GoogleFonts.poppins(
                  color: Colors.white60, fontSize: rs(context, 12))),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _formField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Builder(builder: (context) => Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rsh(context, 14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: rs(context, 11),
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade400,
                  letterSpacing: 0.5)),
          SizedBox(height: rsh(context, 8)),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            readOnly: readOnly,
            style: GoogleFonts.poppins(
                fontSize: rs(context, 14),
                fontWeight: FontWeight.w500,
                color: readOnly ? Colors.blueGrey : const Color(0xFF1A5694)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.poppins(color: Colors.blueGrey.shade200, fontSize: rs(context, 13)),
              prefixIcon: Icon(icon, color: _blue, size: rs(context, 20)),
              filled: true,
              fillColor:
                  readOnly ? const Color(0xFFEDF1F7) : const Color(0xFFF4F7FB),
              contentPadding:
                  EdgeInsets.symmetric(vertical: rsh(context, 14), horizontal: rs(context, 16)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  borderSide: BorderSide(color: _blue.withOpacity(0.4), width: 1.5)),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _fieldDivider() =>
      Divider(height: 1, indent: 68, endIndent: 16, color: Colors.grey.shade100);

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Builder(builder: (context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 18)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rsh(context, 14)),
        child: Row(
          children: [
            Container(
              width: rs(context, 40),
              height: rs(context, 40),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(rs(context, 12)),
              ),
              child: Icon(icon, color: iconColor, size: rs(context, 20)),
            ),
            SizedBox(width: rs(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: rs(context, 14),
                          color: iconColor)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: rs(context, 11),
                          color: Colors.blueGrey.shade400)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios_rounded,
                  size: rs(context, 13), color: Colors.blueGrey.withOpacity(0.3)),
          ],
        ),
      ),
    ));
  }

  Widget _sectionLabel(String text) {
    return Builder(builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: rsh(context, 10), left: rs(context, 4)),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: rs(context, 11),
          fontWeight: FontWeight.w800,
          color: _blue.withOpacity(0.5),
          letterSpacing: 1.4,
        ),
      ),
    ));
  }

  Widget _buildSaveButton() {
    return Builder(builder: (context) => GestureDetector(
      onTap: _isSaving ? null : _save,
      child: Container(
        width: double.infinity,
        height: rsh(context, 54),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
          ),
          borderRadius: BorderRadius.circular(rs(context, 16)),
          boxShadow: [
            BoxShadow(
                color: _teal.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: _isSaving
              ? SizedBox(
                  width: rs(context, 22),
                  height: rs(context, 22),
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: rs(context, 18)),
                    SizedBox(width: rs(context, 8)),
                    Text("Save Changes",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: rs(context, 15))),
                  ],
                ),
        ),
      ),
    ));
  }
}
