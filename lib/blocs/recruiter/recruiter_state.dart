// import '../../models/recruiterdata.dart';

// class RecruiterState {
//   final bool isLoading;
//   final Map<String, dynamic>? recruiter;
//   final List<Map<String, dynamic>> recruiters;

//   final RecruiterData? generatedData; // ✅ NEW
//   final String? error;

//   RecruiterState({
//     required this.isLoading,
//     this.recruiter,
//     this.recruiters = const [],
//     this.generatedData,
//     this.error,
//   });

//   factory RecruiterState.initial() {
//     return RecruiterState(isLoading: false);
//   }

//   RecruiterState copyWith({
//     bool? isLoading,
//     Map<String, dynamic>? recruiter,
//     List<Map<String, dynamic>>? recruiters,
//     RecruiterData? generatedData,
//     String? error,
//   }) {
//     return RecruiterState(
//       isLoading: isLoading ?? this.isLoading,
//       recruiter: recruiter ?? this.recruiter,
//       recruiters: recruiters ?? this.recruiters,
//       generatedData: generatedData ?? this.generatedData,
//       error: error ?? this.error,
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/recruiterdata.dart';

class RecruiterState {
  final bool isLoading;
  final bool isSaving;
  final Map<String, dynamic>? recruiter;
  final List<Map<String, dynamic>> recruiters;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;
  final RecruiterData? generatedData;
  final String? savedDocId; // ✅ ID returned after save — used to build link
  final String? error;

  RecruiterState({
    required this.isLoading,
    this.isSaving = false,
    this.recruiter,
    this.recruiters = const [],
    this.hasMore = true,
    this.lastDoc,
    this.generatedData,
    this.savedDocId,
    this.error,
  });

  factory RecruiterState.initial() {
    return RecruiterState(isLoading: false);
  }

  RecruiterState copyWith({
    bool? isLoading,
    bool? isSaving,
    Map<String, dynamic>? recruiter,
    List<Map<String, dynamic>>? recruiters,
    bool? hasMore,
    DocumentSnapshot? lastDoc,
    RecruiterData? generatedData,
    String? savedDocId,
    String? error,
  }) {
    return RecruiterState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      recruiter: recruiter ?? this.recruiter,
      recruiters: recruiters ?? this.recruiters,
      hasMore: hasMore ?? this.hasMore,
      lastDoc: lastDoc ?? this.lastDoc,
      generatedData: generatedData ?? this.generatedData,
      savedDocId: savedDocId ?? this.savedDocId,
      error: error ?? this.error,
    );
  }
}