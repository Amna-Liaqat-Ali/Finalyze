import 'package:Finalyze/screens/home/widgets/specie_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../species/models/fish_specie.dart';

class DiscoverSpeciesScreen extends StatefulWidget {
  const DiscoverSpeciesScreen({super.key});

  @override
  State<DiscoverSpeciesScreen> createState() => _DiscoverSpeciesScreenState();
}

class _DiscoverSpeciesScreenState extends State<DiscoverSpeciesScreen> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Saltwater", "Freshwater"];

  final List<FishSpecies> speciesList = [
    FishSpecies(
      name: "Heera (ہیرا)",
      category: "Saltwater",
      imagePath: "assets/images/heera.jpeg",
      tip: "Eyes should be clear and bulging, not sunken or cloudy.",
    ),
    FishSpecies(
      name: "Paplet (پاپلیٹ)",
      category: "Saltwater",
      imagePath: "assets/images/paplet.jpeg",
      tip: "Check for a stiff body and moist, white skin.",
    ),
    FishSpecies(
      name: "Rohu (رہو)",
      category: "Freshwater",
      imagePath: "assets/images/rohu.jpeg",
      tip: "Gills should be bright red; scales must be tight and shiny.",
    ),
    FishSpecies(
      name: "Surmai (سرمئی)",
      category: "Saltwater",
      imagePath: "assets/images/surmai.jpeg",
      tip: "Flesh should be firm and spring back when pressed.",
    ),
    FishSpecies(
      name: "Palla (پلاّ)",
      category: "Freshwater",
      imagePath: "assets/images/palla.jpeg",
      tip: "Look for a distinct silvery sheen and oily texture.",
    ),
    FishSpecies(
      name: "Mushka (مشکا)",
      category: "Saltwater",
      imagePath: "assets/images/mushka.jpeg",
      tip: "Avoid if the skin feels slimy or has a strong 'fishy' odor.",
    ),
  ];

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),

            _buildCategoryFilters(primaryBlue),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: speciesList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final fish = speciesList[index];
                  // Category filtering logic
                  if (selectedCategory != "All" &&
                      fish.category != selectedCategory) {
                    return const SizedBox.shrink();
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
          decoration: InputDecoration(
            hintText: "Search species or region...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(Color primary) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == categories[index];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(25),
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
                    fontSize: 13,
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
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    fish.imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    radius: 18,
                    child: const Icon(
                      Icons.favorite_border,
                      color: Color(0xFF1A5694),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fish.category.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1A5694),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fish.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A5694),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fish.tip,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.blueGrey,
                      fontSize: 12,
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
