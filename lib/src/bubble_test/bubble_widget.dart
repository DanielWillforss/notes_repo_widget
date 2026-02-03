import 'package:flutter/material.dart';
import 'package:notes_repo_core/classes/note_model.dart';
import 'package:notes_repo_widget/note_widget_package.dart';
import 'package:notes_repo_widget/src/bubble_test/bubble_controller.dart';

class NoteBubble extends StatelessWidget {
  final Node node;
  final BubblePhysicsController controller;
  final Function(Future<List<Note>> future) setState;

  const NoteBubble({
    super.key,
    required this.node,
    required this.controller,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: node.position,
      builder: (_, pos, child) {
        return Positioned(
          left: pos.dx - controller.radius,
          top: pos.dy - controller.radius,
          child: child!,
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          controller.moveNode(node.note.id, details.delta);
        },
        onPanEnd: (details) {
          controller.updatePositions(node.note.id);
        },
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteDetailPage(note: node.note)),
          );
          setState(NotesApi.getNotes());
        },
        onLongPress: () => _showDialogWindow(context, node.note),
        child: Container(
          width: controller.radius * 2,
          height: controller.radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade200,
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: Offset(2, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Text(
            node.note.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showDialogWindow(BuildContext context, Note note) {
    final titleController = TextEditingController(text: note.title);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Title'),
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
          Row(
            children: [
              // Bottom-left button
              TextButton(
                onPressed: () {
                  setState(NotesApi.updateParentId(note.id, null));
                },
                child: const Text('Detach'),
              ),

              const Spacer(), // pushes the rest to the right

              TextButton(
                onPressed: () async {
                  setState(NotesApi.deleteNote(note.id));
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(NotesApi.updateTitle(note.id, titleController.text));
                  Navigator.pop(context);
                },
                child: Text('Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
