import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/signal_model.dart';

final tradingRepositoryProvider = Provider<TradingRepository>((ref) {
  return TradingRepository(ref.watch(dioProvider));
});

class TradingRepository {
  TradingRepository(this._dio);

  final Dio _dio;

  Future<SignalModel> fetchSignal({required String pair, required String token}) async {
    final res = await _dio.safeGet(
      '/signal',
      query: {'pair': pair},
      token: token,
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) throw Exception('Empty signal response');
    return SignalModel.fromJson(data);
  }

  Future<List<SignalHistoryItem>> fetchHistory({required String token, int skip = 0, int limit = 50}) async {
    final res = await _dio.safeGet(
      '/history',
      query: {'skip': skip, 'limit': limit},
      token: token,
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => SignalHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<String>> fetchWatchlist({required String token}) async {
    final res = await _dio.safeGet('/watchlist', token: token);
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => (e as Map<String, dynamic>)['symbol'] as String).toList();
  }

  Future<void> addWatchlist({required String symbol, required String token}) async {
    await _dio.safePost(
      '/watchlist',
      data: {'symbol': symbol},
      token: token,
    );
  }
}
