import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/fish_specie.dart';

class SpeciesSlider extends StatelessWidget {
  const SpeciesSlider({super.key});

  static final List<FishSpecies> speciesList = [
    FishSpecies(
      name: "Heera (ہیرا)",
      category: "Red Snapper",
      imagePath: "assets/images/heera.jpeg",
      tip: "Eyes should be clear and bulging, not sunken or cloudy.",
    ),
    FishSpecies(
      name: "Rohu (رہو)",
      category: "Freshwater Carp",
      imagePath: "assets/images/rohu.jpeg",
      tip: "Gills should be bright red; scales must be tight and shiny.",
    ),
    FishSpecies(
      name: "Surmai (سرمئی)",
      category: "Marine / Mackerel",
      imagePath: "assets/images/surmai.jpeg",
      tip: "Flesh should be firm and spring back when pressed.",
    ),
    FishSpecies(
      name: "Palla (پلاّ)",
      category: "River Shad",
      imagePath: "assets/images/palla.jpeg",
      tip: "Look for a distinct silvery sheen and oily texture.",
    ),
    FishSpecies(
      name: "Paplet (پاپلیٹ)",
      category: "Pomfret",
      imagePath: "assets/images/paplet.jpeg",
      tip: "Check for a stiff body and moist, white skin.",
    ),
    FishSpecies(
      name: "Mushka (مشکا)",
      category: "Croaker",
      imagePath: "assets/images/mushka.jpeg",
      tip: "Avoid if the skin feels slimy or has a strong 'fishy' odor.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Discover Species",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "View All",
                  style: TextStyle(color: Colors.cyanAccent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: speciesList.length,
            itemBuilder: (context, index) {
              final fish = speciesList[index];
              return _buildSpeciesCard(fish);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesCard(FishSpecies fish) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(fish.imagePath, fit: BoxFit.cover),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      fish.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fish.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fish.tip,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    color: Colors.white.withOpacity(0.1),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
