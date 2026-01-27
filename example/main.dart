import 'package:flutter/material.dart';
import 'package:notes_repo_widget/note_widget_package.dart';
import 'package:notes_repo_widget/src/notes_page.dart';

void main() {
  NotesApi.baseUrl = 'http://127.0.0.1:5000/notes';
  //NotesApi.baseUrl = 'https://danielwillforss.site/notes';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: NotesPage(),
    );
  }
}
