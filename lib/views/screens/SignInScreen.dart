import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

import 'package:get/get.dart';
import '../admin/AdminHomePage.dart';
import '../controller/SignInController.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'SignupScreen.dart'; // Import màn hình đăng ký

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SignInController controller = Get.put(SignInController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false; // Trạng thái hiển thị mật khẩu
  bool isRememberMe = false; // Trạng thái của hộp "Remember Me"

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // Get screen size

    return Scaffold(
      backgroundColor: const Color(0xFF61C9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenSize.height * 0.05),
                _buildLogo(screenSize), // Pass screen size for responsiveness
                SizedBox(height: screenSize.height * 0.05),
                _buildLoginForm(),
                const SizedBox(height: 20),
                _buildSocialLoginButtons(),
                SizedBox(
                    height: screenSize.height * 0.03), // More responsive space
                _buildFooter(context), // Thêm phần footer
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Size screenSize) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6, // Chiều rộng của logo
      height: 130, // Chiều cao của logo
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/AppLogo.png'), // Ảnh nền là logo
          fit: BoxFit
              .cover, // Co dãn ảnh để phù hợp với kích thước của container
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Hiệu ứng bóng cho logo
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          // Thêm viền
          color: Colors.white, // Màu viền
          width: 2.0, // Độ dày của viền
        ),
        borderRadius: BorderRadius.circular(8.0), // Bo tròn các góc nếu cần
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ' ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black54,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            Text(
              ' ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black54,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputField(
          controller: emailController,
          icon: Icons.email_outlined,
          hintText: 'Email',
        ),
        const SizedBox(height: 20),
        _buildInputField(
          controller: passwordController,
          icon: Icons.lock_outline,
          hintText: 'Password',
          isPassword: true,
          isPasswordVisible: isPasswordVisible,
          onPasswordToggle: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isRememberMe,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isRememberMe = newValue ?? false;
                    });
                  },
                  activeColor: const Color(0xFFFF955F),
                ),
                const Text(
                  "Remember Me",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  controller.handlePasswordRecovery(emailController.text);
                } else {
                  Get.snackbar(
                    "Error",
                    "Please enter your email first",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            try {
              if (emailController.text == 'admin@gmail.com' &&
                  passwordController.text == 'admin123') {
                // Navigate to admin web page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminHomePage()),
                );
              } else {
                await controller.handleLogin(LoginData(
                  name: emailController.text,
                  password: passwordController.text,
                ));
              }
            } catch (e) {
              Get.snackbar(
                "Login Failed",
                e.toString(),
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF955F),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('LOGIN'),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onPasswordToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible, // Hide or show password
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: onPasswordToggle,
                  child: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.white70)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Or sign in with',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              Expanded(child: Divider(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              icon: FontAwesomeIcons.google,
              color: Colors.red,
              onTap: controller.signInWithGoogle,
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.facebookF,
              color: Colors.blue,
              onTap: controller.signInWithFacebook,
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.twitter,
              color: Colors.lightBlue,
              onTap: () {
                // TODO: Implement Twitter sign-in
              },
            ),
            _buildSocialButton(
              icon: Icons.person_outline,
              color: Colors.grey,
              onTap: controller.signInAnonymously,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.2), // Bóng nhẹ để tạo hiệu ứng nổi
              blurRadius: 8, // Độ mờ của bóng
              offset: const Offset(0, 4), // Độ lệch của bóng
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don’t have an account? ",
            style: TextStyle(color: Colors.white),
          ),
          Hero(
            tag:
                'signup-hero', // Đặt một tag chung để liên kết giữa hai màn hình
            child: TextButton(
              onPressed: () {
                _navigateToSignupScreen(
                    context); // Gọi hàm chuyển trang với hiệu ứng
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSignupScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }
}
