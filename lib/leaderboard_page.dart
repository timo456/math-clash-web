import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String searchName = '';
  final TextEditingController _searchController = TextEditingController();

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('MM/dd HH:mm').format(timestamp.toDate());
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 0:
        return '👑';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '#${rank + 1}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 排行榜')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '🔍 輸入玩家名稱查詢',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  searchName = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scores')
                  .orderBy('score', descending: true)
                  .orderBy('timestamp', descending: false)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('發生錯誤：${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('尚無排行榜資料'));
                }

                final allDocs = snapshot.data!.docs;

                // 🔍 過濾 + 排序符合玩家
                final filteredDocs = allDocs.where((doc) {
                  final name = (doc['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchName.toLowerCase());
                }).toList();

                filteredDocs.sort((a, b) {
                  final aScore = a['score'] ?? 0;
                  final bScore = b['score'] ?? 0;
                  if (aScore != bScore) {
                    return bScore.compareTo(aScore); // 高分優先
                  } else {
                    final aTime = a['timestamp'] as Timestamp?;
                    final bTime = b['timestamp'] as Timestamp?;
                    return aTime?.compareTo(bTime ?? Timestamp.now()) ?? 0;
                  }
                });

                // 👀 顯示的清單
                final docsToShow = searchName.isNotEmpty ? filteredDocs : allDocs;

                return ListView.builder(
                  itemCount: docsToShow.length,
                  itemBuilder: (context, index) {
                    final doc = docsToShow[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? '未知玩家';
                    final score = data['score'] ?? 0;
                    final time = _formatTimestamp(data['timestamp']);
                    final isMatch = name.toString().toLowerCase().contains(searchName.toLowerCase());

                    return Card(
                      elevation: 3,
                      color: isMatch ? Colors.amber[100] : null, // 搜尋到的高亮
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          child: Text(
                            _getMedalEmoji(index),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('時間：$time'),
                        trailing: Text(
                          '$score 分',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
