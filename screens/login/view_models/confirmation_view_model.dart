// flutterapp/lib/screens/login/view_models/confirmation_view_model.dart

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class ConfirmationViewModel with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email.trim(),
        confirmationCode: confirmationCode.trim(),
      );
      return result.isSignUpComplete;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      safePrint('가입 확인 에러: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}