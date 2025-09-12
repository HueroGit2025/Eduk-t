import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadTestCourseButton extends StatelessWidget {
  const UploadTestCourseButton({super.key});

  Future<void> uploadTestCourse() async {
    final firestore = FirebaseFirestore.instance;

    final String courseId = generateCourseId();
    final courseRef = firestore.collection('courses').doc(courseId);

    final courseData = {
      'course_name': 'Curso de prueba de conexión',
      'description': 'Explora cómo funciona nuestra plataforma a través de este curso de prueba. '
          'Conocerás la estructura de los cursos, cómo acceder al contenido, realizar actividades y seguir tu progreso. '
          'Ideal para nuevos usuarios que desean familiarizarse con el sistema antes de comenzar un curso completo.',
      'career': 'Ing. en TICs',
      'teacher_id': '227012002',
      'image': 'https://flutter.github.io/assets-for-api-docs/assets/material/content_based_color_scheme_1.png',
      'state': 'active',
      'intro_video' : 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'created_at': FieldValue.serverTimestamp(),
    };

    await courseRef.set(courseData);

    for (int i = 1; i <= 5; i++) {
      final unityId = 'unity_$i';
      final unityRef = courseRef.collection('modules').doc(unityId);

      await unityRef.set({
        'name': 'Unidad $i',
      });

      // Crear 3 temas por unidad
      for (int j = 1; j <= 3; j++) {
        final subjectId = 'subject_$j';
        final subjectType = switch (j % 3) {
          1 => 'video',
          2 => 'theory',
          _ => 'resources',
        };

        final content = switch (subjectType) {
          'video' => {
            'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            'title': 'Video introductorio $i.$j',
          },
          'teoría' => {
            'text': 'Este es el contenido teórico del tema $j de la unidad $i.',
          },
          'resources' => {
            'links': ['https://docs.google.com/', 'https://drive.google.com/'],
          },
          _ => {},
        };

        await unityRef.collection('subjects').doc(subjectId).set({
          'name': 'Tema $j',
          'type': subjectType,
          'content': content,
        });
      }

      // Evaluación por unidad
      final isEven = i % 2 == 0;
      final evaluationContent = isEven
          ? {
        'type': 'exam',
        'description': 'Examen de opción múltiple para la unidad $i',
        'questions': [
          {
            'question': '¿Qué es Flutter?',
            'options': ['SDK', 'IDE', 'Lenguaje', 'Framework'],
            'answer': 0
          },
          {
            'question': '¿Firestore es una base de datos?',
            'options': ['Sí', 'No'],
            'answer': 0
          }
        ],
      }
          : {
        'type': 'proyect',
        'description': 'Entrega un proyecto basado en los temas de la unidad $i',
        'requirements': [
          'Crear una app básica con Flutter',
          'Subirla a GitHub',
          'Compartir el enlace'
        ],
      };

      await unityRef.collection('evaluation').doc('content').set(evaluationContent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: uploadTestCourse,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: const Text(
        'Subir curso de prueba',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

String generateCourseId() {
  final now = DateTime.now();
  final random = Random().nextInt(99999).toRadixString(36);
  return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour}${now.minute}_$random';
}

