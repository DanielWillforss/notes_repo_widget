import 'package:flutter/material.dart';
import 'package:notes_repo_core/classes/note_model.dart';
import 'package:notes_repo_widget/note_widget_package.dart';
import 'package:notes_repo_widget/src/bubble_controller/bubble_controller.dart';
import 'package:notes_repo_widget/src/notes_base.dart';

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
  late Future<List<Note>> _notesFuture;

  TransformationController? _viewController;
  late final BubbleController _bubbleController = BubbleController(() {
    setState(() {
      _notesFuture = NotesApi.notesFuture;
    });
  });

  @override
  void initState() {
    super.initState();
    _notesFuture = NotesApi.getNotes();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'bubblePage',
        onPressed: () => _showDialogWindow(),
        child: const Icon(Icons.add),
      ),
      body: NotesBase.getFutureBuilder(
        future: _notesFuture,
        builder: (notes) => InteractiveViewer(
          constrained: false,
          transformationController: _viewController,
          minScale: BubblePage._minScale,
          maxScale: BubblePage._maxScale,
          boundaryMargin: const EdgeInsets.all(0),
          child: SizedBox(
            width: BubblePage._canvasSize,
            height: BubblePage._canvasSize,
            child: Stack(
              children: [
                Container(color: Colors.grey),
                ..._bubbleController.buildBubbles(notes),
              ],
            ),
          ),
        ),
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
              setState(() {
                _notesFuture = NotesApi.createNote(titleController.text);
              });
              Navigator.pop(context);
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
}
