import 'package:eudkt/resources/colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: mainBlue,
  scaffoldBackgroundColor: light2,
  appBarTheme:  AppBarTheme(
    backgroundColor: light2,
    foregroundColor: Colors.black87,

  ),

  drawerTheme: DrawerThemeData(
    backgroundColor: light2,
    elevation: 4,
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: secondaryBlue,
  ),
  inputDecorationTheme: InputDecorationTheme(
    floatingLabelStyle: TextStyle(
      color: secondaryBlue,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: secondaryBlue),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.grey[50],
    //color: Color(0xFFF7F7FF),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
);
