

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eudkt/services/shared_preference.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> updateImageProfile(PlatformFile file)async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? collection;
  if(SharedPreferencesService.role == 'students'){
    collection = 'students';
  }else if(SharedPreferencesService.role == 'teacher'){
    collection = 'teachers';
  }else if(SharedPreferencesService.role == 'admin'){
    collection = 'admin';
  }else if(SharedPreferencesService.role == 'supervisor'){
    collection = 'supervisor';
  }
  String imageUrl = await _uploadFile(file, 'profiles/$collection/${SharedPreferencesService.enrollment}');
  SharedPreferencesService.updatedProfileImage(image: imageUrl);
  firestore.collection(collection!)
      .doc(SharedPreferencesService.enrollment)
      .update({
    'image': imageUrl,
      });
}

Future<String> _uploadFile(PlatformFile file, String route) async {
  final FirebaseStorage storage = FirebaseStorage.instance;

  final fileBytes = file.bytes;
  final fileName = 'profile_image.${file.extension}';
  final mType = _mimeType(fileName);

  final ref = storage.ref('$route/$fileName');
  final metadata = SettableMetadata(contentType: mType);

  await ref.putData(fileBytes!, metadata);

  return await ref.getDownloadURL();
}

String _mimeType(String fileName) {
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