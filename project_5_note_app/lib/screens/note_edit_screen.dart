import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  NoteEditScreen({this.note});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();

    // Kiểm tra xem có phải chế độ Sửa không
    _isEditMode = widget.note != null;

    // Khởi tạo controller với dữ liệu cũ (nếu là Sửa)
    _titleController = TextEditingController(text: _isEditMode ? widget.note!.title : '');
    _contentController = TextEditingController(text: _isEditMode ? widget.note!.content : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    // Validate form
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final content = _contentController.text;

      // Lấy provider (listen: false vì ta chỉ gọi hàm)
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      if (_isEditMode) {
        // Chế độ Sửa
        noteProvider.updateNote(widget.note!.id, title, content);
      } else {
        // Chế độ Tạo mới
        noteProvider.addNote(title, content);
      }

      // Quay lại màn hình danh sách
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Note' : 'Add Note'),
        actions: [
          // Nút Lưu
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 5. Yêu cầu: Dùng TextField
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}