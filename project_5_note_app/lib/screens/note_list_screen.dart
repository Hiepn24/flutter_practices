import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import 'note_edit_screen.dart';

class NoteListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
      ),
      // 3. Dùng "Consumer" để lắng nghe NoteProvider
      // Widget này sẽ tự động rebuild khi provider thay đổi
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          // Nếu không có note nào, hiển thị text
          if (noteProvider.notes.isEmpty) {
            return Center(child: Text('No notes yet. Add one!'));
          }

          // Nếu có, hiển thị ListView
          return ListView.builder(
            itemCount: noteProvider.notes.length,
            itemBuilder: (ctx, index) {
              final note = noteProvider.notes[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis,),
                  // Nút Sửa
                  onTap: () {
                    // Chuyển đến màn hình Edit (gửi kèm note)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => NoteEditScreen(note: note),
                      ),
                    );
                  },
                  // Nút Xóa
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Gọi hàm delete TỪ provider
                      // 'listen: false' là quan trọng khi gọi hàm trong onPressed
                      Provider.of<NoteProvider>(context, listen: false)
                          .deleteNote(note.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      // 4. Yêu cầu: Dùng FloatingActionButton
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Chuyển đến màn hình Edit (không gửi kèm note -> chế độ "Tạo mới")
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => NoteEditScreen(note: null),
            ),
          );
        },
      ),
    );
  }
}