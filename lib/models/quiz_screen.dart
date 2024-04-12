import 'package:flutter/material.dart';
import 'package:mp3/models/data_manager.dart';
import 'package:mp3/utils/db_helper.dart';

class QuizScreen extends StatefulWidget {
  final Flashcardtable flashcard;

  const QuizScreen({Key? key, required this.flashcard}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  bool showAnswer = false;
  List<Flashcardtable> flashcards = [];
  int answeredCount = 0;

  @override
  void initState() {
    super.initState();
    fetchFlashcardsForDeck(widget.flashcard.deck_id);
  }

  void fetchFlashcardsForDeck(int deckId) async {
    final dbHelper = DBHelper();
    final db = await dbHelper.db;

    final flashcardMaps =
        await db.query('flashcards', where: 'deck_id = ?', whereArgs: [deckId]);

    setState(() {
      flashcards = flashcardMaps.map((map) {
        return Flashcardtable(
          id: map['id'] as int,
          deck_id: map['deck_id'] as int,
          question: map['question'] as String,
          answer: map['answer'] as String,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= flashcards.length) {
      return const Center(
        child: Text('No flashcards available for this deck.'),
      );
    }

    final flashcard = flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Container( replaced it with sizebox(
          SizedBox(
            width: 300,
            height: 200,
            child: Card(
              color: showAnswer ? Colors.green : Colors.purple[100],
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showAnswer ? flashcard.answer : flashcard.question,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentIndex > 0)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex--;
                      showAnswer = false;
                    });
                  },
                  child: const Icon(Icons.arrow_back, size: 40),
                ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAnswer = !showAnswer;
                    if (showAnswer) {
                      answeredCount++;
                    }
                  });
                },
                child: Icon(
                  showAnswer ? Icons.visibility_off : Icons.visibility,
                  size: 40,
                ),
              ),
              if (currentIndex < flashcards.length - 1)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex++;
                      showAnswer = false;
                    });
                  },
                  child: const Icon(Icons.arrow_forward, size: 40),
                )
              else
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 0;
                      showAnswer = false;
                      answeredCount = 0;
                    });
                  },
                  child: const Icon(Icons.refresh, size: 40),
                )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Card ${currentIndex + 1} of ${flashcards.length}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Answered: $answeredCount/${flashcards.length}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
