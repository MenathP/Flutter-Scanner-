import 'dart:io';

import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._internal() {
    final base = _determineBaseUrl();
    dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (err, handler) {
          // Pass through so callers can handle it
          handler.next(err);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio dio;

  String _determineBaseUrl() {
    // Android emulator uses 10.0.2.2 to reach host machine. iOS simulator and others use localhost.
    if (Platform.isAndroid) return 'http://10.0.2.2:7001';
    return 'http://localhost:7001';
  }
}
