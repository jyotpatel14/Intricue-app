// abstract class RecruiterEvent {}

// class LoadRecruiter extends RecruiterEvent {
//   final String id;
//   LoadRecruiter(this.id);
// }

// class MarkViewed extends RecruiterEvent {
//   final String id;
//   MarkViewed(this.id);
// }

// /// AI generation (no DB write yet)
// class GenerateContent extends RecruiterEvent {
//   final String prompt;
//   GenerateContent(this.prompt);
// }

// /// Save to Firestore (manual confirm)
// class SaveRecruiter extends RecruiterEvent {
//   final Map<String, dynamic> data;
//   SaveRecruiter(this.data);
// }

// /// Fetch all recruiters (admin list)
// class FetchAllRecruiters extends RecruiterEvent {}

abstract class RecruiterEvent {}

class LoadRecruiter extends RecruiterEvent {
  final String id;
  LoadRecruiter(this.id);
}

class MarkViewed extends RecruiterEvent {
  final String id;
  MarkViewed(this.id);
}

class GenerateContent extends RecruiterEvent {
  final String prompt;
  GenerateContent(this.prompt);
}

class SaveRecruiter extends RecruiterEvent {
  final Map<String, dynamic> data;
  SaveRecruiter(this.data);
}

class FetchAllRecruiters extends RecruiterEvent {}

class FetchMoreRecruiters extends RecruiterEvent {}

class ClearSavedDoc extends RecruiterEvent {}

class SearchRecruiters extends RecruiterEvent {
  final String query;

  SearchRecruiters(this.query);
}