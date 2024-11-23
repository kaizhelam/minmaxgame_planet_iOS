import 'package:flutter/material.dart';
import 'package:minmaxgame_planet/gamewidget/game_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  // Background widget
  Widget menuBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Image.asset(
        "assets/images/bg-menu.jpg",
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black.withOpacity(0.5),
        colorBlendMode: BlendMode.darken,
      ),
    );
  }

  // Floating planet widget
  Widget floatingPlanets() {
    double screenWidth = MediaQuery.of(context).size.width;
    double planetSize = screenWidth > 800 ? 120 : 100; // Larger planet on wide screens

    return Positioned(
      top: 80,
      left: 30,
      child: Image.asset(
        'assets/images/planet1.png',
        width: planetSize,
      ),
    );
  }

  // Rotating planet widget
  Widget rotatingPlanet() {
    double screenWidth = MediaQuery.of(context).size.width;
    double planetSize = screenWidth > 800 ? 150 : 120; // Larger rotating planet on wide screens

    return Positioned(
      bottom: 80,
      right: 130,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: animationController.value * 6.28,
            child: child,
          );
        },
        child: Image.asset(
          'assets/images/earth.png',
          width: planetSize,
        ),
      ),
    );
  }

  // Logo image widget
  Widget logoImage() {
    double screenWidth = MediaQuery.of(context).size.width;
    double logoSize = screenWidth > 800 ? 500 : 300; // Larger logo on wide screens

    return Positioned(
      top: 130,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/images/game-logo.png',
          width: logoSize,
        ),
      ),
    );
  }

  // Play button widget
  Widget playButton() {
    double screenWidth = MediaQuery.of(context).size.width;
    double playButton = screenWidth > 800 ? 500 : 250; // Larger logo on wide screens

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GamePage(),
          ),
        );
      },
      child: Padding(
        padding:  EdgeInsets.only(top: screenWidth > 800 ? 440 : 380),
        child: Center(
          child: Image.asset(
            "assets/images/button-start.png",
            width: playButton,
          ),
        ),
      ),
    );
  }

  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          menuBackground(),
          floatingPlanets(),
          rotatingPlanet(),
          logoImage(),
          playButton(),
        ],
      ),
    );
  }
}
