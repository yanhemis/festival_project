// flutterapp/lib/screens/login/signup_view_model.dart

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class SignUpViewModel with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await Amplify.Auth.signUp(
        username: email.trim(),
        password: password.trim(),
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.name: name.trim(),
          },
        ),
      );

      // 회원가입 성공 시, 확인 페이지로 이동할지 여부를 반환
      return result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      safePrint('회원가입 에러: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}