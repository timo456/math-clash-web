import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:math_clash/shop_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'character_select_page.dart';
import 'coin_helper.dart';
import 'difficulty_page.dart';
import 'game_page.dart';
import 'guide_page.dart';
import 'leaderboard_page.dart';
import 'settings_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert'; // 要確保有 import


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int coins = 0;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void dispose() {
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coin = await CoinHelper.getCoins(); // ⬅️ 使用 CoinHelper
    setState(() {
      coins = coin;
    });
  }

  void _showMasterDialog() {
    TextEditingController _questionController = TextEditingController();
    String? reply;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('🧙 師父說：'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: '請輸入你的問題（例如：什麼是質數？）',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else if (reply != null)
                    Text(reply!, style: const TextStyle(fontSize: 16)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final question = _questionController.text.trim();
                    if (question.isEmpty) return;
                    setState(() {
                      isLoading = true;
                      reply = null;
                    });
                    try {
                      final result = await _getAIReply(question);
                      setState(() {
                        reply = result;
                        isLoading = false;
                      });
                    } catch (e) {
                      setState(() {
                        reply = '出錯了：$e';
                        isLoading = false;
                      });
                    }
                  },
                  child: const Text('請示 🧠'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('謝謝師父 🙏'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<String> _getAIReply(String message) async {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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', // ⬅️ 改成你的金鑰
      },
      body: jsonEncode({
        'model': 'llama3-8b-8192',
        'messages': [
          {'role': 'system', 'content': '你是一位數學師父，語氣睿智簡潔，請用繁體中文回答玩家的問題。'},
          {'role': 'user', 'content': message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes); // ✅ 強制用 UTF-8 解碼
      final data = jsonDecode(decoded);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Groq 回應錯誤: ${response.statusCode}');
    }
  }



  Future<void> _playClickSound() async {
    final prefs = await SharedPreferences.getInstance();
    double volume = prefs.getDouble('volume') ?? 0.5;

    await _sfxPlayer.play(
      AssetSource('sounds/click.mp3'),
      volume: volume,
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      shadowColor: Colors.purpleAccent,
    );

    return Scaffold(
        backgroundColor: const Color(0xFFFCF8FF),
    body: SafeArea( // ✅ 加這一層
      child: Stack(
        children: [
          // 背景圖可改為雲朵、漸層等
          Positioned.fill(
            child: Image.asset(
              'assets/bg_main.png',
              fit: BoxFit.cover,
            ),
          ),

          // 頭像 or 裝飾
          Positioned(top: 50, right: 20, child: Icon(Icons.account_circle, size: 50, color: Colors.grey[400])),

          // 中心主體內容
      LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight( // ✅ 讓內容可自動置中
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🌟 標題
                    FittedBox(
                    fit: BoxFit.scaleDown, // ⬅️ 讓內容自動縮小以符合寬度
                    child: Stack(
                      children: [
                        Text(
                          '🌟 MATH CLASH 🌟',
                          style: TextStyle(
                            fontSize: 64, // 設最大字體，FittedBox 會自動縮小
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 6
                              ..color = Colors.white,
                          ),
                        ),
                        Text(
                          '🌟 MATH CLASH 🌟',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                      const SizedBox(height: 8),
                      // 💰 金幣
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade700),
                        ),
                        child: Text(
                          '💰 金幣：$coins',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 🧮 選單按鈕
                      ..._buildMenuButtons(buttonStyle),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
          // AI 師父按鈕（右下角）
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: _showMasterDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[700],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🧙', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      '請示師父',
                      style: TextStyle(
                        color: Colors.amber[100],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),

        ],
    ),
    ),
    );
  }

  List<Widget> _buildMenuButtons(ButtonStyle style) {
    final labels = [
      "開始遊戲",
      "難度選擇",
      "遊戲簡介",
      "排行榜",
      "角色選擇",
      "商店",
      "音效設定"
    ];


    return labels.map((label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: style,
            onPressed: () async {
              await _playClickSound();

              if (label == "開始遊戲") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GamePage()));
              } else if (label == "音效設定") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              } else if (label == "難度選擇") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DifficultyPage()));
              } else if (label == "遊戲簡介") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidePage()));
              } else if (label == "排行榜") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardPage()));
              } else if (label == "角色選擇") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterSelectPage()));
              } else if (label == "商店") {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopPage()));
                _loadCoins(); // 回來後刷新金幣顯示
              }
            },
            child: Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _circleDeco(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
