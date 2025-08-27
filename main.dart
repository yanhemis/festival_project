import 'package:flutter/material.dart';
import 'package:flutterapp/screens/login/login_screen.dart';
// Amplify 관련 import 추가
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplifyconfiguration.dart';  // amplify init 시 자동 생성된 파일

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Amplify 설정을 추가하고 앱을 실행합니다.
  await _configureAmplify();
  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  try {
    // 추가할 플러그인 목록을 만듭니다.
    // final auth = AmplifyAuthCognito();
    // await Amplify.addPlugins([auth]);
    // 추가할 Amplify 플러그인 목록을 만듭니다. (지금은 인증 기능만)
    final authPlugin = AmplifyAuthCognito();
    await Amplify.addPlugin(authPlugin);

    // amplifyconfiguration.dart 파일의 내용을 사용하여 Amplify를 구성합니다.
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    print('Amplify 설정을 초기화하는 데 실패했습니다: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}