import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'GenderInputScreen.dart';

class UserController extends GetxController {
  final name = ''.obs;

  void setName(String value) => name.value = value;
}

class NameInputScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final TextEditingController _nameController = TextEditingController();

  NameInputScreen({super.key}) {
    _loadCurrentUserName();
  }

  Future<void> _loadCurrentUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String name = userDoc.get('name') ?? '';
        userController.setName(name);
        _nameController.text = name;
      }
    }
  }

  Future<void> _updateNameToFirestore(String name) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
        }, SetOptions(merge: true));
        Get.snackbar('Thành công', 'Tên của bạn đã được cập nhật.');
      } catch (e) {
        print('Lỗi khi cập nhật tên: $e');
        Get.snackbar('Lỗi', 'Không thể cập nhật tên. Vui lòng thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Cho phép điều chỉnh khi bàn phím mở lên
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                const Text(
                  'Tên của tôi',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tôi sẽ xưng hô với bạn như thế nào?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên*',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                  onChanged: (value) => userController.setName(value),
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.05), // Điều chỉnh chiều cao linh hoạt
                Obx(() => SizedBox(
                      width: double
                          .infinity, // Đảm bảo nút rộng bằng chiều rộng của màn hình
                      child: ElevatedButton(
                        onPressed: userController.name.value.isNotEmpty
                            ? () async {
                                await _updateNameToFirestore(
                                    userController.name.value);
                                Navigator.of(context).push(_createRoute());
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Tiếp tục',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const GenderInputScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Animation bắt đầu từ bên phải
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
