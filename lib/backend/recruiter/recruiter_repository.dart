import 'package:cloud_firestore/cloud_firestore.dart';

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
}