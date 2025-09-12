import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/colors.dart';
import '../../state_management/admin_stats/stats_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.sizeOf(context).width < 750;
    final statsCubit = context.watch<StatsCubit>();


    return isMobile ?
    Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total de Alumnos',
                value: '${statsCubit.totalStudents}',
                icon: Icons.school_rounded,
                color: mainGreen,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: StatCard(
                title: 'Total de Docentes',
                value: '${statsCubit.totalTeachers}',
                icon: Icons.person_rounded,
                color: mainBlue,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Cursos Activos',
                value: '${statsCubit.activeCourses}',
                icon: Icons.book,
                color: mainPurple,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: StatCard(
                title: 'Contribuciones',
                value: '${statsCubit.contributions}',
                icon: Icons.insights_rounded,
                color: yellow,
              ),
            ),
          ],
        ),
      ],
    )
        :
    Row(
      children:  [
        Expanded(
          child: StatCard(
            title: 'Total de Alumnos',
            value: '${statsCubit.totalStudents}',
            icon: Icons.school_rounded,
            color: mainGreen,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: StatCard(
            title: 'Total de Docentes',
            value: '${statsCubit.totalTeachers}',
            icon: Icons.person_rounded,
            color: mainBlue,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: StatCard(
            title: 'Cursos Activos',
            value: '${statsCubit.activeCourses}',
            icon: Icons.book,
            color: mainPurple,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: StatCard(
            title: 'Contribuciones',
            value: '${statsCubit.contributions}',
            icon: Icons.insights_rounded,
            color: yellow,
          ),
        ),
      ],
    );
  }
}
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? dark : light,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),

              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

