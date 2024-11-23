import 'dart:async';
import 'dart:ffi';
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
  int _nextNumber = 0;
  int countGenerate = 9;
  int timeLeft = 0;
  Timer? _timer;
  final Map<int, int> _uniqueRandomImageIndexes = {};
  String _gameMode = "Min Max";
  bool _showMessage = false;
  String _message = "";
  late AnimationController _controller;
  late Animation<double> _animation;
  int _lives = 3;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _generateRandomNumbers();
    _startGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimation();
    });
  }

  void _initializeAnimation() {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    print(screenWidth);
    Duration animationDuration =
        screenWidth > 700 ? Duration(seconds: 60) : Duration(seconds: 60);
    double endValue = screenWidth > 700 ? 380.0 : 85.0;

    // Initialize the AnimationController and animation
    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    // Initialize the Tween with the correct end value
    _animation =
        Tween<double>(begin: 10, end: endValue).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Mark as initialized and start the animation
    setState(() {
      _isInitialized = true;
    });

    _controller.forward(); // Start the animation once initialized
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _startGame() {
    setState(() {
      timeLeft = 60;
      _lives = 3;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          _finalResultDisplay("Time's Up!", "The sun has destroyed the Earth",
              "Rise Again", "End the Saga");
        });
      }
    });
  }

  void _generateRandomNumbers() {
    final random = Random();
    final Set<int> usedIndexes = {};
    final Set<int> uniqueNumbers = {};
    setState(() {
      while (uniqueNumbers.length < countGenerate) {
        uniqueNumbers.add(random.nextInt(200) + 10);
      }

      _numbers = uniqueNumbers.toList();
      _numbers.shuffle();

      _nextNumber = _gameMode == "Min Max"
          ? _numbers.reduce((a, b) => a < b ? a : b)
          : _numbers.reduce((a, b) => a > b ? a : b);
      for (int i = 0; i < _numbers.length; i++) {
        int newIndex;
        do {
          newIndex = random.nextInt(14) + 1;
        } while (usedIndexes.contains(newIndex) || newIndex == 8);

        usedIndexes.add(newIndex);
        _uniqueRandomImageIndexes[_numbers[i]] = newIndex;
      }
    });
  }

  void _onNumberTap(int number, int imageIndex) async {
    if ((_gameMode == "Min Max" && number == _nextNumber) ||
        (_gameMode == "Max Min" && number == _nextNumber)) {
      setState(() {
        _numbers.remove(number);
        _uniqueRandomImageIndexes.remove(number);

        if (_numbers.isNotEmpty) {
          _nextNumber = _gameMode == "Min Max"
              ? _numbers.reduce((a, b) => a < b ? a : b)
              : _numbers.reduce((a, b) => a > b ? a : b);
        }
      });
      _checkFinalResult();
    } else {
      _showErrorMessage("Oops wrong guess!");
      _lives--;
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
      }
      _checkFinalResult();
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
          ? "You save the Earth!"
          : "The sun has destroyed the Earth";

      Future.delayed(const Duration(seconds: 1), () {
        _finalResultDisplay(title, message, "Rise Again", "End the Saga");
        _timer?.cancel();
        _controller.stop();
      });
    }

    if (_lives == 0) {
      _finalResultDisplay("No more lives", "Try to protect our Earth",
          "Rise Again", "End the Saga");
      _timer?.cancel();
      _controller.stop();
    }
  }

  void _finalResultDisplay(
  String title, String message, String startGame, String quitGame) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Builder(
        builder: (context) {
          double screenWidth = MediaQuery.of(context).size.width;
          double dialogWidth = screenWidth * 0.9; 
          double titleFontSize = screenWidth > 800 ? 50 : 41; 
          double messageFontSize = screenWidth > 800 ? 38 : 30; 
          double buttonFontSize = screenWidth > 800 ? 35 : 28; 
          return Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: GoogleFonts.spicyRice(
                    color: const Color(0xFFFFBE26),
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Message
                Text(
                  message,
                  style: GoogleFonts.spicyRice(
                    color: const Color(0xFFFFBE26),
                    fontSize: messageFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Start Game Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBE26),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartGame();
                  },
                  child: Text(
                    startGame,
                    style: GoogleFonts.spicyRice(
                      color: Colors.white,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Quit Game Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    quitGame,
                    style: GoogleFonts.spicyRice(
                      color: Colors.white,
                      fontSize: buttonFontSize - 4, // Slightly smaller font size for quit button
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}



  void _restartGame() {
    _timer?.cancel();
    setState(() {
      _generateRandomNumbers();
      timeLeft = 60;
      _controller.reset();
      _controller.forward();
      _lives = 3;
    });
    _startGame();
  }

  Widget randomNumberGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if the screen width is greater than 700
        bool isWideScreen = constraints.maxWidth > 700;
        double imageSize =
            isWideScreen ? 250 : 200; // Adjust image size for wide screens
        double fontSize = isWideScreen ? 60 : 35;
        double stokeSize = isWideScreen ? 57 : 35;

        return Center(
          // Center the entire Grid on the screen
          child: Padding(
            padding: const EdgeInsets.only(
                bottom: 8.0), // Reduce bottom padding here
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 4.0, // Reduce space between rows
              ),
              itemCount: _numbers.length,
              itemBuilder: (context, index) {
                int number = _numbers[index];
                int? imageIndex = _uniqueRandomImageIndexes[number];
                if (imageIndex == null) {
                  return const SizedBox();
                }

                return GestureDetector(
                  onTap: () => _onNumberTap(number, imageIndex),
                  child: Stack(
                    alignment:
                        Alignment.center, // Align Stack children at the center
                    children: [
                      // Background image
                      Image.asset(
                        "assets/images/planet$imageIndex.png",
                        fit: BoxFit.cover,
                        width: imageSize,
                        height: imageSize,
                      ),
                      // Overlay text
                      Stack(
                        alignment:
                            Alignment.center, // Center the text in the Stack
                        children: [
                          // Stroke text for outline
                          Text(
                            '$number',
                            style: TextStyle(
                              fontSize: stokeSize,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 6.0
                                ..color = const Color(0xFF4C1884),
                            ),
                          ),
                          // Main text with white color
                          Text(
                            '$number',
                            style: GoogleFonts.spicyRice(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if the screen width exceeds 800
        bool isWideScreen = constraints.maxWidth > 700;
        return Stack(
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
              top: 80,
              right: 0,
              left: 0,
              child: Center(
                child: Text(
                  "Tap the correct ascending order of numbers before the sun strikes the earth",
                  style: GoogleFonts.spicyRice(
                    fontSize: isWideScreen ? 30 : 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: isWideScreen ? 120 : 190),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        // Move the sun image only
                        return Transform.translate(
                          offset: Offset(_animation.value, 0),
                          child: child,
                        );
                      },
                      child: Image.asset(
                        "assets/images/sun.png",
                        width: isWideScreen
                            ? 250
                            : 200, // Adjust size based on screen width
                        height: isWideScreen ? 250 : 200,
                      ),
                    ),
                    const SizedBox(width: 40),
                    Container(
                      width: isWideScreen
                          ? 250
                          : 200, // Adjust width based on screen width
                      child: Image.asset(
                        "assets/images/earth.png",
                        fit: BoxFit.cover,
                        width: isWideScreen ? 250 : 200,
                        height: isWideScreen ? 250 : 200,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:
                    EdgeInsets.only(top: isWideScreen ? 360 : 415, left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < _lives; i++)
                          Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: isWideScreen ? 43 : 29,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      'Timer: $timeLeft',
                      style: GoogleFonts.spicyRice(
                        fontSize: isWideScreen ? 43 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _gameMode,
                      dropdownColor: const Color(0xFF4D1884),
                      onChanged: (String? newMode) {
                        if (newMode != null && newMode != _gameMode) {
                          setState(() {
                            _gameMode = newMode;
                            _restartGame();
                          });
                        }
                      },
                      items: <String>["Min Max", "Max Min"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: GoogleFonts.spicyRice(
                              fontSize: isWideScreen ? 43 : 28,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                      // Remove underline
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 390, left: 16, right: 16),
                child: SizedBox(
                  child: randomNumberGrid(),
                ),
              ),
            ),
            errorMessage(),
          ],
        );
      },
    );
  }

  Widget errorMessage() {
    if (_showMessage) {
      return Positioned(
        bottom: 25,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _message,
              style: GoogleFonts.spicyRice(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Ensure that animation is only accessed after it's initialized
          if (!_isInitialized) {
            // Show a loading indicator while the animation is being initialized
            return Center(child: CircularProgressIndicator());
          }

          return _buildGameContent();
        },
      ),
    );
  }
}
