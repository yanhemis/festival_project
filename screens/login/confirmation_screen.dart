// confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutterapp/screens/login/view_models/confirmation_view_model.dart'; // ViewModel 임포트
import 'package:provider/provider.dart';

class ConfirmationScreen extends StatelessWidget {
  final String email;

  const ConfirmationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final _confirmationCodeController = TextEditingController();

    return ChangeNotifierProvider(
      create: (context) => ConfirmationViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('가입 확인'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$email으로 전송된\\n6자리 확인 코드를 입력해주세요.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: _confirmationCodeController,
                decoration: const InputDecoration(labelText: '확인 코드'),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              Consumer<ConfirmationViewModel>(
                builder: (context, viewModel, child) {
                  return viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: () async {
                      if (_confirmationCodeController.text.isEmpty) {
                        return;
                      }

                      final isSuccess = await viewModel.confirmSignUp(
                        email: email,
                        confirmationCode: _confirmationCodeController.text,
                      );
                      if (isSuccess && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context); // 이전 화면(로그인)으로 돌아감
                      } else if (context.mounted && viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(viewModel.errorMessage!),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('확인'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}