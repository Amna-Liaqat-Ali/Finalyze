import 'dart:async';

import 'package:Finalyze/auth/screens/welcome_screen.dart';
import 'package:Finalyze/core/user_session.dart'; // Imported to check session
import 'package:Finalyze/screens/Main/MainScreen.dart';
import 'package:audioplayers/audioplayers.dart';
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
            _videoController.setVolume(0.0);
            _videoController.play();
          });

    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(100.0);
    _audioPlayer.play(AssetSource('sounds/ocean_sound.mp3'));

    Timer(const Duration(microseconds: 800), () {
      setState(() => _startAnimation = true);
    });

    _kickstartSessionAndRoute();
  }

  //  load data quietly while splash plays
  Future<void> _kickstartSessionAndRoute() async {
    // Read the disk storage check while the video plays backgrounded
    await UserSession.loadSession();

    // Allow splash screen to show for at least 5 seconds total runtime
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    _videoController.pause();
    _audioPlayer.stop();

    // Conditional navigation based on login status evaluation
    if (UserSession.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
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
          SizedBox.expand(
            child: _videoController.value.isInitialized
                ? VideoPlayer(_videoController)
                : Container(color: const Color(0xFF001F3F)),
          ),
          Container(color: Colors.black.withOpacity(0.2)),
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
