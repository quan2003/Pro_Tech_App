import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/SignInController.dart';
import 'SignInScreen.dart'; // Import màn hình đăng nhập

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SignInController controller = Get.put(SignInController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false; // Trạng thái hiển thị mật khẩu
  bool isConfirmPasswordVisible =
      false; // Trạng thái hiển thị mật khẩu xác nhận

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF61C9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                _buildLogo(),
                const SizedBox(height: 50),
                _buildSignupForm(),
                const SizedBox(height: 5),
                _buildSocialLoginButtons(),
                const SizedBox(height: 30), // Thêm khoảng trống giữa các phần
                _buildFooter(context), // Thêm phần footer
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
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

  Widget _buildSignupForm() {
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
        const SizedBox(height: 20),
        _buildInputField(
          controller: confirmPasswordController,
          icon: Icons.lock_outline,
          hintText: 'Confirm Password',
          isPassword: true,
          isPasswordVisible: isConfirmPasswordVisible,
          onPasswordToggle: () {
            setState(() {
              isConfirmPasswordVisible = !isConfirmPasswordVisible;
            });
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleSignup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              backgroundColor: const Color(0xFFFF955F),
              shadowColor:
                  Colors.black.withOpacity(0.3), // Bổ sung hiệu ứng bóng
            ),
            child: const Text(
              'SIGN UP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        )
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
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Màu bóng mờ
            blurRadius: 10, // Độ mờ của bóng
            offset: const Offset(0, 4), // Độ lệch của bóng
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText:
            isPassword && !isPasswordVisible, // Ẩn hoặc hiển thị mật khẩu
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

  _handleSignup() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await controller.handleSignup(
          emailController.text, passwordController.text);
      // Đăng ký thành công, chuyển hướng đã được xử lý trong controller
    } catch (e) {
      Get.snackbar(
        "Sign Up Failed",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
            "Already have an account? ",
            style: TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: () {
              // Điều hướng sang màn hình SignInScreen khi người dùng nhấn "Sign In"
              Get.to(() => const SignInScreen());
            },
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
