import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: GalleryScreen(),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<File> _images = [];

  final ImagePicker _picker = ImagePicker();

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Chọn từ Thư viện'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Chụp ảnh mới'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      permission = Permission.photos;
    }

    var status = await permission.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      var newStatus = await permission.request();

      if (newStatus.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
        return;
      }

      if (newStatus.isDenied) {
        return;
      }
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print("Lỗi khi chọn ảnh: $e");
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quyền bị từ chối'),
        content: Text('Vui lòng vào Cài đặt và cấp quyền truy cập Camera/Thư viện ảnh.'),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Mở Cài đặt'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Gallery'),
      ),

      body: _images.isEmpty
          ? Center(child: Text('Nhấn + để thêm ảnh'))
          : GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          // Hiển thị ảnh từ file
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              _images[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showPickOptions,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}