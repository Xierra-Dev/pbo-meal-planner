import 'package:flutter/material.dart';
import 'page_transitions.dart';

class NavigationHelper {
  static void navigateToPage(BuildContext context, Widget page, {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacement(
        context,
        FadePageRoute(page: page),
      );
    } else {
      Navigator.push(
        context,
        SlidePageRoute(page: page),
      );
    }
  }

  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
}