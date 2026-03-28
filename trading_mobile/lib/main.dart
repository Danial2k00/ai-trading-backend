import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'providers/api_config_provider.dart';
import 'theme/theme_mode_provider.dart';
import 'features/auth/application/auth_providers.dart';
import 'features/auth/data/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: _Bootstrap(
        child: const TradingApp(),
      ),
    ),
  );
}

/// Loads secure token + persisted theme before first frame paints.
class _Bootstrap extends ConsumerStatefulWidget {
  const _Bootstrap({required this.child});

  final Widget child;

  @override
  ConsumerState<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends ConsumerState<_Bootstrap> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final repo = ref.read(authRepositoryProvider);
      final token = await repo.readToken();
      if (token != null && token.isNotEmpty) {
        ref.read(authTokenProvider.notifier).state = token;
      }
      await hydrateThemeMode(ref);
      await hydrateApiBaseUrl(ref);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
