// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../models/recruiterdata.dart';

// class RecruiterRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// 🔹 Get recruiter
//   Future<Map<String, dynamic>?> getRecruiter(String id) async {
//     print("📥 Fetching recruiter: $id");

//     final doc = await _firestore.collection('recruiters').doc(id).get();

//     print("✅ Recruiter fetched: ${doc.data()}");

//     return doc.data();
//   }

//   /// 🔹 Mark viewed
//   Future<void> markViewed(String id) async {
//     print("👁️ Marking recruiter viewed: $id");

//     await _firestore.collection('recruiters').doc(id).update({
//       'viewed': true,
//       'viewedAt': FieldValue.serverTimestamp(),
//     });

//     print("✅ Marked as viewed");
//   }

//   /// 🔹 Save recruiter
//   Future<void> saveRecruiter(Map<String, dynamic> data) async {
//     print("💾 Saving recruiter...");
//     print("👤 Current user: ${FirebaseAuth.instance.currentUser?.email ?? 'NOT LOGGED IN'}");

//     print("📊 Data: $data");

//     await _firestore.collection('recruiters').add(data);

//     print("✅ Recruiter saved successfully");
//   }

//   /// 🔹 Fetch all
//   Future<List<Map<String, dynamic>>> getAllRecruiters() async {
//     print("📥 Fetching all recruiters...");

//     final snapshot = await _firestore.collection('recruiters').get();

//     print("✅ Total recruiters: ${snapshot.docs.length}");

//     return snapshot.docs.map((e) => e.data()).toList();
//   }

//   /// 🔥 AI PIPELINE (Worker → Groq)
//   Future<RecruiterData> extractProfile(String text) async {
//     print("🚀 Starting AI extraction...");
//     print("📏 Input length: ${text.length} chars");

//      final encoded = jsonEncode({"profileText": text});
//   print("📤 ENCODED BODY (first 500): ${encoded.substring(0, encoded.length.clamp(0, 500))}");

//     try {

//       final res = await http
//           .post(
//             Uri.parse("https://groq-worker.jyotkpatel14.workers.dev"),
//             headers: {"Content-Type": "application/json", "Accept": "application/json",},
//             body: jsonEncode({"profileText": text}),
//           )
//           .timeout(const Duration(seconds: 15));

//       print("📡 Response status: ${res.statusCode}");

//       if (res.statusCode != 200) {
//         print("❌ Worker error: ${res.body}");
//         throw Exception("Worker error");
//       }

//       final data = jsonDecode(res.body);

//       print("📦 Raw response: $data");

//       final parsed = RecruiterData.fromJson(data);

//       print("✅ Parsed data:");
//       print("   Name: ${parsed.name}");
//       print("   Company: ${parsed.recentCompany}");
//       print("   Skills: ${parsed.skills}");

//       return parsed;

//     } catch (e) {
//       print("🔥 ERROR in extractProfile: $e");
//       rethrow;
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intricue_app/utils/my_print.dart';

import '../../models/recruiterdata.dart';

class RecruiterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Get recruiter
  Future<Map<String, dynamic>?> getRecruiter(String id) async {
    print("📥 Fetching recruiter: $id");
    final doc = await _firestore.collection('recruiters').doc(id).get();
    print("✅ Recruiter fetched: ${doc.data()}");
    return doc.data();
  }

  /// 🔹 Mark viewed
  Future<void> markViewed(String id) async {
    print("👁️ Marking recruiter viewed: $id");
    await _firestore.collection('recruiters').doc(id).update({
      'viewed': true,
      'viewedAt': FieldValue.serverTimestamp(),
    });
    print("✅ Marked as viewed");
  }

  /// 🔹 Save recruiter — returns the new document ID
  Future<String> saveRecruiter(Map<String, dynamic> data) async {
    print("💾 Saving recruiter...");
    print(
      "👤 Current user: ${FirebaseAuth.instance.currentUser?.email ?? 'NOT LOGGED IN'}",
    );
    print("📊 Data: $data");

    final keywords = _generateSearchKeywords(data);

    final dataWithMeta = {
      ...data,
      'savedBy': FirebaseAuth.instance.currentUser?.uid,
      'savedAt': FieldValue.serverTimestamp(),
      'searchKeywords': keywords,
    };

    final docRef = await _firestore.collection('recruiters').add(dataWithMeta);

    print("✅ Recruiter saved: ${docRef.id}");
    return docRef.id;
  }

  /// 🔹 Fetch paginated recruiters
  Future<({List<Map<String, dynamic>> items, DocumentSnapshot? lastDoc})>
  getRecruiters({
    DocumentSnapshot? startAfter,
    int limit = 10,
    String? search,
  }) async {
    Query query = _firestore
        .collection('recruiters')
        .orderBy('savedAt', descending: true)
        .limit(limit);

    if (search != null && search.trim().isNotEmpty) {
      query = _firestore
          .collection('recruiters')
          .where('searchKeywords', arrayContains: search.toLowerCase())
          .orderBy('savedAt', descending: true)
          .limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    final items = snapshot.docs
        .map((e) => {'id': e.id, ...e.data() as Map<String, dynamic>})
        .toList();


    MyPrint.printOnConsole("ItemCount : ${items.length}");
    return (
      items: items,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }

  /// 🔹 Fetch all (kept for compatibility)
  Future<List<Map<String, dynamic>>> getAllRecruiters() async {
    final result = await getRecruiters();
    return result.items;
  }

  /// 🔥 AI PIPELINE (Worker → Groq)
  Future<RecruiterData> extractProfile(String text) async {
    print("🚀 Starting AI extraction...");
    print("📏 Input length: ${text.length} chars");

    // Trim before encoding — 28k chars is too large
    final trimmed = text.length > 4000 ? text.substring(0, 4000) : text;
    final encoded = jsonEncode({"profileText": trimmed});
    print(
      "📤 ENCODED BODY (first 500): ${encoded.substring(0, encoded.length.clamp(0, 500))}",
    );

    try {
      final res = await http
          .post(
            Uri.parse("https://groq-worker.jyotkpatel14.workers.dev"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: encoded,
          )
          .timeout(const Duration(seconds: 30));

      print("📡 Response status: ${res.statusCode}");

      if (res.statusCode != 200) {
        print("❌ Worker error: ${res.body}");
        throw Exception("Worker error");
      }

      final data = jsonDecode(res.body);
      print("📦 Raw response: $data");

      final parsed = RecruiterData.fromJson(data);
      print("✅ Parsed: ${parsed.name} @ ${parsed.recentCompany}");

      return parsed;
    } catch (e) {
      print("🔥 ERROR in extractProfile: $e");
      rethrow;
    }
  }

  //generate keywords to search
  List<String> _generateSearchKeywords(Map<String, dynamic> data) {
    final fields = [
      data['name'],
      data['recent_company'],
      data['headline'],
      ...(data['skills'] ?? []),
    ];

    final Set<String> keywords = {};

    for (final field in fields) {
      if (field == null) continue;

      final words = field.toString().toLowerCase().split(RegExp(r'\s+'));

      for (final word in words) {
        if (word.trim().isNotEmpty) {
          keywords.add(word.trim());
        }
      }
    }

    return keywords.toList();
  }
}
