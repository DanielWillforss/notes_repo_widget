import 'package:flutter/material.dart';
import 'package:notes_repo_core/note_package.dart';
import 'package:notes_repo_widget/src/notes_base.dart';
import 'package:notes_repo_widget/src/pages/note_detail_page.dart';

import 'package:notes_repo_widget/src/notes_api.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    _notesFuture = NotesApi.getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'notesPage',
        onPressed: () => _showDialogWindow(null),
        child: const Icon(Icons.add),
      ),
      body: NotesBase.getFutureBuilder(
        future: _notesFuture,
        builder: (notes) => ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return ListTile(
              title: Text(note.title),
              subtitle: Text(
                note.body,
                maxLines: 2, // show only 2 lines
                overflow: TextOverflow.ellipsis, // add "..." if too long
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailPage(note: note),
                  ),
                );
                setState(_loadNotes);
              },
              onLongPress: () => _showDialogWindow(note),
            );
          },
        ),
      ),
    );
  }

  void _showDialogWindow(Note? note) {
    final titleController = TextEditingController(text: note?.title);
    final bool isNewNote = note == null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isNewNote ? 'New Note' : 'Edit Title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
          ],
        ),
        actions: [
          isNewNote
              ? TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                )
              : TextButton(
                  onPressed: () async {
                    await NotesApi.deleteNote(note.id);
                    Navigator.pop(context);
                    setState(_loadNotes);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
          ElevatedButton(
            onPressed: () async {
              isNewNote
                  ? await NotesApi.createNote(titleController.text)
                  : await NotesApi.updateTitle(note.id, titleController.text);
              Navigator.pop(context);
              setState(_loadNotes);
            },
            child: Text(isNewNote ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }
}
