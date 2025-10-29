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
    int attempt = 0;
    const maxAttempts = 2; // initial try + one retry
    while (true) {
      attempt++;
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
        final isTimeout =
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout;
        final isSocket = e.error is SocketException;

        // Retry once for transient network issues
        if ((isTimeout || isSocket) && attempt < maxAttempts) {
          if (kDebugMode) {
            print(
              'AuthService: transient network error, retrying (attempt $attempt) - $e',
            );
          }
          await Future.delayed(const Duration(milliseconds: 300));
          continue;
        }

        if (isTimeout) {
          throw Exception('Network timeout, please try again');
        }
        if (e.response != null && e.response?.statusCode == 401) {
          throw Exception('Invalid code');
        }
        if (isSocket) {
          throw Exception('Network error, check your connection');
        }
        if (kDebugMode) {
          print('AuthService.loginWithCode dio error: $e');
        }
        rethrow;
      } catch (e) {
        if (kDebugMode) {
          print('AuthService.loginWithCode error: $e');
        }
        throw Exception('Failed to login');
      }
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}
