import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _loadSavedNickname();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // ✅ 已登入，就直接跳 Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else if (kIsWeb) {
        // ✅ Web 平台再檢查 redirect 回來的登入結果
        try {
          final result = await FirebaseAuth.instance.getRedirectResult();
          if (result.user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        } catch (e) {
          debugPrint('🔴 redirect 登入錯誤: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('登入後導回失敗：$e')),
          );
        }
      }
    });
  }


  void _loadSavedNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('nickname');
    if (savedName != null && mounted) {
      setState(() {
        _nameController.text = savedName;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    try {
      if (kIsWeb) {
        // ✅ 網頁平台用 redirect（會跳去 Google，再回來）
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithRedirect(provider);
      } else {
        // ✅ 手機或桌面平台用 GoogleSignIn 套件
        final googleUser = await GoogleSignIn().signIn();
        final googleAuth = await googleUser?.authentication;
        if (googleAuth == null) return;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 登入失敗：$e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }


  Future<void> _signInAnonymously() async {
    setState(() {
      _loading = true;
      _showError = false;
    });

    final nickname = _nameController.text.trim();
    if (nickname.isEmpty) {
      setState(() {
        _loading = false;
        _showError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先輸入暱稱')),
      );
      return;
    }

    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
      await auth.currentUser?.updateDisplayName(nickname);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('nickname', nickname);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登入失敗：$e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.indigo,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videogame_asset, size: 72, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'MATH CLASH',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '輸入你的暱稱',
                        errorText: _showError ? '暱稱不能為空' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person),
                      label: const Text('匿名登入', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      onPressed: _signInAnonymously,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('使用 Google 登入', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                        onPressed: () async {
                          setState(() => _loading = true);
                          try {
                            final provider = GoogleAuthProvider();
                            await FirebaseAuth.instance.signInWithRedirect(provider);
                            // ❌ 不要加 Navigator.pushReplacement()，redirect 後這裡不會執行
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Google 登入失敗：$e')),
                            );
                            setState(() => _loading = false); // 加在 catch 裡，因為 redirect 成功時頁面會跳走
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ 加上這段讓 Web 登入時也顯示 loading 圈圈
          if (_loading)
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      );
    }


    // ✅ 手機/模擬器登入畫面
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videogame_asset, size: 72, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'MATH CLASH',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '輸入你的暱稱',
                      errorText: _showError ? '暱稱不能為空' : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text('匿名登入', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    onPressed: _signInAnonymously,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('使用 Google 登入', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _signInWithGoogle,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black38,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
