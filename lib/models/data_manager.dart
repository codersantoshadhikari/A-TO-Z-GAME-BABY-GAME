import '../utils/db_helper.dart';

class Decktable {
  int? id;
  final String title;

  Decktable({
    this.id,
    required this.title,
  });

  Future<void> dbSave() async {
    id = await DBHelper().insert('decks', {
      'title': title,
    });
  }

  Future<void> dbDelete() async {
    if (id != null) {
      await DBHelper().delete('decks', id!);
    }
  }
}

class Flashcardtable {
  int? id;
  final int deck_id;
  final String question;
  final String answer;

  Flashcardtable({
    this.id,
    required this.deck_id,
    required this.question,
    required this.answer,
  });

  Future<void> dbSave() async {
    id = await DBHelper().insert('flashcards', {
      'question': question,
      'answer': answer,
      'deck_id': deck_id,
    });
  }

  Future<void> dbDelete() async {
    if (id != null) {
      await DBHelper().delete('flashcards', id!);
    }
  }
}
