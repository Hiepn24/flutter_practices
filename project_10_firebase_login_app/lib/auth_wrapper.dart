import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 3. Yêu cầu: Dùng StreamBuilder để nghe trạng thái
    return StreamBuilder<User?>(
      // Lắng nghe stream 'authStateChanges'
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Trạng thái đang tải
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Trạng thái có lỗi
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Đã xảy ra lỗi!')));
        }

        // Kiểm tra xem 'snapshot' có dữ liệu (User) không
        if (snapshot.hasData) {
          // Nếu có dữ liệu (User != null) -> Đã đăng nhập
          return HomeScreen();
        } else {
          // Nếu không có dữ liệu (User == null) -> Chưa đăng nhập
          return LoginScreen();
        }
      },
    );
  }
}