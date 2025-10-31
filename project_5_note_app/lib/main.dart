import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/note_provider.dart';
import 'screens/note_list_screen.dart';

void main() {
  runApp(
    // 1. Yêu cầu: Dùng Provider
    // Bọc ứng dụng của bạn trong ChangeNotifierProvider
    ChangeNotifierProvider(
      // 'create' sẽ tạo ra instance của "kho" (NoteProvider)
      create: (context) => NoteProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Note App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: NoteListScreen(), // Bắt đầu với màn hình danh sách
    );
  }
}