import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/recruiterdata.dart';

class RecruiterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getRecruiter(String id) async {
    final doc = await _firestore.collection('recruiters').doc(id).get();
    return doc.data();
  }

  Future<void> markViewed(String id) async {
    await _firestore.collection('recruiters').doc(id).update({
      'viewed': true,
      'viewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveRecruiter(Map<String, dynamic> data) async {
    await _firestore.collection('recruiters').add(data);
  }

  Future<List<Map<String, dynamic>>> getAllRecruiters() async {
    final snapshot = await _firestore.collection('recruiters').get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  Future<RecruiterData> extractProfile(String text) async {
  final res = await http.post(
    Uri.parse("https://groq-worker.jyotpatel14.workers.dev"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"profileText": text}),
  ).timeout(const Duration(seconds: 15));

  if (res.statusCode != 200) {
    throw Exception("Worker error");
  }

  final data = jsonDecode(res.body);

  return RecruiterData.fromJson(data);
}
}