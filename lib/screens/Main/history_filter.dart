import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class HistoryFilter extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const HistoryFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  Widget _chip(String label) {
    final isActive = selected == label;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isActive,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (_) => onChanged(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [_chip("All"), _chip("Fresh"), _chip("Spoiled")],
    );
  }
}
