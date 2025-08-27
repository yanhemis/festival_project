// main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutterapp/screens/login/login_screen.dart';
import 'package:flutterapp/screens/board/board_list_screen.dart';
import 'package:flutterapp/screens/view_models/main_view_model.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('메인 화면'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final viewModel = context.read<MainViewModel>();
                try {
                  await viewModel.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                    );
                  }
                } on Exception catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<MainViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                    const SizedBox(height: 20),
                    const Text(
                      '로그인에 성공했습니다!',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    Text('사용자 ID: ${viewModel.cognitoUserId}', style: const TextStyle(fontSize: 16)),
                    Text('이메일: ${viewModel.loggedInUserEmail}', style: const TextStyle(fontSize: 16)),
                    Text('이름: ${viewModel.loggedInUserName}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    Text(viewModel.localDbStatus, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => viewModel.signOut(), // ViewModel의 메서드 호출
                      child: const Text('사용자 정보 새로고침 및 동기화'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const BoardListScreen()));
                      },
                      child: const Text('게시판으로 이동'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}