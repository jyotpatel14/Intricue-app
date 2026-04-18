class NavigationArguments {
  const NavigationArguments();
}

class OtpScreenNavigationArguments extends NavigationArguments {
  final String mobile;

  const OtpScreenNavigationArguments({required this.mobile});
}

class QuizPageNavigationArguments extends NavigationArguments {
  final String levelId;
  final double? starsEarned;

  const QuizPageNavigationArguments({required this.levelId, this.starsEarned});
}

// class EventDetailNavigationArgument extends NavigationArguments {
//   final EventModel eventModel;
//   final UserModel? userModel;
//   final bool isFromPastEvent;
//   // final bool isSignUp;
//
//   const EventDetailNavigationArgument({
//     required this.eventModel,
//     this.userModel,
//     this.isFromPastEvent = false
//   });
// }

class OtpArgs {
  final String mobile;
  const OtpArgs({required this.mobile});

  Map<String, dynamic> toJson() => {'mobile': mobile};

  factory OtpArgs.fromJson(Map<String, dynamic> json) =>
      OtpArgs(mobile: json['mobile']);
}

class QuizArgs {
  final String levelId;
  final double? starsEarned;

  const QuizArgs({required this.levelId, this.starsEarned});

  Map<String, dynamic> toJson() => {
    'levelId': levelId,
    'starsEarned': starsEarned,
  };

  factory QuizArgs.fromJson(Map<String, dynamic> json) =>
      QuizArgs(levelId: json['levelId'], starsEarned: json['starsEarned']);
}
