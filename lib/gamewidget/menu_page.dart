import 'package:flutter/material.dart';
import 'package:minmaxgame_planet/gamewidget/game_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin{
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
        color: Colors.black.withOpacity(0.5),
        colorBlendMode: BlendMode.darken,
      ),
    );
  }

  Widget floatingPlanets() {
    return Positioned(
      top: 80,
      left: 30,
      child: Image.asset(
        'assets/images/planet1.png',
        width: 100,
      ),
    );
  }

Widget rotatingPlanet() {
  return Positioned(
    bottom: 80,
    right: 50,
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
        width: 120,
      ),
    ),
  );
}

  Widget floatingPlanet() {
    return Positioned(
      top: 80,
      left: 30,
      child: Image.asset(
        'assets/images/planet1.png',
        width: 100,
      ),
    );
  }


  Widget logoImage() {
    return Positioned(
      top: 130,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/images/game-logo.png',
          width: 300,
        ),
      ),
    );
  }

  Widget playButton() {
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
        padding: const EdgeInsets.only(top: 380),
        child: Center(
          child: Image.asset(
            "assets/images/button-start.png",
            width: 250,
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
