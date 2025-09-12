import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> registerStudentToCourse({
  required String studentId,
  required String courseId,
  required String teacherId,
}) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    final studentRef = firestore.collection('students').doc(studentId);
    final courseRef = firestore.collection('courses').doc(courseId);
    final progressRef = firestore.collection('progress').doc(courseId).collection('students').doc(studentId);

    /// Verificar si el alumno ya está inscrito
    final studentSnapshot = await studentRef.get();
    final List<dynamic> studentCourses = studentSnapshot.data()?['courses'] ?? [];

    if (studentCourses.contains(courseId)) {
      return "info";
    }

    /// Añadir curso al alumno
    await studentRef.set({
      'courses': FieldValue.arrayUnion([courseId]),
    }, SetOptions(merge: true));

    /// Añadir alumno al curso del docente
    await courseRef.set({
      'students': FieldValue.arrayUnion([studentId]),
    }, SetOptions(merge: true));

    /// Obtener estructura del curso
    final modulesSnapshot = await courseRef.collection('modules').get();

    for (final unityDoc in modulesSnapshot.docs) {
      final unityId = unityDoc.id;
      final unityPath = progressRef.collection('modules').doc(unityId);

      final subjectSnapshot = await courseRef
          .collection('modules')
          .doc(unityId)
          .collection('subjects')
          .get();

      /// Crear documento de la unidad con progreso
      await unityPath.set({
        'unit_progress': 0,
      });

      /// Añadir cada subject como documento
      for (final subjectDoc in subjectSnapshot.docs) {
        await unityPath.collection('subjects').doc(subjectDoc.id).set({
          'completed': false,
        });
      }

      /// Evaluación
      final evalSnapshot = await courseRef
          .collection('modules')
          .doc(unityId)
          .collection('evaluation')
          .get();

      if (evalSnapshot.docs.isNotEmpty) {
        await unityPath.collection('evaluation').doc('data').set({
          'finished': false,
          'score': 0,
        });
      }
    }

    /// Estado general
    await progressRef.set({
      'status': {
        'evaluation': false,
        'unity': 1,
        'subject': 1,
        'total_progress': 0,
        'calification': 0,
      }
    }, SetOptions(merge: true));

    return "Inscripción exitosa";
  } catch (e) {
    return "error";
  }
}
