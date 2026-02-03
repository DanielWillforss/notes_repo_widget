import 'package:flutter/material.dart';
import 'package:notes_repo_core/classes/note_model.dart';
import 'package:notes_repo_widget/note_widget_package.dart';
import 'package:notes_repo_widget/src/bubble_test/bubble_page.dart';
import 'package:notes_repo_widget/src/bubble_test/bubble_widget.dart';
import 'package:notes_repo_widget/src/bubble_test/graph_builder.dart';
import 'package:notes_repo_widget/src/bubble_test/physics_engine.dart';

class BubblePhysicsController {
  final double radius = 70;
  final double shoveFactor = 2.2; //has to be >2
  final double rootDistance = 200;
  final double attachDistance = 70;

  final Map<int, Node> nodes = {};
  final List<LinePainter> edges = [];
  final ValueNotifier<int> repaintNotifier = ValueNotifier(0);
  Function(Future<List<Note>> future) setState;

  late final GraphBuilder graph = GraphBuilder(nodes, edges, repaintNotifier);
  late final PhysicsEngine physics = PhysicsEngine(nodes, edges);

  bool _isInitialized = false;

  BubblePhysicsController(this.setState);

  //used for frame by frame movements

  Function(int index, Offset delta) get moveNode => physics.moveNode;

  // void moveNode(int index, Offset delta) {
  // physics.moveNode(index, delta);
  // }

  //called after movement to update everything
  void updatePositions(int movedNodeId) {
    //physics.updatePositions(movedNodeId);

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
      setState(NotesApi.updateParentId(movedNodeId, closestNodeId));
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

  List<Widget> build(List<Note> notes) {
    _makeBubbles(notes);

    //actual build
    final bubbles = <Widget>[];
    bubbles.add(Container(color: Colors.grey));
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
        NoteBubble(node: value, controller: this, setState: setState),
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
  bool shouldRepaint(_) => true;
}
