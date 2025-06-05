import 'package:flutter/material.dart';
import 'package:math_clash/score_firestore.dart';
import 'home_page.dart';
import 'coin_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResultPage extends StatefulWidget {
  final int player;
  final int blood;
  final bool win;
  final int score;

  const ResultPage({
    super.key,
    required this.player,
    required this.blood,
    required this.win,
    required this.score,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final TextEditingController _nameController = TextEditingController();
  int storedScore = 0;
  int levelReached = 1;
  String aiReply = '分析中...';

  @override
  void initState() {
    super.initState();
    _loadStoredData();
    _getAIReply(); // 👈 加這行
  }

  Future<void> _getAIReply() async {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: jsonEncode({
        'model': 'llama3-8b-8192',
        'messages': [
          {'role': 'system', 'content': '你是一位數學師父，簡潔的嘲諷玩家的得分表現，用現代一點的嘲諷方式，請用繁體中文。'},
          {'role': 'user', 'content': '我剛剛在遊戲中得到了 ${widget.score} 分，你覺得表現如何？'},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decoded);
      setState(() {
        aiReply = data['choices'][0]['message']['content'];
      });
    } else {
      setState(() {
        aiReply = '⚠️ AI 無法回應（${response.statusCode}）';
      });
    }
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      storedScore = prefs.getInt('score') ?? 0;
      levelReached = prefs.getInt('level') ?? 1;
    });
  }

  Future<void> _clearRecord() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('score');
    await prefs.remove('level');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ 紀錄已清除')),
    );

    // 延遲一點點給使用者看到提示再跳轉
    await Future.delayed(const Duration(milliseconds: 800));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }


  void _saveAndBack() async {
    final name = _nameController.text.trim().isEmpty ? '無名玩家' : _nameController.text;

    try {
      await ScoreFirestore.insertScore(name, widget.score);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('儲存失敗：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎮 結果畫面'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.flag, size: 100, color: Colors.deepOrange),
              const SizedBox(height: 16),
              const Text(
                '🟥 遊戲結束',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 28, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('到達第 $levelReached 關', style: const TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 28, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text('本次得分：${widget.score}', style: const TextStyle(fontSize: 20)),
                ],
              ),
              const Divider(height: 40, thickness: 2),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '👤 請輸入你的名字',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveAndBack,
                icon: const Icon(Icons.save),
                label: const Text('儲存並返回首頁'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _clearRecord,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('刪除紀錄', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 30),
              const Divider(height: 20, thickness: 1),
              const Text(
                '🤖 AI 評論',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                aiReply,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
