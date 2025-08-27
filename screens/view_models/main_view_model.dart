// lib/view_models/main_view_model.dart

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class MainViewModel with ChangeNotifier {
  String _loggedInUserEmail = '불러오는 중...';
  String _loggedInUserName = '불러오는 중...';
  String _cognitoUserId = '불러오는 중...';
  String _localDbStatus = '로컬 DB 상태: 확인 중...';

  String get loggedInUserEmail => _loggedInUserEmail;
  String get loggedInUserName => _loggedInUserName;
  String get cognitoUserId => _cognitoUserId;
  String get localDbStatus => _localDbStatus;

  final String _localApiBaseUrl = Platform.isAndroid ? 'http://10.0.2.2:3001' : 'http://localhost:3001';

  MainViewModel() {
    _fetchAndSyncUserData();
  }

  Future<void> _fetchAndSyncUserData() async {
    try {
      final currentUser = await Amplify.Auth.getCurrentUser();
      final session = await Amplify.Auth.fetchAuthSession();
      String? idToken;

      if (session.isSignedIn && session is CognitoAuthSession) {
        idToken = session.userPoolTokensResult.value?.idToken.raw;
      }
      if (idToken == null) {
        _localDbStatus = 'ID Token 없음. 백엔드 동기화 불가.';
        notifyListeners();
        return;
      }

      final Map<String, dynamic> idTokenPayload = _decodeJwt(idToken);
      _loggedInUserEmail = currentUser.username ?? idTokenPayload['email'] ?? 'N/A';
      _loggedInUserName = idTokenPayload['name'] ?? '이름 없음';
      _cognitoUserId = currentUser.userId;
      notifyListeners();

      await _syncUserToLocalDb(idToken, _cognitoUserId);
      await _fetchUserFromLocalDb(idToken, _cognitoUserId);
    } on AuthException catch (e) {
      _loggedInUserEmail = '로그인 정보 없음';
      _loggedInUserName = '로그인 정보 없음';
      _cognitoUserId = '로그인 정보 없음';
      _localDbStatus = '사용자 정보 로드 실패';
      safePrint('사용자 정보 로드 실패: ${e.message}');
    } on Exception catch (e) {
      _localDbStatus = '데이터 처리 오류: ${e.toString()}';
      safePrint('사용자 데이터 처리 중 오류: $e');
    } finally {
      notifyListeners();
    }
  }

  // 사용자 프로필 생성/업데이트를 위한 새로운 함수
  Future<void> _createOrUpdateUserProfile(String idToken, String name, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_localApiBaseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
        }),
      );

      safePrint('백엔드 응답 상태 코드: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        safePrint('사용자 정보 백엔드에 성공적으로 저장 또는 업데이트되었습니다.');
      } else {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        safePrint('백엔드에서 사용자 데이터 저장 실패: ${errorBody['message']}');
      }
    } on Exception catch (e) {
      safePrint('백엔드 API 호출 중 오류 발생: $e');
    }
  }

  // 로컬 DB 동기화 로직
  Future<void> _syncUserToLocalDb(String idToken, String cognitoId) async {
    _localDbStatus = '로컬 DB: 동기화 중...';
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$_localApiBaseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'id': cognitoId,
          'email': _loggedInUserEmail,
          'name': _loggedInUserName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        safePrint('로컬 DB 동기화 성공: ${response.body}');
        _localDbStatus = '로컬 DB: 동기화 성공';
      } else {
        final errorBody = jsonDecode(response.body);
        safePrint('로컬 DB 동기화 실패: ${response.statusCode} - ${errorBody['message']}');
        _localDbStatus = '로컬 DB: 동기화 실패 (${errorBody['message']})';
      }
    } on Exception catch (e) {
      safePrint('로컬 API 호출 중 오류 발생: $e');
      _localDbStatus = '로컬 DB 동기화 중 네트워크 오류: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  // 로컬 DB에서 사용자 조회 로직
  Future<void> _fetchUserFromLocalDb(String idToken, String cognitoId) async {
    _localDbStatus = '로컬 DB: 조회 중...';
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$_localApiBaseUrl/users/$cognitoId'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(utf8.decode(response.bodyBytes));
        safePrint('로컬 DB 조회 성공: ${jsonEncode(userData)}');
        _localDbStatus = '로컬 DB 조회 성공: ${userData['name'] ?? userData['email']}';
      } else if (response.statusCode == 404) {
        safePrint('로컬 DB에서 사용자 정보를 찾을 수 없습니다.');
        _localDbStatus = '로컬 DB: 사용자 정보 없음 (재동기화 필요)';
      } else {
        final errorBody = jsonDecode(response.body);
        safePrint('로컬 DB에서 사용자 데이터 조회 실패: ${response.statusCode} - ${errorBody['message']}');
        _localDbStatus = '로컬 DB 조회 실패: ${errorBody['message']}';
      }
    } on Exception catch (e) {
      safePrint('로컬 API 호출 중 오류 발생: $e');
      _localDbStatus = '로컬 DB 조회 중 네트워크 오류: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  // JWT 디코딩 로직
  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('유효하지 않은 JWT 형식입니다.');
    }
    final String payload = parts[1];
    final String normalizedPayload = base64Url.normalize(payload);
    return json.decode(utf8.decode(base64Url.decode(normalizedPayload)));
  }

  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      safePrint('로그아웃 에러: ${e.message}');
      throw Exception('로그아웃 실패: ${e.message}');
    }
  }
}