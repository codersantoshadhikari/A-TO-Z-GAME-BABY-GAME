import 'package:flutter/material.dart';
import 'package:mp3/models/data_manager.dart';
import 'package:mp3/models/deckupdation_screen.dart';
import 'package:mp3/models/flashcard_screen.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/decklist.dart';
import 'package:sqflite/sqflite.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  _DeckListScreenState createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  bool _dataLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 236, 203, 58),
        title: const Text('Deck List'),
        actions: [
          IconButton(
            icon: Icon(Icons.download), // You can use any icon you like
            onPressed: () {
              _downloadData();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Decktable>>(
        future: fetchDecksFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No decks available.'));
          } else {
            final decks = snapshot.data;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _calculateCrossAxisCount(context),
              ),
              itemCount: decks?.length,
              itemBuilder: (context, index) {
                final deck = decks?[index];
                return InkWell(
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FlashcardListScreen(deck: deck),
                      ),
                    );
                  },
                  child: DeckCard(deck!, _onDeckAdded),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DeckCreationScreen(onDeckAdded: _onDeckAdded)),
            );
          },
          child: const Icon(Icons.add),
          backgroundColor: const Color.fromARGB(255, 137, 139, 74)),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = 200.0;
    final crossAxisCount = (width / cardWidth).round();
    return crossAxisCount;
  }

  Future<void> fetchDataIfNeeded() async {
    if (!_dataLoaded) {
      await fetchDecksFromDatabase();
      setState(() {
        _dataLoaded = true;
      });
    }
  }

  void _onDeckAdded(bool added) {
    if (added) {
      setState(() {
        _dataLoaded = false;
      });
    }
  }

  void _downloadData() async {
    try {
      await loadJsonDataToDatabase();

      setState(() {
        _dataLoaded = false;
      });
    } catch (e) {
      print('Error downloading data: $e');
    }
  }
}

class DeckCard extends StatefulWidget {
  final Decktable deck;
  final Function(bool) onDeckUpdated;

  DeckCard(this.deck, this.onDeckUpdated, {super.key});

  @override
  _DeckCardState createState() => _DeckCardState();
}

class _DeckCardState extends State<DeckCard> {
  final TextEditingController _titleController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.deck.title;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.yellow[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () {
          if (!_isEditing) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FlashcardListScreen(deck: widget.deck),
              ),
            );
          }
        },
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Edit Title',
                        ),
                      ),
                    )
                  else
                    Text(
                      widget.deck.title,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
            if (!_isEditing)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DeckUpdateScreen(
                          deck: widget.deck,
                          onDeckUpdated: widget.onDeckUpdated,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<List<Decktable>> fetchDecksFromDatabase() async {
  final dbHelper = DBHelper();

  // Check if the database is empty
  final Database db = await dbHelper.db;
  final List<Map<String, dynamic>> deckMaps = await db.query('decks');

  return List.generate(deckMaps.length, (i) {
    return Decktable(
      id: deckMaps[i]['id'],
      title: deckMaps[i]['title'],
    );
  });
}

class DeckCreationScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final Function(bool) onDeckAdded; // Callback function to notify deck added

  DeckCreationScreen({super.key, required this.onDeckAdded});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Deck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Deck Title'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final dbHelper = DBHelper();
                    await dbHelper
                        .insert('decks', {'title': _titleController.text});
                    onDeckAdded(true); // Notify that the deck was added
                    Navigator.pop(context);
                  },
                  child:
                      const Text('Save', style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    onDeckAdded(false); // Notify cancellation
                    Navigator.pop(context);
                  },
                  child:
                      const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
