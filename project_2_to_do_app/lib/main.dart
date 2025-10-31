import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: TodoListPage(),
    );
  }
}

class Task {
  String title;
  bool isDone;
  Task({required this.title, this.isDone = false});
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<Task> _tasks = [];
  final TextEditingController _textController = TextEditingController();

  void _addTask() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: _textController.text));
      });
      _textController.clear();
    }
  }

  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      final removedTask = _tasks.removeAt(index);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa: ${removedTask.title}'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todo List'),
      ),
      body: Column(
        children: [
          _buildInputArea(),

          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];

                // Dùng Dismissible để cho phép vuốt để xóa
                return Dismissible(
                  // Key là bắt buộc để Flutter nhận diện đúng item
                  key: Key(task.title + index.toString()),
                  direction: DismissDirection.endToStart, // Vuốt từ phải sang trái
                  // Hàm được gọi khi vuốt thành công
                  onDismissed: (direction) {
                    _deleteTask(index);
                  },
                  // Background màu đỏ khi vuốt
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  // Nội dung chính của item
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (bool? value) {
                        _toggleTaskStatus(index);
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        // Thêm hiệu ứng gạch ngang nếu đã hoàn thành
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                      onPressed: () {
                        _deleteTask(index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Tách phần nhập liệu ra thành 1 widget riêng cho sạch sẽ
  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Thêm công việc mới...',
                border: OutlineInputBorder(),
              ),
              // Cho phép bấm "Enter" trên bàn phím để thêm
              onSubmitted: (value) => _addTask(),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.add, size: 30),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: _addTask,
          ),
        ],
      ),
    );
  }
}