import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:festival_app/screens/login_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // 로그아웃 로직을 처리하는 함수
  Future<void> _signOut(BuildContext context) async {
    try {
      await Amplify.Auth.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } on AuthException catch (e) {
      print('로그아웃 에러: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그아웃 중 오류가 발생했습니다: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 화면'),
        actions: [
          // AppBar 오른쪽에 로그아웃 아이콘 버튼을 추가합니다.
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut(context); // 버튼을 누르면 _signOut 함수 실행
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              '로그인에 성공했습니다!',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}