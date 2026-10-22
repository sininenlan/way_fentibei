import 'package:flutter/material.dart';

const ink = Color(0xFF17201E);
const ink2 = Color(0xFF26322E);
const canvas = Color(0xFFF2F4F0);
const surface = Color(0xFFFFFFFF);
const soft = Color(0xFFF7F9F6);
const line = Color(0xFFDDE3DE);
const muted = Color(0xFF6D7873);
const teal = Color(0xFF2F7A6C);
const tealSoft = Color(0xFFDFEEE9);
const orange = Color(0xFFD76B34);
const orangeSoft = Color(0xFFF5E5DA);
const red = Color(0xFFD44F35);
const redSoft = Color(0xFFF8E4DE);
const amber = Color(0xFFD58B31);
const amberSoft = Color(0xFFF7EBD9);
const blue = Color(0xFF3E6D91);
const blueSoft = Color(0xFFE3ECF2);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Microsoft YaHei',
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.light,
      primary: teal,
      secondary: orange,
      surface: surface,
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: teal),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(soft),
      headingTextStyle: TextStyle(
        color: muted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      dataTextStyle: TextStyle(color: ink2, fontSize: 11),
      dividerThickness: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink2,
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
