import 'package:flutter/material.dart';
import 'views/decklist.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  // Load data from JSON and populate the database
  await loadJsonDataToDatabase();
}

void main() async {
  await initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DeckList(),
  ));
}
