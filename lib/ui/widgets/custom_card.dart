import 'package:eudkt/resources/colors.dart';
import 'package:eudkt/services/app_snackbar.dart';
import 'package:eudkt/services/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/register_student_course.dart';
import 'course_overlay.dart';


class CustomCard extends StatefulWidget {
  final Map<String, dynamic> courseData;
  final String cardType;


  const CustomCard({super.key, required this.courseData, required this.cardType});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  double _scale = 0;

  void _onHover(bool hovering) {
    setState(() {
      _scale = hovering ? 10 : 0;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: (){
          if (widget.cardType == 'overlay'){
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => CourseOverlay(
                courseData: widget.courseData,
                onEnroll: () async {
                  String result = await registerStudentToCourse(
                    studentId: SharedPreferencesService.enrollment!,
                    courseId: widget.courseData['id'],
                    teacherId: widget.courseData['teacher_id'],
                  );
                  context.pop();
                  if (result == "error") {
                    AppSnackBar.showError('Error al inscribir al alumno');
                    return;
                  }else if(result == "info"){
                    AppSnackBar.showInfo('Ya estás inscrito en este curso');
                    return;
                  }else{
                    AppSnackBar.showSuccess('¡Inscripción exitosa!');
                  }
                },
              ),
            );
          }else if(widget.cardType == 'teacher_card'){
            context.go('/teacher/course/${widget.courseData['id']}');
          }else if(widget.cardType == 'student_card'){
            context.go('/students/course/${widget.courseData['id']}');
          }else if(widget.cardType == 'supervisor'){
            context.go('/supervisor/home/course/${widget.courseData['id']}');
          }else if(widget.cardType == 'admin'){
            context.go('/admin/home/course/${widget.courseData['id']}');
          }


        },
        child: AnimatedContainer(
          margin: EdgeInsets.all(_scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(widget.courseData['image']),
            ),
          ),
          duration: Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.courseData['course_name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.courseData['description'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: yellow, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            '${widget.courseData['credits']}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

