import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutterapp/screens/signup_screen.dart';
import 'package:flutterapp/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  // bool _showError = false;

  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(Duration.zero, (){
  //     if (!_showError){
  //       Navigator.pushReplacement(
  //         context,
  //         materialPageRoute(builder: (context) => MainScreen()),
  //       );
  //     }
  //   });
  // }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInUser() async {
    setState(() {
      _isLoading = true;
      _showError = false; // 로그인 시도 시 이전 에러 메시지는 숨김
    });

    try {
      final result = await Amplify.Auth.signIn(
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 로그인 성공 시
      if (result.isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on AuthException catch (e) {
      // 로그인 실패 시 (예: 사용자 없음, 비밀번호 틀림)
      setState(() {
        _showError = true;
      });
      print('로그인 에러: ${e.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 소셜 로그인 함수
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // signInWithSocialProvider 대신 signInWithWebUI를 사용합니다.
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );
      if (result.isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on AuthException catch (e) {
      print('소셜 로그인 에러: ${e.message}');
      // 사용자가 로그인을 취소했을 때(웹 창을 닫았을 때) 발생하는 에러는 무시합니다.
      if (e is UserCancelledException) {
        print('사용자가 로그인을 취소했습니다.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('소셜 로그인 중 오류가 발생했습니다.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80.0),
                const Text(
                  '앱 이름',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48.0),
                const Text(
                  '로그인 하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '로그인하려면 이메일과 비밀번호를 입력하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'email@domain.com',
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
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),

                if (_showError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '이메일 또는 비밀번호를 잘못 입력했습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 16.0),
                // ElevatedButton(
                //   onPressed: () {
                //     final email = _emailController.text;
                //     final password = _passwordController.text;
                //     final bool isLoginSuccessful = (email == '' && password == '');
                //
                //     if(isLoginSuccessful){
                //       setState((){
                //         _showError = false;
                //       });
                //       Navigator.pushReplacement(
                //         context,
                //         MaterialPageRoute(builder: (context) => const MainScreen()),
                //       );
                //     }else{
                //       setState((){
                //         _showError = true;
                //       });
                //     }
                //     //
                //     // setState(() {
                //     //   _showError = true;
                //     // });
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.black,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(vertical: 16.0),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12.0),
                //     ),
                //   ),
                //   child: const Text('계속', style: TextStyle(fontSize: 16)),
                // ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _signInUser, // 로그인 함수 연결
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('계속', style: TextStyle(fontSize: 16)),
                ),

                Container(
                  height: 48.0,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        child: const Text(
                          '비밀번호 찾기',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const Text(
                        '/',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          '회원 가입',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('또는', style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24.0),
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(FontAwesomeIcons.google, color: Colors.black),
                  label: const Text(
                    'Google 계정으로 계속하기',
                    style: TextStyle(color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(FontAwesomeIcons.apple, color: Colors.black),
                  label: const Text(
                    'Apple 계정으로 계속하기',
                    style: TextStyle(color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}