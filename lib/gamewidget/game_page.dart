import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  final _random = Random();
  List<int> _numbers = [];
  List<List<int>> _collectedNumbers = [];
  int _nextNumber = 0;
  int countGenerate = 9;
  int timeLeft = 0;
  Timer? _timer;
  final Map<int, int> _uniqueRandomImageIndexes = {};

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _showMessage = false;
  String _message = "";

  @override
  void initState() {
    super.initState();
    _generateRandomNumbers();
    _startGame();

    // Initialize shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
        }
      });

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _startGame() {
    setState(() {
      timeLeft = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          _finalResultDisplay("Time's Up!", "Better luck next time",
              "Restart GAME", "Quit GAME");
        });
      }
    });
  }

  void _generateRandomNumbers() {
    final random = Random();
    final Set<int> usedIndexes = {};
    setState(() {
      _numbers = List.generate(countGenerate, (_) => _random.nextInt(200) + 10);
      _numbers.shuffle();
      _nextNumber = _numbers.reduce((a, b) => a < b ? a : b);
      _collectedNumbers = [];
      for (int i = 0; i < _numbers.length; i++) {
        int newIndex;

        // Generate a unique random index
        do {
          newIndex = random.nextInt(14) + 1; // Random number between 1 and 14
        } while (usedIndexes.contains(newIndex));

        usedIndexes.add(newIndex); // Mark this index as used
        _uniqueRandomImageIndexes[_numbers[i]] =
            newIndex; // Map number to image
      }
    });
  }

  void _onNumberTap(int number, int imageIndex) async {
    if (number == _nextNumber) {
      setState(() {
        // Add the number and image to the collected numbers
        _collectedNumbers.add([number, imageIndex]);
        _collectedNumbers.sort((a, b) =>
            a[0].compareTo(b[0])); // Ensure sorting after each collection

        // Remove the tapped number
        _numbers.remove(number);

        // Update _uniqueRandomImageIndexes
        _uniqueRandomImageIndexes.remove(number);

        // Update the next smallest number
        if (_numbers.isNotEmpty) {
          _nextNumber = _numbers.reduce((a, b) => a < b ? a : b);
        }
      });
      _checkFinalResult();
    } else {
      _shakeController.forward();
      _showErrorMessage("Oops wrong guess!");
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
      }
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _message = message;
      _showMessage = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showMessage = false;
      });
    });
  }

  void _checkFinalResult() {
    if (timeLeft == 0 || _numbers.isEmpty) {
      String title = _numbers.isEmpty ? "Congratulations!" : "Time's Up!";
      String message = _numbers.isEmpty
          ? "You collected all the numbers!"
          : "Better luck next time!";

      // Delay execution for 1.5 seconds
      Future.delayed(const Duration(seconds: 1), () {
        _finalResultDisplay(title, message, "Restart Game", "Quit Game");
        _timer?.cancel();
      });
    }
  }

  void _restartGame() {
    // Cancel any existing timer
    _timer?.cancel();

    // Reset game state
    setState(() {
      _collectedNumbers.clear();
      _generateRandomNumbers(); // Regenerate numbers and reset _nextNumber
      timeLeft = 60; // Reset timer
    });

    // Start the game timer again
    _startGame();
  }

  void _finalResultDisplay(
      String title, String message, String startGame, String quitGame) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              width: 380,
              height: 400,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/menu-number.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.spicyRice(color: Color(0xFFFFBE26),
                              fontSize: 42,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          message,
                          style:  GoogleFonts.spicyRice(color: Color(0xFFFFBE26),
                              fontSize: 23,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _restartGame();
                          },
                          child: Text(
                            startGame,
                            style:  GoogleFonts.spicyRice(color: Color(0xFFFFBE26),
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            quitGame,
                            style:  GoogleFonts.spicyRice(color: Color(0xFFFFBE26),
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget collectedNumbersList() {
    return Padding(
      padding: const EdgeInsets.only(top: 250.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 5.0, 
        children: _collectedNumbers.map((pair) {
          int number = pair[0];
          int imageIndex = pair[1];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage("assets/images/planet$imageIndex.png"))),
              child: Center(
                child: Stack(
                  children: [
                    Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6.0
                          ..color = const Color(0xFF4C1884),
                      ),
                    ),
                    Text(
                      '$number',
                      style: GoogleFonts.spicyRice(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget randomNumberRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _numbers.map((number) {
          // Null check before accessing the map
          int? imageIndex = _uniqueRandomImageIndexes[number];
          if (imageIndex == null) {
            return SizedBox(); 
          }

          return GestureDetector(
            onTap: () => _onNumberTap(number, imageIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/planet$imageIndex.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      Text(
                        '$number',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6.0
                            ..color = const Color(0xFF4C1884),
                        ),
                      ),
                      Text(
                        '$number',
                        style: GoogleFonts.spicyRice(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGameContent() {
    return Transform.translate(
      offset: Offset(_shakeAnimation.value, 0),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg-game.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
              top: -135,
              right: 0,
              left: 0,
              child: Image.asset(
                "assets/images/sun.png",
                fit: BoxFit.cover,
              )),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 300.0, left: 15),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Timer: $timeLeft',
                  style: GoogleFonts.spicyRice(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: collectedNumbersList(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 140,
                child: randomNumberRow(),
              ),
            ),
          ),
          errorMessage()
        ],
      ),
    );
  }

  Widget errorMessage() {
    return AnimatedOpacity(
      opacity: _showMessage ? 1.0 : 0.0,
      duration: const Duration(seconds: 1),
      child: Center(
        child: Text(
            _message,
            style: GoogleFonts.spicyRice(
              fontSize: 38,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ), 
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          return _buildGameContent();
        },
      ),
    );
  }
}
