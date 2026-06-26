import 'dart:ui';

import 'package:flutter/material.dart';

import '../screens/specie_detail_screen.dart';
import '../models/fish_specie.dart';

class SpeciesSlider extends StatelessWidget {
  const SpeciesSlider({super.key});

  static final List<FishSpecies> speciesList = [
    FishSpecies(
      name: "Heera",
      urduName: "ہیرا",
      category: "Red Snapper",
      imagePath: "assets/images/heera.jpg",
      tip: "Eyes should be clear and bulging, not sunken or cloudy.",
      scientificName: "Lutjanus malabaricus",
      region: "Arabian Sea",
      season: "Oct – Feb",
      marketValue: "Premium",
      habitat:
          "Heera inhabits rocky reefs and deep-sea structures along Pakistan's Arabian Sea coastline at depths of 30–100 m. It prefers hard substrates and is commonly caught near Karachi and Makran coast.",
      freshnessIndicators: const [
        FreshnessIndicator(icon: Icons.visibility_outlined, title: "Clear, bulging eyes", detail: "Sunken or cloudy eyes indicate age. Fresh Heera has protruding, transparent eyes."),
        FreshnessIndicator(icon: Icons.water_drop_outlined, title: "Bright red gills", detail: "Gills should be vivid red or pink — grey or brown gills mean the fish is old."),
        FreshnessIndicator(icon: Icons.back_hand_outlined, title: "Firm, springy flesh", detail: "Press the flesh — it should bounce back immediately. Soft or mushy flesh is a spoilage sign."),
        FreshnessIndicator(icon: Icons.air_outlined, title: "Mild ocean scent", detail: "Fresh fish smells of the sea. A sharp ammonia or sour odor means it has turned."),
      ],
      nutrition: const NutritionInfo(protein: "20g", omega3: "0.4g", calories: "100 kcal", fat: "1.7g"),
    ),
    FishSpecies(
      name: "Rohu",
      urduName: "رہو",
      category: "Freshwater Carp",
      imagePath: "assets/images/rohu.webp",
      tip: "Gills should be bright red; scales must be tight and shiny.",
      scientificName: "Labeo rohita",
      region: "Indus River Basin",
      season: "Nov – Mar",
      marketValue: "Moderate",
      habitat:
          "Rohu is a riverine fish found throughout the Indus River system including major canals and freshwater lakes of Punjab and Sindh. It thrives in slow-moving deep waters and is widely farmed in aquaculture ponds.",
      freshnessIndicators: const [
        FreshnessIndicator(icon: Icons.layers_outlined, title: "Tight, shiny scales", detail: "Scales should lie flat and gleam. Loose or dull scales suggest the fish has been stored too long."),
        FreshnessIndicator(icon: Icons.water_drop_outlined, title: "Bright red gills", detail: "Rohu gills should be a deep red. Pale or brown-tinged gills are a sign of deterioration."),
        FreshnessIndicator(icon: Icons.visibility_outlined, title: "Clear eyes", detail: "Eyes must be clear and moist. Milky or sunken eyes indicate the fish is past its prime."),
        FreshnessIndicator(icon: Icons.back_hand_outlined, title: "Stiff, rigid body", detail: "A fresh Rohu is rigid and holds its shape. Limp, floppy fish has lost freshness."),
      ],
      nutrition: const NutritionInfo(protein: "16g", omega3: "0.2g", calories: "97 kcal", fat: "2.0g"),
    ),
    FishSpecies(
      name: "Surmai",
      urduName: "سرمئی",
      category: "Kingfish",
      imagePath: "assets/images/surmai.jpg",
      tip: "Flesh should be firm and spring back when pressed.",
      scientificName: "Scomberomorus commerson",
      region: "Arabian Sea",
      season: "Aug – Dec",
      marketValue: "Premium",
      habitat:
          "Surmai is a fast-swimming pelagic fish found in open offshore waters of the Arabian Sea. It migrates along Pakistan's coastline seasonally and is highly prized in Karachi fish markets for its dense, flavourful flesh.",
      freshnessIndicators: const [
        FreshnessIndicator(icon: Icons.auto_awesome_outlined, title: "Bright silvery sheen", detail: "Fresh Surmai has a metallic, rainbow-like sheen on the skin. Dull grey skin means it's aging."),
        FreshnessIndicator(icon: Icons.back_hand_outlined, title: "Dense, firm flesh", detail: "The flesh is naturally firm and meaty. Surmai that crumbles or flakes apart easily is no longer fresh."),
        FreshnessIndicator(icon: Icons.visibility_outlined, title: "Transparent eyes", detail: "Eyes should be clear and slightly bulging. Cloudy or sunken eyes indicate the fish is not fresh."),
        FreshnessIndicator(icon: Icons.air_outlined, title: "No ammonia smell", detail: "Surmai should smell briny and clean. Any ammonia or sharp fishy odor is a spoilage indicator."),
      ],
      nutrition: const NutritionInfo(protein: "19g", omega3: "1.3g", calories: "134 kcal", fat: "4.5g"),
    ),
    FishSpecies(
      name: "Palla",
      urduName: "پلاّ",
      category: "Hilsa / River Shad",
      imagePath: "assets/images/palla.webp",
      tip: "Look for a distinct silvery sheen and oily texture.",
      scientificName: "Tenualosa ilisha",
      region: "Indus River, Sindh",
      season: "Jun – Sep",
      marketValue: "High",
      habitat:
          "Palla is an anadromous fish — it spends most of its life in the Arabian Sea and migrates upstream into the Indus River during monsoon season to spawn. It is considered a cultural delicacy of Sindh and is most abundant near Sukkur and Thatta.",
      freshnessIndicators: const [
        FreshnessIndicator(icon: Icons.auto_awesome_outlined, title: "Silver, oily skin", detail: "Fresh Palla has a distinctive oily, silver-blue sheen. Dry or dull skin means it's old."),
        FreshnessIndicator(icon: Icons.opacity_outlined, title: "Natural oiliness", detail: "Palla is naturally rich in fat. The flesh should look moist and slightly translucent when cut."),
        FreshnessIndicator(icon: Icons.visibility_outlined, title: "Bright, clear eyes", detail: "Eyes should be shiny and protrude slightly. Milky or sunken eyes are a red flag."),
        FreshnessIndicator(icon: Icons.water_drop_outlined, title: "Pink-red gills", detail: "Gills must be uniformly pink-red inside. Discoloration or brown spots indicate spoilage beginning."),
      ],
      nutrition: const NutritionInfo(protein: "21g", omega3: "1.7g", calories: "189 kcal", fat: "11g"),
    ),
    FishSpecies(
      name: "Paplet",
      urduName: "پاپلیٹ",
      category: "Silver Pomfret",
      imagePath: "assets/images/paplet.webp",
      tip: "Check for a stiff body and moist, white skin.",
      scientificName: "Pampus argenteus",
      region: "Arabian Sea, Karachi",
      season: "Year-round (Oct – Feb peak)",
      marketValue: "Premium",
      habitat:
          "Paplet inhabits sandy and muddy seabeds in shallow coastal waters at 10–50 m depth along the entire Pakistani coastline. It is the most commercially important fish species in Karachi and is exported widely across the Gulf region.",
      freshnessIndicators: const [
        FreshnessIndicator(icon: Icons.tonality_outlined, title: "Moist, pearly white skin", detail: "Fresh Paplet has smooth, moist, white-silver skin. Dried or yellowing skin indicates staleness."),
        FreshnessIndicator(icon: Icons.straighten_outlined, title: "Stiff, rigid body", detail: "Hold the fish horizontally — it should stay rigid. If it droops, freshness has declined."),
        FreshnessIndicator(icon: Icons.water_drop_outlined, title: "Pink-red gill arches", detail: "The gills behind the plate should be bright pink. Grey or brown discoloration means it's old."),
        FreshnessIndicator(icon: Icons.back_hand_outlined, title: "Firm, white flesh", detail: "When pressed, the flesh should spring back. Soft or mushy flesh is a rejection signal."),
      ],
      nutrition: const NutritionInfo(protein: "17g", omega3: "0.6g", calories: "96 kcal", fat: "1.9g"),
    ),
    FishSpecies(
      name: "Mushka",
      urduName: "مشکا",
      category: "Croaker",
      imagePath: "assets/images/mushka.webp",
      tip: "Avoid if the skin feels slimy or has a strong 'fishy' odor.",
      scientificName: "Johnius dussumieri",
      region: "Arabian Sea",
      season: "Year-round",
      marketValue: "Budget",
      habitat:
          "Mushka is a bottom-dwelling fish found in shallow estuaries, tidal flats, and muddy coastal waters at 5–30 m depth. It is abundant year-round along the Sindh and Balochistan coasts and is among the most affordable fish available in local markets.",
      freshnessIndicators: const [
        FreshnessIndicator(icon: Icons.do_not_touch_outlined, title: "No slimy coating", detail: "Fresh Mushka skin is moist but not slimy. Thick slime or stickiness signals bacterial growth."),
        FreshnessIndicator(icon: Icons.visibility_outlined, title: "Clear, full eyes", detail: "Eyes should be round, clear, and full. Sunken or milky eyes indicate the fish is old."),
        FreshnessIndicator(icon: Icons.air_outlined, title: "Mild, fresh sea smell", detail: "Croaker naturally has a mild smell. A strong sour or ammonia-like odor means it has spoiled."),
        FreshnessIndicator(icon: Icons.back_hand_outlined, title: "Firm texture", detail: "Press the flesh near the dorsal fin — it should be firm and elastic, not soft or mushy."),
      ],
      nutrition: const NutritionInfo(protein: "15g", omega3: "0.3g", calories: "88 kcal", fat: "1.2g"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: speciesList.length,
            itemBuilder: (context, index) {
              final fish = speciesList[index];
              return _buildSpeciesCard(context, fish);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesCard(BuildContext context, FishSpecies fish) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SpeciesDetailScreen(fish: fish)),
      ),
      child: Container(
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
                child: fish.imagePath.startsWith('assets/')
                    ? Image.asset(fish.imagePath, fit: BoxFit.cover)
                    : Image.network(
                        fish.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF0D2E5C),
                          child: const Icon(Icons.set_meal_rounded, color: Colors.white54, size: 40),
                        ),
                      ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.82)],
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
                    Text(
                      fish.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      fish.urduName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fish.category,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
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
                      padding: const EdgeInsets.all(7),
                      color: Colors.white.withOpacity(0.12),
                      child: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
