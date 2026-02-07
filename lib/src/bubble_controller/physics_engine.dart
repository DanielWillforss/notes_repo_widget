import 'package:flutter/material.dart';
import 'package:notes_repo_widget/src/bubble_controller/bubble_controller.dart';

class PhysicsEngine {
  final Map<int, Node> nodes;
  final List<LinePainter> edges;
  final ValueNotifier<int> repaintNotifier;

  PhysicsEngine(this.nodes, this.edges, this.repaintNotifier);
  //used for frame by frame movements
  void moveNode(int index, Offset delta) {
    nodes[index]!.position.value += delta;
    _updatePosChildren(delta, nodes[index]!);
    updateEdges();
  }

  void updateEdges() {
    for (LinePainter l in edges) {
      l.start = nodes[l.startId]!.position.value;
      l.end = nodes[l.endId]!.position.value;
    }
    repaintNotifier.value++;
  }

  void _updatePosChildren(Offset delta, Node parent) {
    for (Node child in parent.children) {
      child.position.value = child.position.value + delta;
      _updatePosChildren(delta, child);
    }
  }

  void checkCollision(int id) {
    final queue = <int>[id];
    final visited = <int>{};

    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (!visited.add(current)) continue;

      final mainBubble = nodes[current]!;

      nodes.forEach((key, value) {
        if (key == current) return;

        final delta = value.position.value - mainBubble.position.value;
        final distance = delta.distance;

        if (distance < 2 * BubbleController.radius) {
          final Offset offset = distance == 0
              ? Offset(
                  BubbleController.radius * BubbleController.shoveFactor,
                  0,
                )
              : (delta / distance) *
                    (BubbleController.radius * BubbleController.shoveFactor);

          value.position.value = mainBubble.position.value + offset;
          queue.add(key);
        }
      });
    }
  }
}
