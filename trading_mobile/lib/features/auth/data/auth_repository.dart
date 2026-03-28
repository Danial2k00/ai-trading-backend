import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

const _kTokenKey = 'access_token';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> readToken() => _storage.read(key: _kTokenKey);

  Future<void> persistToken(String token) => _storage.write(key: _kTokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _kTokenKey);

  Future<void> register({required String email, required String password}) async {
    try {
      await _dio.safePost(
        '/auth/register',
        data: {'email': email, 'password': password},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> login({required String email, required String password}) async {
    try {
      final res = await _dio.safePost(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final token = res.data?['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw ApiException('Invalid login response');
      }
      await persistToken(token);
      return token;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() => clearToken();
}
