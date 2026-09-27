import 'package:flutter/material.dart';

/// QwikLearn's signature palette — dark ink on warm paper, with a
/// highlighter-yellow accent doing all the emphasis work. No blue/violet
/// "generic AI app" gradients anywhere in this file, on purpose.
class AppColors {
  AppColors._();

  // Core surfaces
  static const Color ink = Color(0xFF211F36); // primary text, dark surfaces, nav
  static const Color inkSoft = Color(0xFF4A4760); // secondary text on paper
  static const Color paper = Color(0xFFFBF7EE); // app background
  static const Color paperDim = Color(0xFFF1EBDB); // cards, chips, secondary surfaces
  static const Color paperLine = Color(0xFFE3DBC6); // hairlines, notebook rules, dividers

  // Accents
  static const Color highlight = Color(0xFFD8FF4F); // signature accent — progress, emphasis
  static const Color highlightDim = Color(0xFFEFFFB0); // faint highlighter wash
  static const Color coral = Color(0xFFFF6B5B); // secondary accent / destructive
  static const Color coralDim = Color(0xFFFFE1DB);
  static const Color lavender = Color(0xFFC9C4FF); // avatars, soft accents
  static const Color lavenderDim = Color(0xFFEAE7FF);
  static const Color sage = Color(0xFF9FBF8F); // success / correct-answer state
  static const Color sageDim = Color(0xFFE3EEDC);

  // Semantic
  static const Color success = sage;
  static const Color danger = coral;
  static const Color warning = Color(0xFFE8A33D);

  // Card difficulty tags
  static const Color easy = sage;
  static const Color medium = Color(0xFFE8A33D);
  static const Color difficult = coral;

  static const List<Color> avatarPalette = [lavender, coral, highlight, sage];
}
