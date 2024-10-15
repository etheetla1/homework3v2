import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(CardMatchingGame());

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<CardModel> cards = [];
  CardModel? selectedCard;
  bool isChecking = false;
  int score = 0;
  int time = 0;
  Timer? gameTimer;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startTimer();
  }

  void _initializeGame() {
    // Create a list of card pairs
    List<String> cardValues = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    cards = (cardValues + cardValues)
        .map((value) => CardModel(value: value, isFlipped: false))
        .toList();
    cards.shuffle();
  }

  void _startTimer() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!gameOver) {
        setState(() {
          time++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _flipCard(CardModel card) {
    if (isChecking || card.isFlipped || gameOver) return;

    setState(() {
      card.isFlipped = true;
    });

    if (selectedCard == null) {
      selectedCard = card;
    } else {
      isChecking = true;
      if (selectedCard!.value == card.value) {
        // Cards match, keep them flipped
        score += 10;
        selectedCard = null;
        _checkWinCondition();
      } else {
        // Cards don't match, flip them back after a delay
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            selectedCard!.isFlipped = false;
            card.isFlipped = false;
            score -= 2;
            selectedCard = null;
          });
        });
      }
      isChecking = false;
    }
  }

  void _checkWinCondition() {
    if (cards.every((card) => card.isFlipped)) {
      setState(() {
        gameOver = true;
      });
      _showVictoryMessage();
    }
  }

  void _showVictoryMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You matched all cards in $time seconds with a score of $score!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      score = 0;
      time = 0;
      gameOver = false;
      _initializeGame();
      _startTimer();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Matching Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Score: $score', style: TextStyle(fontSize: 20)),
                Text('Time: $time s', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4x4 grid
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(20),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _flipCard(cards[index]),
                  child: CardWidget(card: cards[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;

  CardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: card.isFlipped ? Colors.white : Colors.blue,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: card.isFlipped
            ? Text(
                card.value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            : Container(),
      ),
    );
  }
}

class CardModel {
  final String value;
  bool isFlipped;

  CardModel({required this.value, this.isFlipped = false});
}