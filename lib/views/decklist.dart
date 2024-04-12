import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp3/models/data_manager.dart';
import 'package:mp3/models/deckscreen.dart';

class DeckList extends StatefulWidget {
  const DeckList({super.key});
  @override
  _DeckListState createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();

    // Check if data has already been loaded
    if (!dataLoaded) {
      loadJsonDataToDatabase();
      dataLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DeckListScreen(),
    );
  }
}

Future<void> loadJsonDataToDatabase() async {
  final String jsonStr = await rootBundle.loadString('assets/flashcards.json');
  final List<dynamic> jsonData = json.decode(jsonStr);

  for (var deckData in jsonData) {
    final Decktable deck = Decktable(title: deckData['title']);
    await deck.dbSave();

    final List<dynamic> flashcardsData = deckData['flashcards'];

    for (var flashcardData in flashcardsData) {
      final Flashcardtable flashcard = Flashcardtable(
        deck_id: deck.id!,
        question: flashcardData['question'],
        answer: flashcardData['answer'],
      );
      await flashcard.dbSave();
    }
  }
}
