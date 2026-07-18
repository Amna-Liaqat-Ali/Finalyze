import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_sizes.dart';
import '../../../widgets/app_back_button.dart';
import '../../../widgets/app_toast.dart';
import '../models/recipe.dart';
import '../services/recipe_interaction_store.dart';

enum _Phase { ingredients, steps, rate }

class CookingFlowScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingFlowScreen({super.key, required this.recipe});

  @override
  State<CookingFlowScreen> createState() => _CookingFlowScreenState();
}

class _CookingFlowScreenState extends State<CookingFlowScreen> {
  static const primaryBlue = Color(0xFF1A5694);
  static const accentTeal = Color(0xFF2CB88E);
  static const softBg = Color(0xFFF8FAFC);

  _Phase _phase = _Phase.ingredients;
  late final List<bool> _stepsDone =
      List.generate(widget.recipe.instructions.length, (_) => false);
  double _selectedRating = 0;

  Recipe get recipe => widget.recipe;

  void _submitRating() {
    if (_selectedRating <= 0) {
      AppToast.info(context, "Tap a star to rate this recipe first");
      return;
    }
    setState(() => recipe.rating = _selectedRating);
    RecipeInteractionStore.setRating(recipe.id, _selectedRating);
    AppToast.success(context, "Thanks for rating this recipe!");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
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
        leading: Padding(
          padding: EdgeInsets.only(left: rs(context, 12)),
          child: Center(
            child: AppBackButton(isGlass: true, onTap: () => Navigator.pop(context)),
          ),
        ),
        title: Text(
          recipe.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: rs(context, 16),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPhaseIndicator(context),
            Expanded(
              child: switch (_phase) {
                _Phase.ingredients => _buildIngredientsPhase(context),
                _Phase.steps => _buildStepsPhase(context),
                _Phase.rate => _buildRatePhase(context),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator(BuildContext context) {
    const labels = ["Ingredients", "Steps", "Rate"];
    return Padding(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 16), rs(context, 20), rsh(context, 8)),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == _phase.index;
          final done = i < _phase.index;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: active || done ? accentTeal : Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (i != labels.length - 1) SizedBox(width: rs(context, 6)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIngredientsPhase(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 12), rs(context, 20), rsh(context, 20)),
            itemCount: recipe.ingredients.length,
            itemBuilder: (context, index) => Container(
              margin: EdgeInsets.only(bottom: rsh(context, 10)),
              padding: EdgeInsets.all(rs(context, 14)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rs(context, 14)),
                border: Border.all(color: Colors.blueGrey.shade50),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: accentTeal, size: rs(context, 20)),
                  SizedBox(width: rs(context, 12)),
                  Expanded(
                    child: Text(
                      recipe.ingredients[index],
                      style: GoogleFonts.poppins(
                        fontSize: rs(context, 14),
                        color: primaryBlue.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildBottomButton(context, "Start Cooking", Icons.play_arrow_rounded,
            () => setState(() => _phase = _Phase.steps)),
      ],
    );
  }

  Widget _buildStepsPhase(BuildContext context) {
    final doneCount = _stepsDone.where((d) => d).length;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rs(context, 20), vertical: rsh(context, 8)),
          child: Row(
            children: [
              Text(
                "$doneCount/${_stepsDone.length} steps done",
                style: GoogleFonts.poppins(
                  fontSize: rs(context, 13),
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(rs(context, 20), 0, rs(context, 20), rsh(context, 20)),
            itemCount: recipe.instructions.length,
            itemBuilder: (context, index) {
              final done = _stepsDone[index];
              return GestureDetector(
                onTap: () => setState(() => _stepsDone[index] = !_stepsDone[index]),
                child: Container(
                  margin: EdgeInsets.only(bottom: rsh(context, 12)),
                  padding: EdgeInsets.all(rs(context, 16)),
                  decoration: BoxDecoration(
                    color: done ? accentTeal.withOpacity(0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(rs(context, 16)),
                    border: Border.all(
                      color: done ? accentTeal.withOpacity(0.4) : Colors.blueGrey.shade50,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: done ? accentTeal : Colors.blueGrey.shade300,
                        size: rs(context, 22),
                      ),
                      SizedBox(width: rs(context, 14)),
                      Expanded(
                        child: Text(
                          recipe.instructions[index],
                          style: GoogleFonts.poppins(
                            fontSize: rs(context, 14),
                            color: done ? Colors.blueGrey : Colors.blueGrey.shade800,
                            height: 1.5,
                            decoration: done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _buildBottomButton(context, "Finish & Rate", Icons.flag_rounded,
            () => setState(() => _phase = _Phase.rate)),
      ],
    );
  }

  Widget _buildRatePhase(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 32)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_rounded, color: Colors.amber, size: rs(context, 56)),
                  SizedBox(height: rsh(context, 16)),
                  Text(
                    "How did it turn out?",
                    style: GoogleFonts.poppins(
                      fontSize: rs(context, 20),
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  SizedBox(height: rsh(context, 8)),
                  Text(
                    "Rate ${recipe.title} to help improve your recommendations.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: rs(context, 13),
                      color: Colors.blueGrey,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: rsh(context, 24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final starValue = i + 1;
                      final filled = starValue <= _selectedRating.round();
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = starValue.toDouble()),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: rs(context, 4)),
                          child: Icon(
                            filled ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: rs(context, 38),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildBottomButton(context, "Submit Rating", Icons.check_rounded, _submitRating),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.fromLTRB(rs(context, 20), 0, rs(context, 20), rsh(context, 20)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: rsh(context, 56),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
            ),
            borderRadius: BorderRadius.circular(rs(context, 16)),
            boxShadow: [
              BoxShadow(
                color: accentTeal.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: rs(context, 20)),
                SizedBox(width: rs(context, 10)),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: rs(context, 16),
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
