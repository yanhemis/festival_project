// flutterapp/lib/screens/login/view_models/login_view_model.dart

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class LoginViewModel with ChangeNotifier {
  bool _isLoading = false;
  bool _showError = false;

  bool get isLoading => _isLoading;
  bool get showError => _showError;

  // 로그인 시도 함수
  Future<bool> signInUser(String email, String password) async {
    _isLoading = true;
    _showError = false;
    notifyListeners();

    try {
      final result = await Amplify.Auth.signIn(
        username: email.trim(),
        password: password.trim(),
      );
      if (result.isSignedIn) {
        return true;
      }
    } on AuthException catch (e) {
      _showError = true;
      safePrint('로그인 에러: ${e.message}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // 소셜 로그인 함수
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
      );
      if (result.isSignedIn) {
        return true;
      }
    } on AuthException catch (e) {
      safePrint('구글 로그인 에러: ${e.message}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // 애플 소셜 로그인 함수
//   Future<bool> signInWithApple() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final result = await Amplify.Auth.signInWithWebUI(
//         provider: AuthProvider.apple,
//       );
//       if (result.isSignedIn) {
//         return true;
//       }
//     } on AuthException catch (e) {
//       safePrint('애플 로그인 에러: ${e.message}');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//     return false;
//   }
}