import 'package:flutter/material.dart';
import 'package:notes_repo_widget/src/bubble_test/bubble_controller.dart';

class PhysicsEngine {
  final Map<int, Node> nodes;
  final List<LinePainter> edges;
  final double radius = 70;
  final double shoveFactor = 2.2;
  final double attachDistance = 70;

  PhysicsEngine(this.nodes, this.edges);
  //used for frame by frame movements
  void moveNode(int index, Offset delta) {
    nodes[index]!.position.value += delta;
    _updatePosChildren(delta, nodes[index]!);
    updateEdges();
  }

  //called after movement to update everything
  // void updatePositions(int movedNodeId) {
  //   checkCollision(movedNodeId);
  // }

  void updateEdges() {
    for (LinePainter l in edges) {
      l.start = nodes[l.startId]!.position.value;
      l.end = nodes[l.endId]!.position.value;
    }
  }

  void _updatePosChildren(Offset delta, Node parent) {
    for (Node child in parent.children) {
      child.position.value = child.position.value + delta;
      _updatePosChildren(delta, child);
    }
  }

  void checkCollision(int id) {
    final mainBubble = nodes[id];

    final List<int> moved = [];

    nodes.forEach((key, value) {
      //ignore self colision
      if (key == id) return;

      //find distance
      final Offset delta = value.position.value - mainBubble!.position.value;
      final double distance = delta.distance;

      //if overlapping
      if (distance < 2 * radius) {
        if (distance != 0) {
          //push away other
          final Offset direction = delta / distance;
          final Offset newPosition =
              mainBubble.position.value + direction * (shoveFactor * radius);

          value.position.value = newPosition;
        } else {
          //if perfectly overlapping
          value.position.value =
              mainBubble.position.value + Offset(shoveFactor * radius, 0);
        }

        //for iteration
        moved.add(key);
      }
    });

    //CheckCollision for all moved bubbles
    for (int i in moved) {
      checkCollision(i);
    }
  }
}
