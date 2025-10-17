import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/core/api/api_client.dart';
import 'package:app/models/user_model.dart';

class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel> loginWithCode(String code) async {
    try {
      final resp = await ApiClient.instance.dio.post(
        '/api/auth/login-code',
        data: {'code': code},
      );
      final data = resp.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userJson = data['user'] as Map<String, dynamic>?;
      if (token == null || userJson == null) {
        throw Exception('Invalid response from server');
      }
      await _storage.write(key: 'jwt_token', value: token);
      final user = UserModel.fromJson(userJson);
      return user;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Network timeout, please try again');
      }
      if (e.response != null && e.response?.statusCode == 401) {
        throw Exception('Invalid code');
      }
      if (e.error is SocketException) {
        throw Exception('Network error, check your connection');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) print('AuthService.loginWithCode error: $e');
      throw Exception('Failed to login');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}
