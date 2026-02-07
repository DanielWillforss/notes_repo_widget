import 'package:flutter/material.dart';
import 'package:notes_repo_core/classes/note_model.dart';

class NotesBase {
  static Widget getFutureBuilder({
    required Future<List<Note>> future,
    required Widget Function(List<Note> notes) builder,
  }) {
    return FutureBuilder(
      future: future,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final notes = snapshot.data ?? [];
        if (notes.isEmpty) {
          return const Center(child: Text('No notes yet'));
        }

        return builder(notes);
      },
    );
  }
}
