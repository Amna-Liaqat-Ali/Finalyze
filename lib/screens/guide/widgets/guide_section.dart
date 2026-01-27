import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class GuideSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const GuideSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 10),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        children: [child],
      ),
    );
  }
}
