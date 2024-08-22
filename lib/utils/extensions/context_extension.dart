import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ThemeData get theme => Theme.of(this);

  bool get isLight => theme.brightness == Brightness.light;
  bool get isDark => theme.brightness == Brightness.dark;

  void pushReplacement({required Widget navigateTo}) {
    Navigator.pushReplacement(
      this,
      MaterialPageRoute(
        builder: (context) => navigateTo,
      ),
    );
  }

  void push({required Widget navigateTo}) {
    Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => navigateTo,
      ),
    );
  }

  void pop() => Navigator.pop(this);
  void pushRemoveUntil({required Widget to}) => Navigator.pushAndRemoveUntil(
        this,
        MaterialPageRoute(
          builder: (context) {
            return to;
          },
        ),
        (route) => false,
      );

  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;

  Size get size => Size(screenWidth, screenHeight);
  double height(double percentage) => percentage * screenHeight / 100;
  double width(double percentage) => percentage * screenWidth / 100;
}
