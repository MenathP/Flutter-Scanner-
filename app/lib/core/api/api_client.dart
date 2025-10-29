import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// Allow overriding the API base URL at build/run time with:
// --dart-define=API_BASE_URL=http://192.168.x.y:7001
const _envApiBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');

class ApiClient {
  ApiClient._internal() {
    final base = _determineBaseUrl();
    dio = Dio(
      BaseOptions(
        baseUrl: base,
        // Give the server a bit more time on slower networks / debug devices
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    // Keep a pass-through error interceptor so callers can handle errors,
    // and add a logging interceptor to help diagnose network issues.
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (err, handler) {
          handler.next(err);
        },
      ),
    );
    // Only enable verbose logging in debug builds so release logs don't leak
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio dio;

  String _determineBaseUrl() {
    // Allow runtime override (useful when testing on physical devices):
    if (_envApiBase.isNotEmpty) return _envApiBase;

    // Android devices (emulator or physical) should contact the host machine's
    // IP on the local network. Update this default if your host IP changes.
    if (Platform.isAndroid) return 'http://10.231.227.33:7001';
    return 'http://localhost:7001';
  }
}
