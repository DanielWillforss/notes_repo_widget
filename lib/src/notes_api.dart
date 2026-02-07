import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notes_repo_core/note_package.dart';

class NotesApi {
  static late final String baseUrl;
  static late Future<List<Note>> notesFuture;

  static Future<List<Note>> getNotes() {
    notesFuture = _getNotes();
    return notesFuture;
  }

  /// GET /notes
  static Future<List<Note>> _getNotes() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load notes');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Note.fromMap(e)).toList();
  }

  /// POST /notes
  static Future<List<Note>> createNote(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create note');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Note.fromMap(e)).toList();
  }

  static Future<void> updateTitle(int id, String title) async {
    notesFuture = _updateTitle(id, title);
  }

  /// PUT /notes/{id}/title/
  static Future<List<Note>> _updateTitle(int id, String title) async {
    final response = await http.put(
      Uri.parse('$baseUrl$id/title/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update note');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Note.fromMap(e)).toList();
  }

  /// PUT /notes/{id}/body/
  static Future<List<Note>> updateBody(int id, String body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$id/body/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'body': body}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update note');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Note.fromMap(e)).toList();
  }

  static void updateParentId(int id, int? parentId) {
    notesFuture = _updateParentId(id, parentId);
  }

  /// PUT /notes/{id}/parent/
  static Future<List<Note>> _updateParentId(int id, int? parentId) async {
    final response = await http.put(
      Uri.parse('$baseUrl$id/parent/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'parentId': parentId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update note');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Note.fromMap(e)).toList();
  }

  static Future<void> deleteNote(int id) async {
    notesFuture = _deleteNote(id);
  }

  /// DELETE /notes/{id}
  static Future<List<Note>> _deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl$id/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete note');
    }
    final List data = jsonDecode(response.body);
    return data.map((e) => Note.fromMap(e)).toList();
  }
}
