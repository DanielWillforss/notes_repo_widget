import 'package:flutter/material.dart';
import 'package:notes_repo_core/classes/note_model.dart';
import 'package:notes_repo_widget/note_widget_package.dart';
import 'package:notes_repo_widget/src/bubble_test/bubble_controller.dart';

class BubblePage extends StatefulWidget {
  const BubblePage({super.key});

  static const double _canvasSize = 5000;
  static const double _minScale = 0.1;
  static const double _maxScale = 1;
  static const Offset origin = Offset(_canvasSize / 2, _canvasSize / 2);

  @override
  State<BubblePage> createState() => _BubblePageState();
}

class _BubblePageState extends State<BubblePage> {
  //main data list, await in builder
  late Future<List<Note>> _notesFuture;
  //Handles camera
  TransformationController? _viewController;
  //Manages the bubbles
  late final BubblePhysicsController _bubbleController =
      BubblePhysicsController(loadNotes);

  @override
  void initState() {
    super.initState();
    loadNotes(NotesApi.getNotes());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_viewController == null) {
      final screenSize = MediaQuery.of(context).size;
      final initialMatrix = Matrix4.identity()
        ..setTranslationRaw(
          screenSize.width / 2 - BubblePage.origin.dx,
          screenSize.height / 2 - BubblePage.origin.dy,
          0,
        );
      _viewController = TransformationController(initialMatrix);
    }
  }

  @override
  void dispose() {
    _viewController?.dispose();
    //_bubbleController.dispose();
    super.dispose();
  }

  void loadNotes(Future<List<Note>> future) {
    setState(() {
      _notesFuture = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'bubblePage',
        onPressed: () => _showDialogWindow(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
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

          return InteractiveViewer(
            constrained: false,
            transformationController: _viewController,
            minScale: BubblePage._minScale,
            maxScale: BubblePage._maxScale,
            boundaryMargin: const EdgeInsets.all(0),
            child: SizedBox(
              width: BubblePage._canvasSize,
              height: BubblePage._canvasSize,
              child: Stack(
                //Actually builds the bubbles based on earlier logic
                children: _bubbleController.build(notes),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDialogWindow() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New Note'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              loadNotes(NotesApi.createNote(titleController.text));
              Navigator.pop(context);
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
}
