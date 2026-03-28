import 'package:flutter_riverpod/flutter_riverpod.dart';

/// JWT access token; null when logged out.
final authTokenProvider = StateProvider<String?>((ref) => null);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authTokenProvider) != null;
});
