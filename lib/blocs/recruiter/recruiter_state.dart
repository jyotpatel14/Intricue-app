class RecruiterState {
  final bool isLoading;
  final Map<String, dynamic>? recruiter;
  final List<Map<String, dynamic>> recruiters;
  final String? generatedContent;
  final String? error;

  RecruiterState({
    required this.isLoading,
    this.recruiter,
    this.recruiters = const [],
    this.generatedContent,
    this.error,
  });

  factory RecruiterState.initial() {
    return RecruiterState(isLoading: false);
  }

  RecruiterState copyWith({
    bool? isLoading,
    Map<String, dynamic>? recruiter,
    List<Map<String, dynamic>>? recruiters,
    String? generatedContent,
    String? error,
  }) {
    return RecruiterState(
      isLoading: isLoading ?? this.isLoading,
      recruiter: recruiter ?? this.recruiter,
      recruiters: recruiters ?? this.recruiters,
      generatedContent: generatedContent ?? this.generatedContent,
      error: error ?? this.error,
    );
  }
}