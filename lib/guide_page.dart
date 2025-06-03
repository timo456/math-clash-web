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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎮 遊戲標題區塊
            Center(
              child: Column(
                children: [
                  const Icon(Icons.videogame_asset, size: 72, color: Colors.teal),
                  const SizedBox(height: 8),
                  Text(
                    '歡迎來到 MATH CLASH！',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // 📘 遊戲說明卡片
            _infoCard(
              icon: Icons.swipe,
              title: '操作方式',
              content: '在遊戲中，使用滑動手勢控制角色左右移動，選擇左右的數學閘門。',
            ),
            _infoCard(
              icon: Icons.calculate,
              title: '閘門邏輯',
              content: '每個閘門會加、減、乘（或未來新增除）你的角色數量，選擇最有利的路線！',
            ),
            _infoCard(
              icon: Icons.bug_report,
              title: 'BOSS 對決',
              content: '通過數學試煉後，你的角色會圍成一圈與 BOSS 戰鬥，決定最終勝負。',
            ),
            _infoCard(
              icon: Icons.emoji_events,
              title: '獲勝條件',
              content: '若角色人數成功擊敗 BOSS 並活下來，你就能取得高分與勝利！',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String content}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.teal),
            const SizedBox(width: 16),
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
            )
          ],
        ),
      ),
    );
  }
}
