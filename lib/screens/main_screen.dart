// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart'; // CognitoAuthSession을 위해 필요
import 'package:flutterapp/screens/login_screen.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위해 필요
import 'dart:convert'; // JSON 인코딩/디코딩을 위해 필요
import 'dart:io'; // Platform.isAndroid 등을 위해 필요 (에뮬레이터 IP 처리)
import 'package:flutterapp/screens/board/board_list_screen.dart'; // 추가

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _loggedInUserEmail = '불러오는 중...';
  String _loggedInUserName = '불러오는 중...';
  String _cognitoUserId = '불러오는 중...';
  String _localDbStatus = '로컬 DB 상태: 확인 중...';

  // 로컬 백엔드 API의 기본 URL
  // Android 에뮬레이터는 호스트 PC의 localhost에 접근할 때 10.0.2.2를 사용합니다.
  // 실제 Android 기기나 iOS 시뮬레이터/기기는 호스트 PC의 실제 IP 주소를 사용해야 합니다.
  final String _localApiBaseUrl = Platform.isAndroid ? 'http://10.0.2.2:3001' : 'http://localhost:3001';

  @override
  void initState() {
    super.initState();
    // 화면이 초기화될 때 사용자 정보를 가져와 로컬 DB에 동기화 시도
    _fetchAndSyncUserData();
  }

  // 사용자 정보를 가져와 로컬 DB에 동기화하는 메인 함수
  Future<void> _fetchAndSyncUserData() async {
    if (!mounted) return; // 위젯이 마운트되지 않았다면 실행하지 않음

    try {
      final currentUser = await Amplify.Auth.getCurrentUser();
      final session = await Amplify.Auth.fetchAuthSession();

      // --- 오류 수정 부분 시작 (이번엔 정확하게!) ---
      String? idToken;

      if (session.isSignedIn) {
        if (session is CognitoAuthSession) {
          try {
            // CognitoAuthSession에서 'tokensResult'를 통해 토큰에 접근
            final tokensResult = session.userPoolTokensResult; // tokensResult 사용
            if (tokensResult.value != null) {
              idToken = tokensResult.value!.idToken.raw; // ID 토큰 가져오기
            } else {
              safePrint('tokensResult에 유효한 토큰이 없습니다.');
            }
          } on Exception catch (e) {
            safePrint('ID Token 가져오기 중 예외 발생: $e');
            idToken = null;
          }
        } else {
          safePrint('경고: 현재 AuthSession은 CognitoAuthSession 타입이 아닙니다. ID Token을 가져올 수 없습니다.');
        }
      } else {
        safePrint('세션이 로그인 상태가 아닙니다.');
      }

      if (idToken == null) {
        safePrint('ID Token을 가져올 수 없습니다. 세션이 유효하지 않거나 토큰이 없거나 Cognito 세션이 아닙니다.');
        safePrint('현재 AuthSession 타입: ${session.runtimeType}'); // 어떤 세션 타입인지 확인
        if (mounted) {
          setState(() {
            _localDbStatus = 'ID Token 없음. 백엔드 동기화 불가.';
          });
        }
        return; // 토큰 없으면 더 이상 진행하지 않음
      }
      // --- 오류 수정 부분 끝 ---


      // 사용자 이메일 및 이름 가져오기: currentUser.username을 직접 사용합니다.
      final Map<String, dynamic> idTokenPayload = _decodeJwt(idToken);
      final String userEmailForDisplay = currentUser.username ?? idTokenPayload['email'] ?? 'N/A';
      final String userNameForDisplay = idTokenPayload['name'] ?? idTokenPayload['given_name'] ?? '이름 없음';

      setState(() {
        _cognitoUserId = currentUser.userId; // Cognito의 sub ID
        _loggedInUserEmail = userEmailForDisplay;
        _loggedInUserName = userNameForDisplay;
      });

      await _syncUserToLocalDb(idToken, _cognitoUserId);
      await _fetchUserFromLocalDb(idToken, _cognitoUserId);

    } on AuthException catch (e) {
      safePrint('현재 사용자 정보 가져오기 실패: ${e.message}');
      if (mounted) {
        setState(() {
          _loggedInUserEmail = '로그인 정보 없음';
          _loggedInUserName = '로그인 정보 없음';
          _cognitoUserId = '로그인 정보 없음';
          _localDbStatus = '사용자 정보 로드 실패';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 정보 로드 실패: ${e.message}')),
        );
      }
    } on Exception catch (e) {
      safePrint('사용자 데이터 처리 중 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 처리 오류: ${e.toString()}')),
        );
      }
    }
  }

  // ... (나머지 코드는 이전과 동일)

  // 로컬 DB에 사용자 정보 동기화 (API 호출) - 백엔드가 Cognito에서 정보 가져옴
  Future<void> _syncUserToLocalDb(String idToken, String cognitoId) async {
    safePrint('로컬 DB에 사용자 데이터 동기화 시도 중');
    try {
      final response = await http.post(
        Uri.parse('$_localApiBaseUrl/users'), // POST 요청
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $idToken', // Cognito ID Token을 Authorization 헤더에 포함
        },
        body: jsonEncode(<String, String>{ // 요청 본문에는 cognitoId만 포함
          'cognitoId': cognitoId,
        }),
      );

      if (response.statusCode == 201) { // 201 Created (새 사용자 생성)
        safePrint('로컬 DB에 새 사용자 데이터 저장 성공.');
        if (mounted) {
          setState(() {
            _localDbStatus = '로컬 DB: 새 사용자 저장 성공';
          });
        }
      } else if (response.statusCode == 200) { // 200 OK (기존 사용자 업데이트)
        safePrint('로컬 DB에 사용자 데이터 업데이트 성공.');
        if (mounted) {
          setState(() {
            _localDbStatus = '로컬 DB: 사용자 정보 업데이트 성공';
          });
        }
      } else {
        final errorBody = jsonDecode(response.body);
        safePrint('로컬 DB에 사용자 데이터 동기화 실패: ${response.statusCode} - ${errorBody['message']}');
        if (mounted) {
          setState(() {
            _localDbStatus = '로컬 DB 동기화 실패: ${errorBody['message']}';
          });
        }
      }
    } catch (e) {
      safePrint('로컬 API 호출 중 오류 발생: $e');
      if (mounted) {
        setState(() {
          _localDbStatus = '로컬 DB 동기화 중 네트워크 오류: ${e.toString()}';
        });
      }
    }
  }

  // 로컬 DB에서 사용자 정보 조회 (API 호출 - 확인용)
  Future<void> _fetchUserFromLocalDb(String idToken, String cognitoId) async {
    safePrint('로컬 DB에서 사용자 데이터 조회 시도 중...');
    try {
      final response = await http.get(
        Uri.parse('$_localApiBaseUrl/users/$cognitoId'), // GET 요청
        headers: <String, String>{
          'Authorization': 'Bearer $idToken', // Cognito ID Token
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        safePrint('로컬 DB에서 사용자 데이터 조회 성공: ${jsonEncode(userData)}');
        if (mounted) {
          setState(() {
            _localDbStatus = '로컬 DB 조회 성공: ${userData['name'] ?? userData['email']}';
          });
        }
      } else if (response.statusCode == 404) {
        safePrint('로컬 DB에서 사용자 정보를 찾을 수 없습니다.');
        if (mounted) {
          setState(() {
            _localDbStatus = '로컬 DB: 사용자 정보 없음 (재동기화 필요)';
          });
        }
      } else {
        final errorBody = jsonDecode(response.body);
        safePrint('로컬 DB에서 사용자 데이터 조회 실패: ${response.statusCode} - ${errorBody['message']}');
        if (mounted) {
          setState(() {
            _localDbStatus = '로컬 DB 조회 실패: ${errorBody['message']}';
          });
        }
      }
    } catch (e) {
      safePrint('로컬 API 호출 중 오류 발생: $e');
      if (mounted) {
        setState(() {
          _localDbStatus = '로컬 DB 조회 중 네트워크 오류: ${e.toString()}';
        });
      }
    }
  }

  // JWT를 디코딩하는 유틸리티 함수
  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('유효하지 않은 JWT 형식입니다.');
    }
    // 페이로드 부분은 base64Url 인코딩되어 있으므로 디코딩 필요
    final payload = utf8.decode(base64Url.decode(parts[1]));
    return jsonDecode(payload);
  }

  // 로그아웃 로직 (기존과 동일)
  Future<void> _signOut(BuildContext context) async {
    try {
      await Amplify.Auth.signOut();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } on AuthException catch (e) {
      safePrint('로그아웃 에러: ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 화면'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                '로그인에 성공했습니다!',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Text('사용자 ID: $_cognitoUserId', style: const TextStyle(fontSize: 16)),
              Text('이메일: $_loggedInUserEmail', style: const TextStyle(fontSize: 16)),
              Text('이름: $_loggedInUserName', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text(_localDbStatus, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchAndSyncUserData, // 버튼을 눌러 수동으로 동기화 시도
                child: const Text('사용자 정보 새로고침 및 동기화'),
              ),
              const SizedBox(height: 20), // 추가
              ElevatedButton( // 추가
                onPressed: () { // 추가
                  Navigator.push( // 추가
                    context, // 추가
                    MaterialPageRoute(builder: (context) => const BoardListScreen()), // 추가
                  ); // 추가
                }, // 추가
                child: const Text('게시판으로 이동'), // 추가
              ), // 추가
            ],
          ),
        ),
      ),
    );
  }
}