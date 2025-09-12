import 'package:eudkt/ui/state_management/students_list/students_list_cubit.dart';
import 'package:eudkt/ui/state_management/teachers_list/teachers_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../resources/colors.dart';
import '../../state_management/admin_stats/stats_cubit.dart';
import '../../state_management/courses/courses_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/admin_dashboard/add_user_dialog.dart';
import '../../widgets/admin_dashboard/comunity_section.dart';
import '../../widgets/admin_dashboard/stats_overview.dart';
import '../../widgets/admin_dashboard/students_list.dart';
import '../../widgets/admin_dashboard/teachers_list.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/profile_menu.dart';
import '../../widgets/theme_toggle_button.dart';



class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 750;
    final width = MediaQuery.sizeOf(context).width;
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;
    final ScrollController courseScrollController = ScrollController();
    context.read<CoursesCubit>().loadAdminCourses();

    void scrollCourses(double offset) {
      courseScrollController.animateTo(
        courseScrollController.offset + offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => StudentsListCubit()..listenStudents(),
),
    BlocProvider(
      create: (context) => TeachersListCubit()..listenTeachers(),
    ),
    BlocProvider(
      create: (_) => StatsCubit(),
    ),
  ],
  child: Scaffold(
        body: Stack(
          children: [
            ListView(
              children: [
                const SizedBox(height: 60),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DashboardHeader(),
                      const SizedBox(height: 20),
                      const StatsOverview(),
                      const SizedBox(height: 30),

                      isMobile ?
                      Column(
                        children: [
                          SizedBox(
                            height: 600,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AddButton(
                                        title: 'Añadir Alumnos',
                                        icon: Icons.person_add,
                                        color: secondaryBlue,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AddUserDialog(isStudent: true),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: AddButton(
                                        title: 'Añadir Docentes',
                                        icon: Icons.person_add,
                                        color: secondaryBlue,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AddUserDialog(isStudent: false),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Expanded(child: UsersTabView()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 400,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Aportes a la Comunidad',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Expanded(child: CommunitySection()),
                              ],
                            ),
                          ),
                        ],
                      )
                          :
                      SizedBox(
                        height: 600,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AddButton(
                                          title: 'Añadir Alumnos',
                                          icon: Icons.person_add,
                                          color: secondaryBlue,
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AddUserDialog(isStudent: true),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: AddButton(
                                          title: 'Añadir Docentes',
                                          icon: Icons.person_add,
                                          color: secondaryBlue,
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AddUserDialog(isStudent: false),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Expanded(child: UsersTabView()),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Aportes a la Comunidad',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigoAccent,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Expanded(child: CommunitySection()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 400,
                        child: Container(
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Cursos",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),

                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: BlocBuilder<CoursesCubit, CoursesState>(
                                    builder: (context, state) {
                                      if (state is CourseLoading) {
                                        return const Center(child: CircularProgressIndicator());
                                      } else if (state is CourseEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image(
                                                  height: 100,
                                                  image: AssetImage('assets/empty-box.png')
                                              ),
                                              Text(
                                                    'Aún no hay cursos para revisar.',
                                                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (state is CourseError) {
                                        return Center(child: Text(state.message));
                                      } else if (state is CourseLoaded) {
                                        final courses = state.courses;
                                        final bool isMobile = MediaQuery.sizeOf(context).width < 750;

                                        if (isMobile) {
                                          return ListView.builder(
                                            itemCount: courses.length,
                                            itemBuilder: (context, index) {
                                              final course = courses[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 15),
                                                child: SizedBox(
                                                  height: 250,
                                                    child: CustomCard(courseData: course, cardType: 'admin')),
                                              );
                                            },
                                          );
                                        } else {
                                          return Stack(
                                            children: [
                                              ListView.builder(
                                                controller: courseScrollController,
                                                scrollDirection: Axis.horizontal,
                                                itemCount: courses.length,
                                                itemBuilder: (context, index) {
                                                  final course = courses[index];
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 15),
                                                    child: SizedBox(
                                                      width: 400,
                                                      child: CustomCard(courseData: course, cardType: 'admin'),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Positioned(
                                                left: 0,
                                                top: 150,
                                                child: IconButton(
                                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                                  onPressed: () => scrollCourses(-250),
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 150,
                                                child: IconButton(
                                                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                                  onPressed: () => scrollCourses(250),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ProfileButton(onImageUpdated: ()=>setState(() {}),),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
);
  }
}
class AddButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AddButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsersTabView extends StatefulWidget {
  const UsersTabView({super.key});

  @override
  State<UsersTabView> createState() => _UsersTabViewState();
}

class _UsersTabViewState extends State<UsersTabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorColor: secondaryBlue,
          labelColor: secondaryBlue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Alumnos'),
            Tab(text: 'Docentes'),
          ],
        ),
        const SizedBox(height: 20),
        Flexible(
          child: TabBarView(
            controller: _tabController,
            children: const [
              StudentsList(),
              TeachersList(),
            ],
          ),
        ),
      ],
    );
  }
}

