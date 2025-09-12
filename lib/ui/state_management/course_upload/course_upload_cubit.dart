import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eudkt/services/shared_preference.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/course_creator_globals.dart';

part 'course_upload_state.dart';

class CourseUploadCubit extends Cubit<CourseUploadState> {
  CourseUploadCubit() : super(Initial());
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  void uploadCourse(
      String courseName,
      String courseDescription,
      String selectedCareer,
      int credits,
      PlatformFile? coverImage,
      PlatformFile? introVideo,
      ) async {
    emit(Validating());
    final validationError = _validateCourseData(
      courseName,
      courseDescription,
      coverImage,
      introVideo,
      CourseCreatorGlobals.units
    );

    if (validationError != null) {
      emit(Error(validationError));
      return;
    }else{
      _processToUploadCourse(
          courseName,
          courseDescription,
          selectedCareer,
          credits,
          coverImage,
          introVideo
      );
    }


  }
  String generateCourseId() {
    final now = DateTime.now();
    final random = Random().nextInt(99999).toRadixString(36);
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour}${now.minute}_$random';
  }

  String? _validateCourseData(
      String courseName,
      String courseDescription,
      PlatformFile? coverImage,
      PlatformFile? introVideo,
      List<Unity> units,
      ) {
    if (courseName == 'Nuevo Curso' ||courseName == ''||courseName.isEmpty|| courseDescription.isEmpty) {
      return('El nombre y la descripción del curso son obligatorios.');
    }

    if (coverImage == null) {
      return('Debes seleccionar una imagen para el curso.');
    }

    if (introVideo == null) {
      return('Debes seleccionar un video introductorio.');
    }

    if (units.isEmpty) {
      return('El curso debe tener al menos una unidad.');
    }

    for (var u in units) {
      if (u.subjects.length < 3) {
        return('La unidad "${u.name}" debe tener al menos 3 temas.');
      }

      for (var s in u.subjects) {
        if (s.name.isEmpty) {
          throw Exception('Un tema en la unidad "${u.name}" no tiene nombre.');
        }

        if (s.type == SubjectType.theory &&
            (s.quillController?.document.toPlainText().trim().isEmpty ?? true)) {
          return(
              'El tema "${s.name}" en la unidad "${u.name}" no tiene contenido teórico.');
        }

        if (s.type == SubjectType.video && s.videoFile == null) {
          return(
              'El tema "${s.name}" en la unidad "${u.name}" no tiene video seleccionado.');
        }

        if (s.type == SubjectType.resources && s.resources.isEmpty) {
          return(
              'El tema "${s.name}" en la unidad "${u.name}" no tiene recursos.');
        }
      }

      if (u.isExam && u.questions.length < 5) {
        return(
            'La unidad "${u.name}" tiene examen, pero menos de 10 preguntas.');
      }

      if (!u.isExam && u.projectDescription.trim().isEmpty) {
        return(
            'La unidad "${u.name}" es un proyecto, pero no tiene descripción.');
      }
    }
    return null;
  }

  Future<void> _processToUploadCourse(
      String courseName,
      String courseDescription,
      String selectedCareer,
      int credits,
      PlatformFile? coverImage,
      PlatformFile? introVideo,
      ) async {
    String courseId = generateCourseId();
    final courseRef = _firestore.collection('courses').doc(courseId);
    final now = DateTime.now();

    try{

    final imageUrl = await _uploadFile(coverImage!, 'courses/$courseId/image');

    final videoUrl = await _uploadFile(introVideo!, 'courses/$courseId/intro');

    await courseRef.set({
      'is_active': false,
      'teacher_id': SharedPreferencesService.enrollment,
      'career': selectedCareer,
      'name': courseName,
      'description': courseDescription,
      'image': imageUrl,
      'intro_video': videoUrl,
      'credits': credits,
      'created_at': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    });

    final modulesRef = _firestore.collection('courses').doc(courseId).collection('modules');
    final units = CourseCreatorGlobals.units;

    for (int i = 0; i < units.length; i++) {
      final unit = units[i];
      final unitId = 'unity_${i + 1}';

      final unitDocRef = modulesRef.doc(unitId);
      await unitDocRef.set({'name': unit.name});

      for (int j = 0; j < unit.subjects.length; j++) {
        final subject = unit.subjects[j];
        final subjectId = 'subject_${j + 1}';

        String fileUrl = '';
        List<String> resourceUrls = [];

        /// Subir contenido dependiendo del tipo
        switch (subject.type) {
          case SubjectType.theory:
            final json = jsonEncode(subject.quillController!.document.toDelta().toJson());
            fileUrl = json;
            break;

          case SubjectType.video:
            if (subject.videoFile != null) {
              fileUrl = await _uploadFile(subject.videoFile!, 'courses/$courseId/$unitId/$subjectId}');
            }
            break;

          case SubjectType.resources:
            for (var resource in subject.resources) {
              resourceUrls.add(await _uploadFile(resource, 'courses/$courseId/$unitId/$subjectId'));
            }
            break;
        }

        /// Guardar subject
        await unitDocRef.collection('subjects').doc(subjectId).set({
          'name': subject.name,
          'type': subject.type.name,
          'file_url': subject.type == SubjectType.resources ? resourceUrls : fileUrl,
        });
      }

      if (unit.isExam) {
        /// Sincronizar preguntas
        for (final q in unit.questions) {
          q.syncValues();
        }

        final questionsList = unit.questions.map((q) => {
          'question': q.questionText,
          'options': q.options,
          'correct_answer': q.correctAnswerIndex,
        }).toList();

        await unitDocRef.collection('evaluation').doc('data').set({
          'type': 'exam',
          'questions': questionsList,
        });
      } else {
        await unitDocRef.collection('evaluation').doc('data').set({
          'type': 'project',
          'project_description': unit.projectDescription,
        });
      }
    }

    await _firestore.collection('teacher').doc(SharedPreferencesService.enrollment).set({
      'courses': FieldValue.arrayUnion([courseId]),
    }, SetOptions(merge: true));

    emit(Success());
  } catch (e) {
  emit(Error('Error al subir el curso: $e'));
  }

  }

  Future<String> _uploadFile(PlatformFile file, String route) async {
    final fileBytes = file.bytes;
    final fileName = file.name;
    final mType = mimeType(fileName);

    final ref = _storage.ref('$route/$fileName');
    final metadata = SettableMetadata(contentType: mType);

    await ref.putData(fileBytes!, metadata);

    return await ref.getDownloadURL();
  }

  String mimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/x-msvideo';
      case 'wmv':
        return 'video/x-ms-wmv';
      case 'webm':
        return 'video/webm';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'zip':
        return 'application/zip';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

}
