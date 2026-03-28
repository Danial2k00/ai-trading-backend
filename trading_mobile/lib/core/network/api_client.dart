import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/api_config_provider.dart';
import 'api_exception.dart';

String _normalizeBase(String raw) {
  var s = raw.trim();
  if (s.endsWith('/')) s = s.substring(0, s.length - 1);
  return s;
}

final dioProvider = Provider<Dio>((ref) {
  final base = _normalizeBase(ref.watch(apiBaseUrlProvider));
  return Dio(
    BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );
});

extension DioApi on Dio {
  Future<Response<dynamic>> safeGet(
    String path, {
    Map<String, dynamic>? query,
    String? token,
    Options? options,
  }) async {
    try {
      final headers = <String, dynamic>{...(options?.headers ?? {})};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      return await get(
        path,
        queryParameters: query,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Response<dynamic>> safePost(
    String path, {
    Object? data,
    String? token,
    Options? options,
  }) async {
    try {
      final headers = <String, dynamic>{...(options?.headers ?? {})};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      return await post(
        path,
        data: data,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }
}

ApiException _mapDio(DioException e) {
  final code = e.response?.statusCode;
  final data = e.response?.data;
  String msg = e.message ?? 'Network error';
  if (data is Map && data['detail'] != null) {
    final d = data['detail'];
    if (d is String) {
      msg = d;
    } else if (d is List && d.isNotEmpty && d.first is Map && d.first['msg'] != null) {
      msg = d.first['msg'].toString();
    }
  }
  return ApiException(msg, statusCode: code);
}
