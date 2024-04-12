import 'package:flutter/material.dart';
import 'package:mp3/models/data_manager.dart';
import 'package:mp3/utils/db_helper.dart';

class DeckUpdateScreen extends StatefulWidget {
  final Decktable deck;
  final Function(bool) onDeckUpdated;

  DeckUpdateScreen({required this.deck, required this.onDeckUpdated});

  @override
  _DeckUpdateScreenState createState() => _DeckUpdateScreenState();
}

class _DeckUpdateScreenState extends State<DeckUpdateScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.deck.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Deck'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Deck Title'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      final dbHelper = DBHelper();
                      await dbHelper.update('decks', {
                        'id': widget.deck.id,
                        'title': _titleController.text,
                      });
                      widget.onDeckUpdated(true);
                      Navigator.pop(context, true);
                    },
                    child: const Text('Save',
                        style: TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
                      final dbHelper = DBHelper();
                      await dbHelper.delete('decks', widget.deck.id!);
                      await dbHelper.deleteFlashCardByDeckId(
                          'flashcards', widget.deck.id!);
                      widget.onDeckUpdated(true);
                      Navigator.pop(context, true);
                    },
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
