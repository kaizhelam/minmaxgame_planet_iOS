import 'package:flutter/material.dart';
import 'package:minmaxgame_planet/gamewidget/game_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Widget menuBackground() {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/bg-menu.jpg"),
              fit: BoxFit.cover)),
    );
  }

  Widget logoImage() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/images/game-logo.png',
          width: 350,
          fit: BoxFit.cover,
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
        padding: const EdgeInsets.only(top: 500),
        child: Center(
          child: Image.asset(
            "assets/images/button-start.png",
            width: 250,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [menuBackground(), logoImage(), playButton()],
      ),
    );
  }
}
