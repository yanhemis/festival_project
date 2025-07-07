import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:festival_app/screens/confirmation_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // final _formKey = GlobalKey<FormState>();
  //
  // final _nameController = TextEditingController();
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  // final _confirmPasswordController = TextEditingController();
  //
  // bool _isPasswordObscured = true;
  //
  // @override
  // void dispose() {
  //   _nameController.dispose();
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   _confirmPasswordController.dispose();
  //   super.dispose();
  // }
  //
  // void _submit() {
  //   if (_formKey.currentState!.validate()) {
  //     // TODO: 1. 데이터베이스에 회원 정보 저장하는 로직 구현
  //     final name = _nameController.text;
  //     final email = _emailController.text;
  //     final password = _passwordController.text;
  //
  //     print('Name: $name, Email: $email, Password: $password');
  //
  //     // TODO: 2. 회원가입 성공 후 로그인 페이지로 돌아가기
  //     Navigator.pop(context);
  //   }
  // }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordObscured = true;

  // 로딩 상태를 관리하는 변수
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 회원가입 로직을 처리하는 함수
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 로딩 시작
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await Amplify.Auth.signUp(
        username: _emailController.text.trim(), // 이메일을 username으로 사용
        password: _passwordController.text.trim(),
        options: SignUpOptions(
          userAttributes: {
            // Cognito에 저장할 추가 사용자 속성 (예: 이름)
            AuthUserAttributeKey.name: _nameController.text.trim(),
          },
        ),
      );

      if (result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // 로딩 종료
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('회원가입'),
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       foregroundColor: Colors.black,
  //     ),
  //     body: SingleChildScrollView(
  //       child: Padding(
  //         padding: const EdgeInsets.all(24.0),
  //         child: Form(
  //           key: _formKey,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             children: [
  //               TextFormField(
  //                 controller: _nameController,
  //                 decoration: const InputDecoration(labelText: '이름'),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return '이름을 입력해주세요.';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               const SizedBox(height: 16.0),
  //
  //               TextFormField(
  //                 controller: _emailController,
  //                 decoration: const InputDecoration(labelText: '이메일'),
  //                 keyboardType: TextInputType.emailAddress,
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return '이메일을 입력해주세요.';
  //                   }
  //                   if (!value.contains('@')) {
  //                     return '올바른 이메일 형식이 아닙니다.';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               const SizedBox(height: 16.0),
  //
  //               TextFormField(
  //                 controller: _passwordController,
  //                 obscureText: _isPasswordObscured,
  //                 decoration: InputDecoration(
  //                   labelText: '비밀번호',
  //                   suffixIcon: IconButton(
  //                     icon: Icon(
  //                       _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
  //                     ),
  //                     onPressed: () {
  //                       setState(() {
  //                         _isPasswordObscured = !_isPasswordObscured;
  //                       });
  //                     },
  //                   ),
  //                 ),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return '비밀번호를 입력해주세요.';
  //                   }
  //                   if (value.length < 8) {
  //                     return '비밀번호는 8자 이상이어야 합니다.';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               const SizedBox(height: 16.0),
  //
  //               TextFormField(
  //                 controller: _confirmPasswordController,
  //                 obscureText: true,
  //                 decoration: const InputDecoration(labelText: '비밀번호 확인'),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return '비밀번호를 다시 한번 입력해주세요.';
  //                   }
  //                   if (value != _passwordController.text) {
  //                     return '비밀번호가 일치하지 않습니다.';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               const SizedBox(height: 32.0),
  //
  //               ElevatedButton(
  //                 onPressed: _submit,
  //                 style: ElevatedButton.styleFrom(
  //                   padding: const EdgeInsets.symmetric(vertical: 16.0),
  //                   backgroundColor: Colors.black,
  //                   foregroundColor: Colors.white,
  //                 ),
  //                 child: const Text('가입하기'),
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Column(
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
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return '올바른 이메일 형식이 아닙니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('가입하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
