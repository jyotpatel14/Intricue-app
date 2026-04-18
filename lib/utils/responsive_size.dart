import 'package:flutter/material.dart';

class ResponsiveSize {
  final BuildContext context;
  late double _screenWidth;
  late double _screenHeight;
  late double _devicePixelRatio;

  ResponsiveSize(this.context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    _screenWidth = size.width;
    _screenHeight = size.height;
    _devicePixelRatio = mediaQuery.devicePixelRatio;
  }

  double height(double value) => _screenHeight * value;
  double width(double value) => _screenWidth * value;

  /// Font size based on device pixel ratio (dpi scaling)
  /// Font size scaled to device width
  /// Font size scaling optimized for portrait mobile/tablet
  double fontSize(double value) {
    // Scale based on screen width with reasonable limits
    final widthScale =
        isTablet
            ? (_screenWidth / 375.0).clamp(0.85, 1.3)
            : (_screenWidth / 35.0).clamp(0.85, 1.37);
    return value * widthScale;
  }

  /// Responsive padding scaled to screen width
  double padding(double value) {
    final widthScale = (_screenWidth / 375.0).clamp(0.8, 1.4);
    return value * widthScale;
  }

  /// Responsive horizontal padding (left/right)
  double horizontalPadding(double value) {
    final widthScale = (_screenWidth / 375.0).clamp(0.8, 1.4);
    return value * widthScale;
  }

  /// Responsive vertical padding (top/bottom)
  double verticalPadding(double value) {
    final heightScale = (_screenHeight / 812.0).clamp(
      0.8,
      1.4,
    ); // 812 is iPhone 12 height
    return value * heightScale;
  }

  /// Create EdgeInsets with responsive padding
  EdgeInsets paddingAll(double value) {
    final scaledValue = padding(value);
    return EdgeInsets.all(scaledValue);
  }

  /// Create EdgeInsets with responsive symmetric padding
  EdgeInsets paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(horizontal),
      vertical: verticalPadding(vertical),
    );
  }

  /// Create EdgeInsets with responsive padding for each side
  EdgeInsets paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsets.only(
      left: horizontalPadding(left),
      top: verticalPadding(top),
      right: horizontalPadding(right),
      bottom: verticalPadding(bottom),
    );
  }

  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;

  bool get isTablet => _screenWidth > 600;
  bool get isSmallDevice => _screenWidth < 360;
}
