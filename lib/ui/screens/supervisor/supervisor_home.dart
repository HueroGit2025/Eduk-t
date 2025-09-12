import 'package:eudkt/ui/state_management/admin_stats/stats_cubit.dart';
import 'package:eudkt/ui/state_management/community/community_cubit.dart';
import 'package:eudkt/ui/state_management/supervisor_dashboard/supervisor_dashboard_cubit.dart';
import 'package:eudkt/ui/widgets/admin_dashboard/stats_overview.dart';
import 'package:eudkt/ui/widgets/supervisor_dashboard/supervisor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../resources/colors.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/profile_menu.dart';
import '../../widgets/theme_toggle_button.dart';

class SupervisorHome extends StatefulWidget {
  const SupervisorHome({super.key});

  @override
  State<SupervisorHome> createState() => _SupervisorHomeState();
}

class _SupervisorHomeState extends State<SupervisorHome> {
  @override

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;
    return MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => StatsCubit(),
    ),
    BlocProvider(
      create: (context) => SupervisorDashboardCubit(),
    ),
    BlocProvider(
      create: (context) => CommunityCubit()..loadPosts(),
    ),
  ],
  child: Scaffold(
        body: Stack(
          children: [
            ListView(
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding:EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      DashboardHeader(),
                      const SizedBox(height: 20),
                      StatsOverview(),
                      const SizedBox(height: 20),

                      SupervisorDashboard()

                    ],
                  ),
                ),
              ],
            ),
            Container(
              width: width,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? dark4 : Colors.grey[300]!)),
                color: isDark ? dark3 : light,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: SvgPicture.asset(
                      color: mainBlue,
                      'assets/LOGO.svg',
                      alignment: Alignment.center,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                  ThemeToggleButton(),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: ProfileButton(onImageUpdated: ()=>setState(() {}),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
