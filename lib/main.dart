import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const SubtractionGame());
}

// If you have code/tests referring to 'MyApp', change them to 'SubtractionGame'.
// There is no 'MyApp' class in this file; 'SubtractionGame' is your main widget.

class SubtractionGame extends StatelessWidget {
  const SubtractionGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Subtraction Game',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum Difficulty { grade1, grade2, grade3, grade4, grade5 }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int num1 = 0;
  int num2 = 0;
  int correctAnswer = 0;
  List<int> options = [];

  String message = '';
  Color messageColor = Colors.green;
  bool answered = false;

  int questionCount = 0;
  int score = 0;
  bool showSummary = false;

  Difficulty? selectedDifficulty;
  int timer = 10;
  late VoidCallback _timerCallback;

  @override
  void initState() {
    super.initState();
    _timerCallback = () {
      if (mounted && !answered && !showSummary && selectedDifficulty != null) {
        setState(() {
          timer--;
          if (timer <= 0) {
            answered = true;
            message = '⏰ Time\'s up!';
            messageColor = Colors.red;
            questionCount++;
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                if (questionCount >= 10) {
                  setState(() {
                    showSummary = true;
                  });
                } else {
                  setState(() {
                    generateQuestion();
                  });
                }
              }
            });
          }
        });
      }
    };
  }

  void startTimer() {
    timer = 10;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || answered || showSummary || selectedDifficulty == null) return false;
      _timerCallback();
      return timer > 0 && !answered && !showSummary;
    });
  }

  void generateQuestion() {
    Random rand = Random();
    int maxNum = 10;
    switch (selectedDifficulty) {
      case Difficulty.grade1:
        maxNum = 10;
        break;
      case Difficulty.grade2:
        maxNum = 50;
        break;
      case Difficulty.grade3:
        maxNum = 200;
        break;
      case Difficulty.grade4:
        maxNum = 1000;
        break;
      case Difficulty.grade5:
        maxNum = 9999;
        break;
      default:
        maxNum = 10;
    }
    num1 = rand.nextInt(maxNum) + 1;
    num2 = rand.nextInt(maxNum) + 1;

    // Ensure no negative answers by swapping
    if (num2 > num1) {
      int temp = num1;
      num1 = num2;
      num2 = temp;
    }

    correctAnswer = num1 - num2;

    // Generate 4 tricky options close to the correct answer
    options = [correctAnswer];
    while (options.length < 4) {
      int offset = rand.nextInt(6) + 1;
      int sign = rand.nextBool() ? 1 : -1;
      int wrong = correctAnswer + (offset * sign);

      if (wrong >= 0 && wrong <= maxNum && !options.contains(wrong)) {
        options.add(wrong);
      }
    }
    options.shuffle();
    message = '';
    messageColor = Colors.green;
    answered = false;
    startTimer();
  }

  void checkAnswer(int selected) {
    if (answered) return;
    setState(() {
      answered = true;
      if (selected == correctAnswer) {
        message = '✅ Correct!';
        messageColor = Colors.green;
        score++;
      } else {
        message = '❌ Incorrect!';
        messageColor = Colors.red;
      }
      // Move questionCount++ AFTER showing the question
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          questionCount++; // <-- increment here
          if (questionCount >= 10) {
            setState(() {
              showSummary = true;
            });
          } else {
            setState(() {
              generateQuestion();
            });
          }
        }
      });
    });
  }

  void restartGame() {
    setState(() {
      score = 0;
      questionCount = 0;
      showSummary = false;
      message = '';
      answered = false;
      generateQuestion();
    });
  }

  void backToMenu() {
    setState(() {
      selectedDifficulty = null;
      showSummary = false;
      questionCount = 0;
      score = 0;
      message = '';
      answered = false;
    });
  }

  void exitGame() {
    Navigator.of(context).maybePop();
  }

  Widget difficultySelector() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Difficulty Level',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade1;
                  generateQuestion();
                });
              },
              child: const Text('Grade 1 '),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade2;
                  generateQuestion();
                });
              },
              child: const Text('Grade 2 '),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade3;
                  generateQuestion();
                });
              },
              child: const Text('Grade 3 '),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade4;
                  generateQuestion();
                });
              },
              child: const Text('Grade 4 '),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = Difficulty.grade5;
                  generateQuestion();
                });
              },
              child: const Text('Grade 5 '),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Subtraction Game',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (selectedDifficulty == null)
            difficultySelector()
          else if (showSummary)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Game Over!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'You answered $score out of 10 correctly!',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: restartGame,
                      child: const Text('Restart'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: backToMenu,
                      child: const Text('Back to Menu'),
                    ),
                  ],
                ),
              ),
            )
          else
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Score: $score',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Q: $questionCount/10', // <-- FIXED: show current question number
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'What is $num1 - $num2 ?',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Time left: $timer s',
                          style: TextStyle(
                            fontSize: 22,
                            color: timer <= 3 ? Colors.red : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        for (var option in options)
                          ElevatedButton(
                            onPressed: answered ? null : () => checkAnswer(option),
                            child: Text('$option', style: const TextStyle(fontSize: 24)),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 24,
                            color: messageColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: restartGame,
                          child: const Text('Restart'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: backToMenu,
                          child: const Text('Back to Menu'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: exitGame,
                          child: const Text('Exit'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}