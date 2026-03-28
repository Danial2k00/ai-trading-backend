import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/trading_repository.dart';
import '../features/auth/application/auth_providers.dart';
import '../models/signal_model.dart';

final selectedPairSymbolProvider = StateProvider<String>((ref) => 'BTCUSDT');

final selectedTimeframeProvider = StateProvider<String>((ref) => '1h');

final dashboardSignalProvider = FutureProvider.autoDispose<SignalModel>((ref) async {
  final token = ref.watch(authTokenProvider);
  final pair = ref.watch(selectedPairSymbolProvider);
  if (token == null) throw Exception('Not authenticated');
  return ref.read(tradingRepositoryProvider).fetchSignal(pair: pair, token: token);
});

final signalsHistoryProvider = FutureProvider.autoDispose<List<SignalHistoryItem>>((ref) async {
  final token = ref.watch(authTokenProvider);
  if (token == null) return [];
  return ref.read(tradingRepositoryProvider).fetchHistory(token: token);
});
