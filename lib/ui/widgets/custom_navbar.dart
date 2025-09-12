import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:eudkt/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state_management/theme/theme_cubit.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<Widget> inIcons;
  final List<Widget> aIcons;
  final List<String> levelsList;


  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.inIcons,
    required this.aIcons,
    required this.levelsList,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return CircleNavBar(
      onTap: onTap,
        color: isDark ? dark : light,
        circleColor: secondaryBlue,
        height: 60,
        circleWidth: 50,
      levels: levelsList,
        activeIndex: currentIndex,
        activeIcons: aIcons,
        inactiveIcons: inIcons,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      cornerRadius: BorderRadius.circular(30),
      elevation: 10,
      shadowColor: Colors.black12,

    );
  }
}
