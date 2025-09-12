import 'package:eudkt/resources/colors.dart';
import 'package:eudkt/ui/widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../state_management/my_courses/my_courses_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/theme_toggle_button.dart';

class TeacherMain extends StatefulWidget {
  const TeacherMain({super.key});

  @override
  State<TeacherMain> createState() => _TeacherMainState();
}

class _TeacherMainState extends State<TeacherMain> {
  late final MyCoursesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MyCoursesCubit()..startListeningTeachers();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;
    final width = MediaQuery.sizeOf(context).width;
    final bool isTablet = width < 900;
    final bool isMobile = width < 600;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: width,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                color: isDark ? dark2 : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          colorFilter:  ColorFilter.mode(secondaryBlue, BlendMode.srcIn),
                          'assets/LOGO.svg',
                          alignment: Alignment.center,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),
                        const ThemeToggleButton(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ProfileButton(onImageUpdated: ()=>setState(() {}),),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: BlocProvider.value(
                value: _cubit,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: BlocBuilder<MyCoursesCubit, MyCoursesState>(
                    builder: (context, state) {
                      if (state is MyCoursesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is MyCoursesError) {
                        return Center(child: Text('Error: ${state.message}'));
                      } else if (state is MyCoursesEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                height: 100,
                                image: AssetImage('assets/empty-box.png'),
                              ),
                              Text('No has creado ningún curso.',
                                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      } else if (state is MyCoursesLoaded) {
                        final courses = state.courses;

                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 30),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile
                                ? 1
                                : isTablet
                                ? 2
                                : 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return CustomCard(
                              courseData: course,
                              cardType: 'teacher_card',
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: secondaryBlue,
        foregroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          context.go('/teacher/coursecreator');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo curso'),
      ),
    );
  }
}
