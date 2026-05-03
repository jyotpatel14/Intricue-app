import '../../models/recruiterdata.dart';

class RecruiterState {
  final bool isLoading;
  final Map<String, dynamic>? recruiter;
  final List<Map<String, dynamic>> recruiters;

  final RecruiterData? generatedData; // ✅ NEW
  final String? error;

  RecruiterState({
    required this.isLoading,
    this.recruiter,
    this.recruiters = const [],
    this.generatedData,
    this.error,
  });

  factory RecruiterState.initial() {
    return RecruiterState(isLoading: false);
  }

  RecruiterState copyWith({
    bool? isLoading,
    Map<String, dynamic>? recruiter,
    List<Map<String, dynamic>>? recruiters,
    RecruiterData? generatedData,
    String? error,
  }) {
    return RecruiterState(
      isLoading: isLoading ?? this.isLoading,
      recruiter: recruiter ?? this.recruiter,
      recruiters: recruiters ?? this.recruiters,
      generatedData: generatedData ?? this.generatedData,
      error: error ?? this.error,
    );
  }
}