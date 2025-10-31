import 'package:flutter/foundation.dart';
import '../models/note.dart';

class NoteProvider with ChangeNotifier {
  final List<Note> _notes = [
    Note(id: '1', title: 'Chào mừng', content: 'Đây là app ghi chú Provider!'),
  ];
  // -----------------------------------

  List<Note> get notes => _notes;

  void addNote(String title, String content) {
    final newNote = Note(
      id: DateTime.now().toString(),
      title: title,
      content: content,
    );
    _notes.add(newNote);
    notifyListeners();
  }

  void updateNote(String id, String newTitle, String newContent) {
    // Tìm note cũ
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex >= 0) {
      // Tạo note mới với nội dung đã cập nhật
      final updatedNote = Note(id: id, title: newTitle, content: newContent);
      _notes[noteIndex] = updatedNote;

      // BÁO CÁO: "Này, dữ liệu đã thay đổi!"
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);

    // BÁO CÁO: "Này, dữ liệu đã thay đổi!"
    notifyListeners();
  }
}