import 'package:eudkt/resources/colors.dart';
import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: mainBlue,
  scaffoldBackgroundColor: dark3,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: secondaryBlue,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: dark2
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: dark2
  ),
  inputDecorationTheme: InputDecorationTheme(
    prefixIconColor: Colors.white,
    floatingLabelStyle: TextStyle(
      color: secondaryBlue,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide(color: secondaryBlue),
    ),
  ),
  cardTheme: CardThemeData(
    color: dark2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
);
