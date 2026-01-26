import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class HistoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const HistoryFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const filters = ["All", "Fresh", "Moderate", "Fair"];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: filters.map((f) {
        final bool isActive = selected == f;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            label: Text(f),
            selected: isActive,
            onSelected: (_) => onChanged(f),
            selectedColor: AppColors.primary,
            backgroundColor: Colors.grey.shade100,
            labelStyle: TextStyle(
              color: isActive ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }).toList(),
    );
  }
}
