import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_sizes.dart';
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
        Text(
          "Expert Guides",
          style: TextStyle(
            color: Colors.white,
            fontSize: rs(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: rsh(context, 15)),
        SizedBox(
          height: sh(context, 0.213),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _launchURL(blogs[index].videoUrl),
                child: Container(
                  width: sw(context, 0.718),
                  margin: EdgeInsets.only(right: rs(context, 16)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(rs(context, 20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(rs(context, 20)),
                    child: Stack(
                      children: [
                        //Thumbnail Image
                        Image.network(
                          blogs[index].thumbnailUrl,
                          fit: BoxFit.cover,
                          width: sw(context, 0.718),
                          height: sh(context, 0.213),
                        ),

                        Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            radius: rs(context, 25),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: rs(context, 35),
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
                                padding: EdgeInsets.all(rs(context, 12)),
                                color: Colors.black.withOpacity(0.5),
                                child: Text(
                                  blogs[index].title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: rs(context, 13),
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
