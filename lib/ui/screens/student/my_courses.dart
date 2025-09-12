
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/colors.dart';
import '../../state_management/my_courses/my_courses_cubit.dart';
import '../../widgets/custom_card.dart';

class MyCourses extends StatefulWidget {
  const MyCourses({super.key});

  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
  late final MyCoursesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MyCoursesCubit(
    )..startListeningStudents();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.sizeOf(context).width < 900;
    bool isMobile = MediaQuery.sizeOf(context).width < 600;
    return BlocProvider.value(
      value: _cubit,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mis Cursos',
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: thirdBlue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white,),
                  SizedBox(width: 15,),
                  Expanded(child: Text ('Recuerda que solo podras obtener creditos hasta sexto semestre', style: const TextStyle(color: Colors.white),)),
                ],
              ),
            ),
            SizedBox(height: 20,),
            BlocBuilder<MyCoursesCubit, MyCoursesState>(
              builder: (context, state) {
                if (state is MyCoursesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MyCoursesEmpty) {
                  return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 100,),
                          Image(
                            height: 100,
                            image: AssetImage('assets/empty-box.png'),
                          ),
                          Text(
                          'No estás inscrito en ningún curso.',
                            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ));
                } else if (state is MyCoursesError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is MyCoursesLoaded) {
                  final courses = state.courses;

                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : isTablet ? 2:3 ,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return CustomCard(
                        courseData: course,
                        cardType: 'student_card',
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

}
