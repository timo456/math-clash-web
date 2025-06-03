import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreFirestore {
  static final _collection = FirebaseFirestore.instance.collection('scores');

  static Future<void> insertScore(String name, int score) async {
    await FirebaseFirestore.instance.collection('scores').add({
      'name': name,
      'score': score,
      'timestamp': FieldValue.serverTimestamp(), // ✅ 排序用
    });
  }

  static Future<List<Map<String, dynamic>>> getScores() async {
    final query = await _collection.orderBy('score', descending: true).limit(50).get();
    return query.docs.map((doc) => doc.data()).toList();
  }
}
