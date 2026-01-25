import 'package:flutter/material.dart';

import '../constants/colors.dart';

class ChangeImageSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const ChangeImageSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 25),

          ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.primary),
            title: const Text("Use Camera"),
            onTap: onCamera,
          ),

          ListTile(
            leading: const Icon(
              Icons.photo_library,
              color: AppColors.secondary,
            ),
            title: const Text("Choose from Gallery"),
            onTap: onGallery,
          ),
        ],
      ),
    );
  }
}
