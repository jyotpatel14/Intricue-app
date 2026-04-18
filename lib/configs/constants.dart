//Shared Preference Keys
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SharePreferenceKeys {
  static const String bearerToken = "AuthToken";
  static const String appThemeMode = "themeMode";
  static const String selectedLanguage = "selectedLanguage";
  static const String isFirstTimeUser = "isFirstTimeUser";
  static const String userIdKey = "userIdKey";
  static const String userNameKey = "userNameKey";
  static const String role = "role";
}

class AppConstants {
  static Widget getBackButton(context, {Function()? onBackPress}) {
    return Center(
      child: GestureDetector(
        onTap: onBackPress ??
            () {
              Navigator.pop(context);
            },
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Container(
            height: 30,
            width: 30,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(40),
                side: const BorderSide(color: Color(0xffEDBC54), width: 3),
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 16,
              color: Color(0xffEDBC54),
            ),
          ),
        ),
      ),
    );
  }
}
