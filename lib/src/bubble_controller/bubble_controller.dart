import 'package:flutter/material.dart';
import 'package:notes_repo_core/classes/note_model.dart';
import 'package:notes_repo_widget/note_widget_package.dart';
import 'package:notes_repo_widget/src/pages/bubble_page.dart';
import 'package:notes_repo_widget/src/bubble_widget.dart';
import 'package:notes_repo_widget/src/bubble_controller/graph_builder.dart';
import 'package:notes_repo_widget/src/bubble_controller/physics_engine.dart';

class BubbleController {
  static final double radius = 70;
  static final double shoveFactor = 2.2; //has to be >2
  static final double rootDistance = 200;
  static final double attachDistance = 70;

  final Map<int, Node> nodes = {};
  final List<LinePainter> edges = [];
  final ValueNotifier<int> repaintNotifier = ValueNotifier(0);
  final VoidCallback onChanged;

  late final GraphBuilder graph = GraphBuilder(nodes, edges, repaintNotifier);
  late final PhysicsEngine physics = PhysicsEngine(
    nodes,
    edges,
    repaintNotifier,
  );

  bool _isInitialized = false;

  BubbleController(this.onChanged);

  //used for frame by frame movements

  Function(int index, Offset delta) get moveNode => physics.moveNode;

  //called after movement to update everything
  void updatePositions(int movedNodeId) {
    final Offset movedPosition = nodes[movedNodeId]!.position.value;
    int? closestNodeId;
    double closestDistance = double.infinity;

    nodes.forEach((id, node) {
      if (id == movedNodeId) return; // skip self

      final double distance = (node.position.value - movedPosition).distance;

      if (distance <= attachDistance && distance < closestDistance) {
        closestDistance = distance;
        closestNodeId = node.note.id;
      }
    });

    if (closestNodeId != null) {
      NotesApi.updateParentId(movedNodeId, closestNodeId);
      onChanged();
    }

    physics.checkCollision(
      closestNodeId != null ? closestNodeId! : movedNodeId,
    );
    physics.updateEdges();
  }

  //Parent child logic
  void _makeBubbles(List<Note> notes) {
    int? newNote = _findMissingId(notes);

    if (!_isInitialized) {
      graph.createMap(notes);
    } else {
      graph.updateMap(notes);
    }

    if (newNote != null) {
      physics.checkCollision(newNote);
    }

    _isInitialized = true;
  }

  List<Widget> buildBubbles(List<Note> notes) {
    _makeBubbles(notes);

    //actual build
    final bubbles = <Widget>[];
    for (LinePainter edge in edges) {
      bubbles.add(
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: CustomPaint(painter: edge),
          ),
        ),
      );
    }
    nodes.forEach((key, value) {
      bubbles.add(
        NoteBubble(node: value, controller: this, onChanged: onChanged),
      );
    });
    return bubbles; // create bubbles and lines
  }

  int? _findMissingId(List<Note> notes) {
    for (final note in notes) {
      if (!nodes.containsKey(note.id)) {
        return note.id;
      }
    }
    return null;
  }
}

class Node {
  final ValueNotifier<Offset> position;
  Note note;
  final Set<Node> children = {};

  Node(this.note) : position = ValueNotifier(BubblePage.origin);
}

class LinePainter extends CustomPainter {
  final int startId;
  final int endId;

  Offset start;
  Offset end;

  LinePainter({
    required this.startId,
    required this.endId,
    required this.start,
    required this.end,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(LinePainter old) {
    return old.start != start || old.end != end;
  }
}
