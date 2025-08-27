// flutterapp/lib/screens/login/login_screen.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart'; // Provider 패키지 추가
import 'package:flutterapp/screens/login/signup_screen.dart';
import 'package:flutterapp/screens/main_screen.dart';
import 'package:flutterapp/screens/login/view_models/login_view_model.dart'; // ViewModel 파일 임포트

class LoginScreen extends StatelessWidget { // StatelessWidget으로 변경
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TextEditingController는 View에 남겨둡니다.
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    return ChangeNotifierProvider( // ViewModel을 제공합니다.
      create: (context) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Consumer<LoginViewModel>( // ViewModel의 상태 변화를 관찰합니다.
                builder: (context, viewModel, child) {
                  return Column(
                    children: [
                      const SizedBox(height: 80.0),
                      const Text(
                        'SummerProject',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        '로그인',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 60.0),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: '이메일',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '비밀번호',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      if (viewModel.showError) // ViewModel의 상태를 사용하여 오류 메시지 표시
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            '이메일 또는 비밀번호를 잘못 입력했습니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      viewModel.isLoading // ViewModel의 상태를 사용하여 로딩 인디케이터 표시
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: () async {
                          final isSuccess = await viewModel.signInUser(
                            _emailController.text,
                            _passwordController.text,
                          );
                          if (isSuccess && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MainScreen()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text('계속', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 24.0),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.black26,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '또는',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.black26,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        icon: const Icon(FontAwesomeIcons.google, color: Colors.black),
                        label: const Text('Google로 로그인', style: TextStyle(color: Colors.black)),
                        onPressed: () async {
                          final isSuccess = await viewModel.signInWithGoogle();
                          if (isSuccess && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MainScreen()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton.icon(
                        icon: const Icon(FontAwesomeIcons.apple, color: Colors.white),
                        label: const Text('Apple로 로그인', style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          // final isSuccess = await viewModel.signInWithApple();
                          // if (isSuccess && context.mounted) {
                          //   Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => const MainScreen()),
                          //   );
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                          children: [
                            const TextSpan(text: '계속을 클릭하면 당사의 '),
                            TextSpan(
                              text: '서비스 이용 약관',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: 서비스 이용 약관 페이지로 이동
                                },
                            ),
                            const TextSpan(text: ' 및 '),
                            TextSpan(
                              text: '개인정보 처리방침',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: 개인정보 처리방침 페이지로 이동
                                },
                            ),
                            const TextSpan(text: '에 동의하는 것으로 간주됩니다.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          '계정이 없으신가요? 가입하기',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}