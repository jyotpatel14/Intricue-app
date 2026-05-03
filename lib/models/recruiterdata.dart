import 'package:intricue_app/utils/parsing_helper.dart';

class RecruiterData {
  final String? name;
  final String? email;
  final String? headline;
  final String? recentCompany;
  final String? recentRole;
  final String? experienceYears;
  final List<dynamic>? skills;

  RecruiterData({this.name, this.email, this.headline, this.recentCompany, this.recentRole, this.experienceYears, this.skills, });

  factory RecruiterData.fromJson(Map<String, dynamic> json) {
    return RecruiterData(
      name: ParsingHelper.parseStringNullableMethod(json['name']),
      email: ParsingHelper.parseStringNullableMethod(json['email']),
      headline: ParsingHelper.parseStringNullableMethod(json['headline']),
      recentCompany: ParsingHelper.parseStringNullableMethod(json['recent_company']),
      recentRole: ParsingHelper.parseStringNullableMethod(json['recent_role']),
      experienceYears: ParsingHelper.parseStringNullableMethod(json['experience_years']),
      skills: ParsingHelper.parseListMethod<dynamic, dynamic>(json['skills']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['headline'] = headline;
    data['recent_company'] = recentCompany;
    data['recent_role'] = recentRole;
    data['experience_years'] = experienceYears;
    data['skills'] = skills;
    return data;
  }
}


