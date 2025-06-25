import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import '../config.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});
  @override
  UserRegisterPageState createState() => UserRegisterPageState();
}

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    serverClientId: OuterToken.googleClientID,
  );

  static Future<void> loginWithGoogle() async {
    try {
      log('take signIn');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      log('take signIn fin');
      if (googleUser == null) {
        log('no user');
        return;
      }
      log('get auth');
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      log('get auth fin');

      if (idToken != null) {
        log('token:$idToken');
        log('send token to backend');
        await _sendTokenToBackend(idToken);
        log('send token to backend fin');
      } else {
        log('token is null');
      }
    } catch (error) {
      log('Google登入錯誤: $error');
    }
  }

  static Future<void> _sendTokenToBackend(String idToken) async {
    final url = Uri.parse('$baseUrl${ApiPath.loginAndRegister}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'idToken': idToken}),
    );
    log('$response');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access']; // 通常會有 access token
      log('登入成功, 後端發的 token: $token');
      // 這裡你可以把 token 存起來，比如用 shared_preferences
    } else {
      log('後端登入失敗: ${response.body}');
    }
  }
}

class UserRegisterPageState extends State<UserRegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GFButton(
            onPressed: () {
              GoogleSignInService.loginWithGoogle();
            },
            text: "使用 google 註冊",
            icon: Image.asset(
              'assets/register/google.png',
              width: 24,
              height: 24,
            ),
            color: GFColors.LIGHT,
            textColor: GFColors.DARK,
          ),
        ],
      ),
    );
  }
}
