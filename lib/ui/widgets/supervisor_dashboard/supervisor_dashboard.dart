import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../resources/colors.dart';
import '../../state_management/community/community_cubit.dart';
import '../../state_management/courses/courses_cubit.dart';
import '../../state_management/supervisor_dashboard/supervisor_dashboard_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../custom_card.dart';
import '../post_card.dart';
import '../profile_avatar.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  String? selectedCareer;

  @override
  void initState() {
    super.initState();
    context.read<CoursesCubit>().loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 750;
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return Column(
      children: [

        if (!isMobile) SizedBox(
          height: 400,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Alumnos",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              PopupMenuButton<String>(
                                color: isDark ? dark2 : light ,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                icon: const Icon(Icons.filter_list),
                                tooltip: 'Filtrar por carrera',
                                onSelected: (value) {
                                  setState(() {
                                    selectedCareer = value == 'Todos' ? null : value;
                                  });
                                  context.read<SupervisorDashboardCubit>().subscribeStudents(career: selectedCareer);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    value: 'Todos',
                                    child: Text('Mostrar todos'),
                                  ),
                                  const PopupMenuDivider(),
                                  ...[
                                    'Lic. en Contaduría Pública',
                                    'Lic. en Gastronomía',
                                    'Ing. Ambiental',
                                    'Ing. en Administración',
                                    'Ing. en Sistemas Computacionales',
                                    'Ing. en TICs',
                                    'Ing. en Energías Renovables',
                                    'Ing. Industrial',
                                    'Ing. en Sistemas Automotrices'
                                  ].map((career) => PopupMenuItem<String>(
                                    value: career,
                                    child: Text(career),
                                  )),
                                ],
                              )

                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: BlocBuilder<SupervisorDashboardCubit, SupervisorDashboardState>(
                              builder: (context, state){
                                if(state.students.isEmpty){
                                  return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image(
                                            height: 100,
                                            image: AssetImage('assets/empty-box.png'),
                                          ),
                                          Text('No hay Alumnos disponibles.',
                                            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                                          ),
                                        ],
                                      ));
                                }
                                return ListView.builder(
                                  itemCount: state.students.length,
                                  itemBuilder:(context, index){
                                    final student = state.students[index];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: GestureDetector(
                                        onTap: () => _showStudentDetails(context, student, isDark),
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isDark ? dark2 : Colors.grey[50],
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
                                            children: [
                                              ProfileAvatarBasic(imageUrl: state.students[index]['image'], size: 40),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(state.students[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    Text(state.students[index]['id'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Icon(Icons.chevron_right, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );

                                  }
                                );

                              }
                          ),
                        )
                      ],
                    ),
                  ),

                ),
              ),
              SizedBox(width: 20,),
              Expanded(
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Docentes",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: BlocBuilder<SupervisorDashboardCubit, SupervisorDashboardState>(
                              builder: (context, state){
                                if(state.teachers.isEmpty){
                                  return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image(
                                            height: 100,
                                            image: AssetImage('assets/empty-box.png'),
                                          ),
                                          Text('No hay Docentes disponibles.',
                                            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                                          ),
                                        ],
                                      ));
                                }
                                return ListView.builder(
                                    itemCount: state.teachers.length,
                                    itemBuilder:(context, index){
                                      final teacher = state.teachers[index];

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: GestureDetector(
                                          onTap: () => _showTeacherDetails(context, teacher, isDark),
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isDark ? dark2 : Colors.grey[50],
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
                                              children: [
                                                ProfileAvatarBasic(imageUrl: state.teachers[index]['image'], size: 40),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(state.teachers[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                                      Text(state.teachers[index]['id'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                const Icon(Icons.chevron_right, color: Colors.grey),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );

                                    }
                                );

                              }
                          ),
                        )
                      ],
                    ),
                  ),

                ),
              ),
            ],
          )

        ),

        if (isMobile)SizedBox(
          height: 400,
          child: Expanded(
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Alumnos",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          PopupMenuButton<String>(
                            color: isDark ? dark2 : light ,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            icon: const Icon(Icons.filter_list),
                            tooltip: 'Filtrar por carrera',
                            onSelected: (value) {
                              setState(() {
                                selectedCareer = value == 'Todos' ? null : value;
                              });
                              context.read<SupervisorDashboardCubit>().subscribeStudents(career: selectedCareer);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'Todos',
                                child: Text('Mostrar todos'),
                              ),
                              const PopupMenuDivider(),
                              ...[
                                'Lic. en Contaduría Pública',
                                'Lic. en Gastronomía',
                                'Ing. Ambiental',
                                'Ing. en Administración',
                                'Ing. en Sistemas Computacionales',
                                'Ing. en TICs',
                                'Ing. en Energías Renovables',
                                'Ing. Industrial',
                                'Ing. en Sistemas Automotrices'
                              ].map((career) => PopupMenuItem<String>(
                                value: career,
                                child: Text(career),
                              )),
                            ],
                          )

                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: BlocBuilder<SupervisorDashboardCubit, SupervisorDashboardState>(
                          builder: (context, state){
                            if(state.students.isEmpty){
                              return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        height: 100,
                                        image: AssetImage('assets/empty-box.png'),
                                      ),
                                      Text('No hay Alumnos disponibles.',
                                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                                      ),
                                    ],
                                  ));
                            }
                            return ListView.builder(
                                itemCount: state.students.length,
                                itemBuilder:(context, index){
                                  final student = state.students[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: GestureDetector(
                                      onTap: () => _showStudentDetails(context, student, isDark),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isDark ? dark2 : Colors.grey[50],
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
                                          children: [
                                            ProfileAvatarBasic(imageUrl: state.students[index]['image'], size: 40),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(state.students[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  Text(state.students[index]['id'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.chevron_right, color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                }
                            );

                          }
                      ),
                    )
                  ],
                ),
              ),

            ),
          ),
        ),
        if (isMobile)SizedBox(height: 20,),
        if (isMobile)SizedBox(
          height: 400,
          child: Expanded(
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Docentes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: BlocBuilder<SupervisorDashboardCubit, SupervisorDashboardState>(
                          builder: (context, state){
                            if(state.teachers.isEmpty){
                              return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        height: 100,
                                        image: AssetImage('assets/empty-box.png'),
                                      ),
                                      Text('No hay Docentes disponibles.',
                                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                                      ),
                                    ],
                                  ));
                            }
                            return ListView.builder(
                                itemCount: state.teachers.length,
                                itemBuilder:(context, index){
                                  final teacher = state.teachers[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: GestureDetector(
                                      onTap: () => _showTeacherDetails(context, teacher, isDark),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isDark ? dark2 : Colors.grey[50],
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
                                          children: [
                                            ProfileAvatarBasic(imageUrl: state.teachers[index]['image'], size: 40),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(state.teachers[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  Text(state.teachers[index]['id'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.chevron_right, color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                }
                            );

                          }
                      ),
                    )
                  ],
                ),
              ),

            ),
          ),
        ),
        if (isMobile)SizedBox(height: 20,),
        if (isMobile)SizedBox(
          height: 400,
          child: Expanded(
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Aportes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          PopupMenuButton<String>(
                            color: isDark ? dark2 : light ,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            icon: const Icon(Icons.filter_list),
                            tooltip: 'Filtrar por carrera',
                            onSelected: (value) {
                              setState(() {
                                selectedCareer = value == 'Todos' ? null : value;
                              });
                              context.read<CommunityCubit>().loadPosts(career: selectedCareer);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'Todos',
                                child: Text('Mostrar todos'),
                              ),
                              const PopupMenuDivider(),
                              ...[
                                'Lic. en Contaduría Pública',
                                'Lic. en Gastronomía',
                                'Ing. Ambiental',
                                'Ing. en Administración',
                                'Ing. en Sistemas Computacionales',
                                'Ing. en TICs',
                                'Ing. en Energías Renovables',
                                'Ing. Industrial',
                                'Ing. en Sistemas Automotrices'
                              ].map((career) => PopupMenuItem<String>(
                                value: career,
                                child: Text(career),
                              )),
                            ],
                          )

                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: BlocBuilder<CommunityCubit, CommunityState>(
                        builder: (context, state) {
                          if (state is CommunityEmpty) {
                            return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                      height: 100,
                                      image: AssetImage('assets/empty-box.png'),
                                    ),
                                    Text('No hay aportes disponibles.',
                                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                                    ),
                                  ],
                                ));
                          }else if (state is CommunityLoaded) {
                            final posts = state.posts;
                            return ListView.builder(
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                return PostCard(
                                    text: post['text'] ?? '',
                                    videoUrl: post['video']!,
                                    user: post['name'],
                                    avatar: post['image'],
                                    career: post['career'],
                                    createdAt: post['created_at']
                                );
                              },
                            );
                          }

                          return SizedBox.shrink();
                        },
                      ),

                    )
                  ],
                ),
              ),

            ),
          ),
        ),
        if (isMobile)SizedBox(height: 20,),
        if (isMobile)SizedBox(
          height: 400,
          child: Expanded(
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cursos",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        PopupMenuButton<String>(
                          color: isDark ? dark2 : light ,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          icon: const Icon(Icons.filter_list),
                          tooltip: 'Filtrar por carrera',
                          onSelected: (value) {
                            setState(() {
                              selectedCareer = value == 'Todos' ? null : value;
                            });
                            context.read<CoursesCubit>().loadCourses(career: selectedCareer);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'Todos',
                              child: Text('Mostrar todos'),
                            ),
                            const PopupMenuDivider(),
                            ...[
                              'Lic. en Contaduría Pública',
                              'Lic. en Gastronomía',
                              'Ing. Ambiental',
                              'Ing. en Administración',
                              'Ing. en Sistemas Computacionales',
                              'Ing. en TICs',
                              'Ing. en Energías Renovables',
                              'Ing. Industrial',
                              'Ing. en Sistemas Automotrices'
                            ].map((career) => PopupMenuItem<String>(
                              value: career,
                              child: Text(career),
                            )),
                          ],
                        )

                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: BlocBuilder<CoursesCubit, CoursesState>(
                        builder: (context, state) {
                          if (state is CourseLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (state is CourseEmpty) {
                            return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                      height: 100,
                                      image: AssetImage('assets/empty-box.png'),
                                    ),
                                    Text('No hay cursos disponibles.',
                                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                                    ),
                                  ],
                                ));
                          } else if (state is CourseError) {
                            return Center(child: Text(state.message));
                          } else if (state is CourseLoaded) {
                            final courses = state.courses;

                            return GridView.builder(
                              padding: EdgeInsets.only(bottom: 20),
                              shrinkWrap: true,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                                childAspectRatio: 1.8,
                              ),
                              itemCount: courses.length,
                              itemBuilder: (context, index) {
                                final course = courses[index];
                                return CustomCard(
                                  courseData: course,
                                  cardType: 'supervisor',

                                );
                              },
                            );
                          }

                          return SizedBox.shrink();
                        },
                      ),
                    )
                  ],
                ),
              ),

            ),
          ),
        ),
        const SizedBox(height: 20),

        if (!isMobile) SizedBox(
          height: 400,
          child: Row(
            children: [
              Expanded(
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Aportes",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              PopupMenuButton<String>(
                                color: isDark ? dark2 : light ,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                icon: const Icon(Icons.filter_list),
                                tooltip: 'Filtrar por carrera',
                                onSelected: (value) {
                                  setState(() {
                                    selectedCareer = value == 'Todos' ? null : value;
                                  });
                                  context.read<CommunityCubit>().loadPosts(career: selectedCareer);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    value: 'Todos',
                                    child: Text('Mostrar todos'),
                                  ),
                                  const PopupMenuDivider(),
                                  ...[
                                    'Lic. en Contaduría Pública',
                                    'Lic. en Gastronomía',
                                    'Ing. Ambiental',
                                    'Ing. en Administración',
                                    'Ing. en Sistemas Computacionales',
                                    'Ing. en TICs',
                                    'Ing. en Energías Renovables',
                                    'Ing. Industrial',
                                    'Ing. en Sistemas Automotrices'
                                  ].map((career) => PopupMenuItem<String>(
                                    value: career,
                                    child: Text(career),
                                  )),
                                ],
                              )

                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: BlocBuilder<CommunityCubit, CommunityState>(
                        builder: (context, state) {
                           if (state is CommunityEmpty) {
                            return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                      height: 100,
                                      image: AssetImage('assets/empty-box.png'),
                                    ),
                                    Text('No hay aportes disponibles.',
                                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                                    ),
                                  ],
                                ));
                          }else if (state is CommunityLoaded) {
                            final posts = state.posts;
                            return ListView.builder(
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                return PostCard(
                                  text: post['text'] ?? '',
                                  videoUrl: post['video']!,
                                  user: post['name'],
                                  avatar: post['image'],
                                    career: post['career'],
                                    createdAt: post['created_at'],
                                );
                              },
                            );
                          }

                          return SizedBox.shrink();
                        },
                        ),

                        )
                      ],
                    ),
                  ),

                ),
              ),
              SizedBox(width: 20,),
              Expanded(
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
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Cursos",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            PopupMenuButton<String>(
                              color: isDark ? dark2 : light ,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              icon: const Icon(Icons.filter_list),
                              tooltip: 'Filtrar por carrera',
                              onSelected: (value) {
                                setState(() {
                                  selectedCareer = value == 'Todos' ? null : value;
                                });
                                context.read<CoursesCubit>().loadCourses(career: selectedCareer);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem<String>(
                                  value: 'Todos',
                                  child: Text('Mostrar todos'),
                                ),
                                const PopupMenuDivider(),
                                ...[
                                  'Lic. en Contaduría Pública',
                                  'Lic. en Gastronomía',
                                  'Ing. Ambiental',
                                  'Ing. en Administración',
                                  'Ing. en Sistemas Computacionales',
                                  'Ing. en TICs',
                                  'Ing. en Energías Renovables',
                                  'Ing. Industrial',
                                  'Ing. en Sistemas Automotrices'
                                ].map((career) => PopupMenuItem<String>(
                                  value: career,
                                  child: Text(career),
                                )),
                              ],
                            )

                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: BlocBuilder<CoursesCubit, CoursesState>(
                          builder: (context, state) {
                            if (state is CourseLoading) {
                              return Center(child: CircularProgressIndicator());
                            } else if (state is CourseEmpty) {
                              return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        height: 100,
                                        image: AssetImage('assets/empty-box.png'),
                                      ),
                                      Text('No hay cursos disponibles.',
                                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                                      ),
                                    ],
                                  ));
                            } else if (state is CourseError) {
                              return Center(child: Text(state.message));
                            } else if (state is CourseLoaded) {
                              final courses = state.courses;

                              return GridView.builder(
                                padding: EdgeInsets.only(bottom: 20),
                                shrinkWrap: true,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: 1.8,
                                ),
                                itemCount: courses.length,
                                itemBuilder: (context, index) {
                                  final course = courses[index];
                                  return CustomCard(
                                    courseData: course,
                                    cardType: 'supervisor',

                                  );
                                },
                              );
                            }

                            return SizedBox.shrink();
                          },
                        ),
                        )
                      ],
                    ),
                  ),

                ),
              ),

            ],
          ),
        )
      ],
    );
  }

  void _showStudentDetails(
      BuildContext context, Map<String, dynamic> student, isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? dark3 : light2,
            borderRadius: BorderRadius.circular(30),
          ),
          width: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatarBasic(imageUrl: student['image'], size: 60),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student['name'],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text('Matrícula: ${student['id']}',
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Text(student['career'],
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Cursos Inscritos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo),
              ),
              const SizedBox(height: 15),

              if (student['courses'] == null ||
                  (student['courses'] as List).isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Image(
                            height: 100,
                            image: AssetImage('assets/empty-box.png')),
                        Text(
                          'Este alumno no cuenta con cursos inscritos.',
                          style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...student['courses'].map<Widget>((courseId) {
                  final progress = student['progress'][courseId] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? dark2 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.book, color: secondaryBlue),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            student['courseNames'][courseId],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: progress.toDouble(),
                                decoration: BoxDecoration(
                                  color: secondaryBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$progress%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: secondaryBlue),
                        ),
                      ],
                    ),
                  );
                }).toList(),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(color: secondaryBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeacherDetails(
      BuildContext context, Map<String, dynamic> teacher, bool isDark) {
    final courses = teacher['courses'] as List<dynamic>;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          width: 600,
          decoration: BoxDecoration(
            color: isDark ? dark3 : light2,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatarBasic(
                      imageUrl: teacher['image'] ?? '', size: 60),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'ID: ${teacher['id']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Cursos Impartidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 15),

              if (courses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Image(
                            height: 100,
                            image: AssetImage('assets/empty-box.png')),
                        Text(
                          'El docente no tiene cursos para esta carrera',
                          style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...courses.map<Widget>((courseId) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? dark2 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.book, color: Colors.indigo[400]),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            teacher['courseNames'][courseId] ??
                                'Curso sin nombre',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                            const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

