import 'package:flutter/material.dart';
import 'package:notes_repo_widget/note_widget_package.dart';
import 'package:notes_repo_widget/src/pages/bubble_page.dart';
import 'package:notes_repo_widget/src/pages/notes_page.dart';

void main() {
  NotesApi.baseUrl = 'http://127.0.0.1:5000/notes/';
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
      home: const HomeSwitcher(),
      //home: NotesPage(),
    );
  }
}

class HomeSwitcher extends StatefulWidget {
  const HomeSwitcher({super.key});

  @override
  State<HomeSwitcher> createState() => _HomeSwitcherState();
}

class _HomeSwitcherState extends State<HomeSwitcher> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                index = index == 0 ? 1 : 0;
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: const [BubblePage(), NotesPage()],
      ),
    );
  }
}
