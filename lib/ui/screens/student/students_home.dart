import 'package:eudkt/ui/state_management/courses/courses_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../resources/colors.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/theme_toggle_button.dart';

class StudentsHome extends StatefulWidget {

  const StudentsHome({super.key});

  @override
  State<StudentsHome> createState() => _StudentsHomeState();
}

class _StudentsHomeState extends State<StudentsHome> {
  final PageController controller = PageController(viewportFraction: 0.55, initialPage: 1);
  int currentPage = 1;

  String? selectedCareer;

  @override
  void initState() {
    super.initState();
    context.read<CoursesCubit>().loadCourses();
  }

  void nextPage() {
    if (currentPage < ImageInfo.values.length - 1) {
      setState(() {
        currentPage++;
      });
      controller.animateToPage(currentPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInSine);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
      controller.animateToPage(currentPage, duration: const Duration(milliseconds: 600), curve: Curves.easeOutSine);
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    bool isTablet = MediaQuery.sizeOf(context).width < 900;
    bool isMobile = MediaQuery.sizeOf(context).width < 600;

    final double height = MediaQuery.sizeOf(context).height;
    final double width = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      child: Column(

        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  color: mainBlue,
                    'assets/LOGO.svg',
                  alignment: Alignment.center,
                  height: 30,
                ),
                SizedBox(width: 20,),
                ThemeToggleButton(),

              ],
            ),
          ),



          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: height * .6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      controller: controller,
                      itemCount: ImageInfo.values.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return HeroLayoutCard(imageInfo: ImageInfo.values[index]);
                      },
                    ),
                    Positioned(
                      left: 5,
                      child: IconButton(
                        onPressed: previousPage,
                        icon: Icon(Icons.chevron_left_rounded, size: 40, color: Colors.grey[100]!),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      child: IconButton(
                        onPressed: nextPage,
                        icon: Icon(Icons.chevron_right_rounded, size: 40, color: Colors.grey[100]!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mejora tus habilidades',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(
                      width: width*.75,
                      child: Text(
                        maxLines: 3,
                          textAlign: TextAlign.justify,
                          'Aquí encontrarás todos nuestros cursos disponibles. '
                              'Descubre contenido gratuito y accede '
                              'a materiales creados por docentes.'
                      ),
                    ),
                  ],
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
          ),

          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: BlocBuilder<CoursesCubit, CoursesState>(
              builder: (context, state) {
                if (state is CourseLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is CourseEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 100,),
                        Image(
                          height: 100,
                          image: AssetImage('assets/empty-box.png'),
                        ),
                        Text(
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),

                          selectedCareer == null
                              ? 'No hay cursos disponibles aún.'
                              : 'No hay cursos disponibles para la carrera seleccionada.',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 100,),

                      ],
                    ),
                  );
                } else if (state is CourseError) {
                  return Center(child: Text(state.message));
                } else if (state is CourseLoaded) {
                  final courses = state.courses;

                  return GridView.builder(
                    padding: EdgeInsets.only(bottom: 20),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : isTablet ? 2 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return CustomCard(
                        courseData: course,
                        cardType: 'overlay',

                      );
                    },
                  );
                }

                return SizedBox.shrink();
              },
            ),
          ),
          SizedBox(height: 100,)
        ],
      ),
    );
  }
}

class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({super.key, required this.imageInfo});

  final ImageInfo imageInfo;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (){

        },
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: OverflowBox(
                  maxWidth: width * 7 / 8,
                  minWidth: width * 7 / 8,
                  child: Image(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://flutter.github.io/assets-for-api-docs/assets/material/${imageInfo.url}',
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    imageInfo.title,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    imageInfo.subtitle,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
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

enum ImageInfo {
  image0(
    'The Flow',
    'Sponsored | Season 1 Now Streaming',
    'content_based_color_scheme_1.png',
  ),
  image1(
    'Through the Pane',
    'Sponsored | Season 1 Now Streaming',
    'content_based_color_scheme_2.png',
  ),
  image2(
    'Iridescence',
    'Sponsored | Season 1 Now Streaming',
    'content_based_color_scheme_3.png',
  ),
  image3(
    'Sea Change',
    'Sponsored | Season 1 Now Streaming',
    'content_based_color_scheme_4.png',
  ),
  image4(
    'Blue Symphony',
    'Sponsored | Season 1 Now Streaming',
    'content_based_color_scheme_5.png',
  ),
  image5(
    'When It Rains',
    'Sponsored | Season 1 Now Streaming',
    'content_based_color_scheme_6.png',
  );

  const ImageInfo(this.title, this.subtitle, this.url);
  final String title;
  final String subtitle;
  final String url;
}

