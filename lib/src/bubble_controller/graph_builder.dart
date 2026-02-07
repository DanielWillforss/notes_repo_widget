import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes_repo_core/classes/note_model.dart';
import 'package:notes_repo_widget/src/bubble_controller/bubble_controller.dart';
import 'package:notes_repo_widget/src/pages/bubble_page.dart';

class GraphBuilder {
  final Map<int, Node> nodes;
  final List<LinePainter> edges;
  final ValueNotifier<int> repaintNotifier;

  GraphBuilder(this.nodes, this.edges, this.repaintNotifier);

  //Parent child logic
  void createMap(List<Note> notes) {
    final Map<int, Node> incomingNodes = {};
    for (final note in notes) {
      if (!nodes.containsKey(note.id)) {
        incomingNodes.putIfAbsent(note.id, () => Node(note));
      } else {
        incomingNodes.putIfAbsent(note.id, () {
          final updatedNode = nodes[note.id]!;
          updatedNode.note = note;
          return updatedNode;
        });
      }
    }
    nodes.clear();
    incomingNodes.forEach((key, value) {
      nodes.putIfAbsent(key, () => value);
    });

    // 1. Clear children (important if this is called more than once)
    for (final node in nodes.values) {
      node.children.clear();
    }

    // 2. Build parent -> children relationships
    for (final node in nodes.values) {
      final parentId = node.note.parentId;
      if (parentId != null && nodes.containsKey(parentId)) {
        nodes[parentId]!.children.add(node);
      }
    }

    // 3. Collect root nodes
    final List<Node> roots = nodes.values
        .where((bubble) => bubble.note.parentId == null)
        .toList();

    // 4. Compute subtree sizes for angular distribution
    final List<double> subtreeSizes = roots
        .map((root) => _subTreeSize(root))
        .toList();

    final rootAngles = _getAnglesRoot(subtreeSizes);

    // 5. Position roots and recursively place children

    for (int i = 0; i < roots.length; i++) {
      roots[i].position.value = _positionFromAngle(
        rootAngles[i],
        BubblePage.origin,
        BubbleController.rootDistance,
      );
      _setInitialPos(roots[i], rootAngles[i]);
    }

    // 6. Build edges
    edges.clear();

    for (final node in nodes.values) {
      final parentId = node.note.parentId;
      if (parentId != null && nodes.containsKey(parentId)) {
        edges.add(
          LinePainter(
            startId: node.note.id,
            endId: parentId,
            start: node.position.value,
            end: nodes[parentId]!.position.value,
            repaint: repaintNotifier,
          ),
        );
      }
    }
  }

  //Parent child logic
  //final Map<int, Node> incomingNodes = {};
  void updateMap(List<Note> notes) {
    final List<int> updated = [];

    // Collect all incoming note IDs
    final noteIds = notes.map((n) => n.id).toSet();

    for (final note in notes) {
      if (!nodes.containsKey(note.id)) {
        nodes.putIfAbsent(note.id, () => Node(note));
      } else {
        nodes[note.id]!.note = note;
        updated.add(note.id);
      }
    }

    nodes.removeWhere((id, _) => !noteIds.contains(id));

    // 1. Clear children (important if this is called more than once)
    for (final node in nodes.values) {
      node.children.clear();
    }

    // 2. Build parent -> children relationships
    for (final node in nodes.values) {
      final parentId = node.note.parentId;
      if (parentId != null && nodes.containsKey(parentId)) {
        nodes[parentId]!.children.add(node);
      }
    }

    // 6. Build edges
    edges.clear();

    for (final node in nodes.values) {
      final parentId = node.note.parentId;
      if (parentId != null && nodes.containsKey(parentId)) {
        edges.add(
          LinePainter(
            startId: node.note.id,
            endId: parentId,
            start: node.position.value,
            end: nodes[parentId]!.position.value,
            repaint: repaintNotifier,
          ),
        );
      }
    }
  }

  List<double> _getAngles(double initialAngle, int nbr) {
    if (nbr <= 1) return [initialAngle];

    final double start = initialAngle - pi;
    final double end = initialAngle + pi;
    final double step = (end - start) / (nbr + 1);

    return List.generate(nbr, (i) => start + step * (i + 1));
  }

  List<double> _getAnglesRoot(List<double> subtreeSizes) {
    if (subtreeSizes.isEmpty) return [];
    if (subtreeSizes.length == 1) return [pi / 2];

    final double totalSize = subtreeSizes.fold(0.0, (sum, size) => sum + size);

    //modify pi to avoid backwards bubble
    final double start = -pi * 3 / 2;
    final double end = pi / 2;
    final double step = (end - start) / totalSize;

    final List<double> angles = [];
    double lastStep = 0;

    for (final size in subtreeSizes) {
      angles.add(start + lastStep + size * step / 2);
      lastStep += size * step;
    }

    return angles;
  }

  Offset _positionFromAngle(double angle, Offset origin, double distance) {
    return origin.translate(cos(angle) * distance, sin(angle) * distance);
  }

  void _setInitialPos(Node root, double rootAngle) {
    final int nbrChildren = root.children.length;
    if (nbrChildren == 0) return;

    final List<double> angles = _getAngles(rootAngle, nbrChildren);

    final children = root.children.toList();
    for (int i = 0; i < nbrChildren; i++) {
      children[i].position.value = _positionFromAngle(
        angles[i],
        root.position.value,
        BubbleController.radius * BubbleController.shoveFactor,
      );
      _setInitialPos(children[i], angles[i]);
    }
  }

  double _subTreeSize(Node root, [int depth = 1]) {
    if (root.children.isEmpty) return 1;
    double sum = 1;
    for (final child in root.children) {
      sum += _subTreeSize(child, depth + 1);
    }
    return sum / (depth * depth);
  }
}
