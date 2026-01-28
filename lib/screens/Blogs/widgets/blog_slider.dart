import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/youtube_Blog.dart';

class YouTubeBlogSlider extends StatelessWidget {
  YouTubeBlogSlider({super.key});

  final List<YouTubeBlog> blogs = [
    YouTubeBlog(
      title: "How to check Fish Freshness",
      thumbnailUrl: "https://img.youtube.com/vi/DloJ9SmZFQs/maxresdefault.jpg",
      videoUrl: "https://www.youtube.com/watch?v=DloJ9SmZFQs",
    ),
    YouTubeBlog(
      title: "Identifying Pakistani Fish",
      thumbnailUrl: "https://img.youtube.com/vi/szT3TWxn2Cw/maxresdefault.jpg",
      videoUrl: "https://www.youtube.com/watch?v=szT3TWxn2Cw",
    ),
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Expert Guides",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _launchURL(blogs[index].videoUrl),
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        //Thumbnail Image
                        Image.network(
                          blogs[index].thumbnailUrl,
                          fit: BoxFit.cover,
                          width: 280,
                          height: 180,
                        ),

                        Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            radius: 25,
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                color: Colors.black.withOpacity(0.5),
                                child: Text(
                                  blogs[index].title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
