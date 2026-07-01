import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_sizes.dart';
import '../models/fish_specie.dart';
import '../screens/specie_detail_screen.dart';
import '../../species/widgets/species_slider.dart';

class DiscoverSpeciesScreen extends StatefulWidget {
  const DiscoverSpeciesScreen({super.key});

  @override
  State<DiscoverSpeciesScreen> createState() => _DiscoverSpeciesScreenState();
}

class _DiscoverSpeciesScreenState extends State<DiscoverSpeciesScreen> {
  String selectedCategory = "All";
  String _searchQuery = "";
  final List<String> categories = ["All", "Marine", "Freshwater"];
  final TextEditingController _searchController = TextEditingController();

  final List<FishSpecies> speciesList = SpeciesSlider.speciesList;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A5694);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: rs(context, 20)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),

            _buildCategoryFilters(context, primaryBlue),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: rs(context, 20),
                  vertical: rsh(context, 10),
                ),
                itemCount: speciesList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final fish = speciesList[index];
                  final isFreshwater = fish.category.toLowerCase().contains('freshwater') ||
                      fish.category.toLowerCase().contains('carp') ||
                      fish.category.toLowerCase().contains('shad');
                  if (selectedCategory == "Freshwater" && !isFreshwater) return const SizedBox.shrink();
                  if (selectedCategory == "Marine" && isFreshwater) return const SizedBox.shrink();
                  if (_searchQuery.isNotEmpty) {
                    final match = fish.name.toLowerCase().contains(_searchQuery) ||
                        fish.urduName.contains(_searchQuery) ||
                        fish.category.toLowerCase().contains(_searchQuery) ||
                        fish.region.toLowerCase().contains(_searchQuery);
                    if (!match) return const SizedBox.shrink();
                  }
                  return _buildSpeciesCard(context, fish);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 20), rs(context, 20), rsh(context, 10)),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
          decoration: InputDecoration(
            hintText: "Search species or region...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: rs(context, 14)),
            prefixIcon: Icon(Icons.search, color: Colors.grey, size: rs(context, 22)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.grey, size: rs(context, 20)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: rsh(context, 15)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 15)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context, Color primary) {
    return Container(
      height: rsh(context, 65),
      padding: EdgeInsets.symmetric(vertical: rsh(context, 10)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: rs(context, 20)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: rs(context, 12)),
              padding: EdgeInsets.symmetric(horizontal: rs(context, 30)),
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(rs(context, 25)),
                border: Border.all(
                  color: isSelected ? primary : Colors.grey.shade200,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: rs(context, 13),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpeciesCard(BuildContext context, FishSpecies fish) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpeciesDetailScreen(fish: fish),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: rsh(context, 25)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rs(context, 20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(rs(context, 20)),
                  ),
                  child: fish.imagePath.startsWith('assets/')
                      ? Image.asset(fish.imagePath, height: rsh(context, 200), width: double.infinity, fit: BoxFit.cover)
                      : Image.network(
                          fish.imagePath,
                          height: rsh(context, 200),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: rsh(context, 200),
                            color: const Color(0xFF0D2E5C),
                            child: Icon(Icons.set_meal_rounded, color: Colors.white38, size: rs(context, 60)),
                          ),
                        ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(rs(context, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fish.category.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1A5694),
                      fontSize: rs(context, 10),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: rsh(context, 4)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        fish.name,
                        style: GoogleFonts.poppins(
                          fontSize: rs(context, 18),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A5694),
                        ),
                      ),
                      SizedBox(width: rs(context, 8)),
                      Text(
                        fish.urduName,
                        style: GoogleFonts.poppins(
                          fontSize: rs(context, 14),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A5694).withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: rsh(context, 2)),
                  Text(
                    fish.tip,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.blueGrey,
                      fontSize: rs(context, 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
