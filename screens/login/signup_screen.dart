// flutterapp/lib/screens/login/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutterapp/screens/login/confirmation_screen.dart';
import 'package:flutterapp/screens/login/view_models/signup_view_model.dart'; // ViewModel 임포트
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    return ChangeNotifierProvider(
      create: (context) => SignUpViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('회원가입'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Consumer<SignUpViewModel>( // ViewModel의 상태를 관찰
                builder: (context, viewModel, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: '이름'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: '이메일'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return '유효한 이메일 주소를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '비밀번호',
                        ),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return '비밀번호는 8자 이상이어야 합니다.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: '비밀번호 확인'),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32.0),
                      // 로딩 중일 때는 비활성화된 버튼을, 아닐 때는 활성화된 버튼을 보여줍니다.
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      viewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final isSignUpSuccessful = await viewModel.signUpUser(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            if (isSignUpSuccessful && context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfirmationScreen(email: _emailController.text),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('가입하기'),
                      ),
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