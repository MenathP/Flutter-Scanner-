import 'dart:io';

import 'package:dio/dio.dart';
import 'package:app/core/api/api_client.dart';

class PhotoService {
  static Future<Response> uploadPhoto(File image) async {
    final dio = ApiClient.instance.dio;
    final name = image.path.split(Platform.pathSeparator).last;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: name),
    });
    final resp = await dio.post('/api/photos/upload', data: form);
    return resp;
  }
}
