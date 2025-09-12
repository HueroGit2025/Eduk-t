import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  StreamSubscription? _subscription;

  CommunityCubit() : super(CommunityInitial());

  void loadPosts({String? career}) {
    emit(CommunityLoading());

    _subscription?.cancel();

    final query = FirebaseFirestore.instance.collection('publications');
    final stream = (career != null && career.isNotEmpty)
        ? query.where('career', isEqualTo: career).snapshots()
        : query.snapshots();

    _subscription = stream.listen((snapshot) async {
      final posts = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        data['id'] = doc.id;

        final studentId = data['student_id'];

        if (studentId != null) {
          try {
            final studentDoc = await FirebaseFirestore.instance
                .collection('students')
                .doc(studentId)
                .get();

            if (studentDoc.exists) {
              final studentData = studentDoc.data();
              data['image'] = studentData?['image'];
            }
          } catch (e) {
            data['image'] = '';
          }
        }

        return data;
      }).toList());

      if (posts.isEmpty) {
        emit(CommunityEmpty());
      } else {
        emit(CommunityLoaded(posts));
      }
    }, onError: (error) {
      emit(CommunityError('Error al cargar aportes: $error'));
    });
  }

  Future<bool> addPost(Map<String, dynamic> postData, String studentId, String postId) async {
    final now = DateTime.now();
    final createdAt = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    postData['created_at'] = createdAt;

    try {
      await FirebaseFirestore.instance
          .collection('publications')
          .doc(postId)
          .set(postData);

      await FirebaseFirestore.instance.collection('students').doc(studentId).set({
        'publications': FieldValue.arrayUnion([postId]),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> uploadFile(PlatformFile file, String route) async {
    final ref = FirebaseStorage.instance.ref('$route/${file.name}');
    final mType = mimeType(file.name);

    if (kIsWeb) {
      await ref.putData(file.bytes!, SettableMetadata(contentType: mType));
    } else {
      final uploadFile = File(file.path!);
      await ref.putFile(uploadFile, SettableMetadata(contentType: mType));
    }

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

  String generateCourseId() {
    final now = DateTime.now();
    final random = Random().nextInt(99999).toRadixString(36);
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour}${now.minute}_$random';
  }

  void deletePost(String postId, String studentId) async {
    try {
      await FirebaseFirestore.instance.collection('publications').doc(postId).delete();
      await FirebaseFirestore.instance.collection('students').doc(studentId).update({
        'publications': FieldValue.arrayRemove([postId]),
      });
    } catch (e) {
      emit(CommunityError('Error al eliminar aporte: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
