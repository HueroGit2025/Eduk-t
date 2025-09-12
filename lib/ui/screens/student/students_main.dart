import 'package:eudkt/resources/colors.dart';
import 'package:eudkt/ui/screens/student/community_page.dart';
import 'package:eudkt/ui/screens/student/students_home.dart';
import 'package:eudkt/ui/screens/student/my_courses.dart';
import 'package:eudkt/ui/screens/student/profile_page.dart';
import 'package:eudkt/ui/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';


class StudentsMain extends StatefulWidget {
  const StudentsMain({super.key});

  @override
  State<StudentsMain> createState() => _StudentsMainState();
}

class _StudentsMainState extends State<StudentsMain> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    StudentsHome(),
    MyCourses(),
    Community(),
    Profile(),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(

        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomNavBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                inIcons: [
                  Icon(Icons.home_rounded, color: secondaryBlue),
                  Icon(Icons.subscriptions_rounded, color: secondaryBlue),
                  Icon(Icons.groups_rounded, color: secondaryBlue),
                  Icon(Icons.person_rounded, color: secondaryBlue),
                ],
                aIcons: [
                  Icon(Icons.home_rounded, color: Colors.white),
                  Icon(Icons.subscriptions_rounded, color: Colors.white),
                  Icon(Icons.groups_rounded, color: Colors.white),
                  Icon(Icons.person_rounded, color: Colors.white),
                ],
                levelsList: [
                  'Inicio',
                  'Mis Cursos',
                  'Comunidad',
                  'Perfil'
                ],



              ),
            ],
          )

        ],
      ),

    );
  }
}



