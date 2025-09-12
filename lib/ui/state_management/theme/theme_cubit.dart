import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/themes/dark_theme.dart';
import '../../../config/themes/light_theme.dart';
part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(themeData: lightTheme, isDarkMode: false));

  void toggleTheme() {
    emit(
        state.isDarkMode
        ? ThemeState(themeData: lightTheme, isDarkMode: false)
        : ThemeState(themeData: darkTheme, isDarkMode: true)
    );
  }
}
