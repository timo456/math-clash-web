//s11230017劉冠廷 s11230069潘柏霖
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // ✅ flutterfire 自動生成的
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ❗初始化必要
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MathClashApp());
}


class MathClashApp extends StatelessWidget {
  const MathClashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MATH CLASH',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginPage(), // 👈 改成這個
      debugShowCheckedModeBanner: false,
    );
  }
}
