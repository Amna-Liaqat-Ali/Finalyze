import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fish_freshness_detection/auth/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();

    _videoController =
        VideoPlayerController.asset("assets/videos/splash_video.mp4")
          ..initialize().then((_) {
            setState(() {});
            _videoController.setLooping(true);
            _videoController.setVolume(0.0); // Mute video to use separate MP3
            _videoController.play();
          });

    // Play Separate Background MP3
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(100.0);
    _audioPlayer.play(AssetSource('sounds/ocean_sound.mp3'));
    // Trigger Title Animation
    Timer(const Duration(microseconds: 800), () {
      setState(() => _startAnimation = true);
    });

    Timer(const Duration(seconds: 5), () {
      _videoController.pause();
      _audioPlayer.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Video Layer
          SizedBox.expand(
            child: _videoController.value.isInitialized
                ? VideoPlayer(_videoController)
                : Container(color: const Color(0xFF001F3F)),
          ),

          Container(color: Colors.black.withOpacity(0.2)),

          // Animated Title Layer
          Center(
            child: AnimatedOpacity(
              duration: const Duration(seconds: 2),
              opacity: _startAnimation ? 1.0 : 0.0,
              child: AnimatedScale(
                duration: const Duration(seconds: 2),
                scale: _startAnimation ? 1.0 : 0.7,
                curve: Curves.easeOutBack,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Finalyze",
                      style: GoogleFonts.poppins(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          const Shadow(
                            blurRadius: 20,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "SMART GUIDE TO FRESH SEAFOOD",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
