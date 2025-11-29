import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors_manager.dart';

class TextStyles {
  TextStyles._();

  // Headings
  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: ColorsManager.textPrimaryLight,
      );

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: ColorsManager.textPrimaryLight,
      );

  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: ColorsManager.textPrimaryLight,
      );

  // Body Text
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: ColorsManager.textPrimaryLight,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: ColorsManager.textPrimaryLight,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: ColorsManager.textSecondaryLight,
      );

  // Labels
  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: ColorsManager.textPrimaryLight,
      );

  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: ColorsManager.textPrimaryLight,
      );

  // Code/Monospace
  static TextStyle get code => GoogleFonts.firaCode(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: ColorsManager.textPrimaryLight,
      );

  static TextStyle get codeSmall => GoogleFonts.firaCode(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: ColorsManager.textPrimaryLight,
      );

  // Button
  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  // Category Title
  static TextStyle get categoryTitle => GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: ColorsManager.textPrimaryLight,
      );

  // Algorithm Card
  static TextStyle get algorithmTitle => GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: ColorsManager.textPrimaryLight,
      );

  static TextStyle get algorithmDescription => GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: ColorsManager.textSecondaryLight,
      );

  // Complexity Badge
  static TextStyle get complexityBadge => GoogleFonts.firaCode(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );
}
