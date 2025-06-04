import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('遊戲簡介'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🟢 遊戲標題卡片
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.teal[50],
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.videogame_asset, size: 72, color: Colors.teal),
                    const SizedBox(height: 10),
                    Text(
                      '歡迎來到 MATH CLASH！',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '一場結合數學與策略的冒險之旅！',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 📘 四張遊戲說明卡片
            _infoCard(
              icon: Icons.swipe,
              title: '角色移動',
              content: '透過手指滑動控制主角左右移動，選擇適合的數學閘門。',
            ),
            _infoCard(
              icon: Icons.functions,
              title: '數學閘門',
              content: '通過「+」、「×」等閘門來增加角色人數，越多角色越有利！',
            ),
            _infoCard(
              icon: Icons.dangerous,
              title: 'Boss 對決',
              content: '通過跑道後角色會圍攻 Boss，依人數造成傷害，擊敗 Boss 才能過關。',
            ),
            _infoCard(
              icon: Icons.store,
              title: '強化道具',
              content: '在商店中可購買速度提升、護盾（延長耐久）、火力加強（攻擊乘2）等能力。',
            ),
            _infoCard(
              icon: Icons.leaderboard,
              title: '排行榜',
              content: '每次過關後可以輸入暱稱上榜，挑戰最高分並跟好友比一比！',
            ),
            _infoCard(
              icon: Icons.bolt,
              title: '難度設定',
              content: '可選擇簡單、中等、困難三種模式，Boss 血量會隨之變化挑戰性更高。',
            ),

          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(icon, size: 30, color: Colors.teal[600]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 6),
                  Text(content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
