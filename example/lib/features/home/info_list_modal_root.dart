import 'package:flutter/material.dart';
import 'info_list_screen.dart';
import 'info_detail_screen.dart';

class InfoListModalRoot extends StatefulWidget {
  const InfoListModalRoot({super.key});

  @override
  State<InfoListModalRoot> createState() => _InfoListModalRootState();
}

class _InfoListModalRootState extends State<InfoListModalRoot> {
  final GlobalKey<NavigatorState> _modalNavKey = GlobalKey<NavigatorState>();
  String _currentRouteName = '/infoList';
  late final NavigatorObserver _observer;

  @override
  void initState() {
    super.initState();
    _observer = _ModalNavObserver(onStackChanged: _updateCanPop);
  }

  void _updateCanPop() {
    // ここでは何もしない（canPop判定は使わない）
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _currentRouteName != '/infoList'
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _modalNavKey.currentState?.maybePop(),
              )
            : const SizedBox.shrink(),
        title: const Text('お知らせ一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Navigator(
        key: _modalNavKey,
        observers: [_observer],
        initialRoute: '/infoList',
        onGenerateRoute: (settings) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _currentRouteName != settings.name) {
              setState(() {
                _currentRouteName = settings.name ?? '/infoList';
              });
            }
          });
          switch (settings.name) {
            case '/infoList':
              return MaterialPageRoute(
                builder: (_) => const InfoListScreen(),
                settings: settings,
              );
            case '/infoDetail':
              final int index = settings.arguments as int;
              return MaterialPageRoute(
                builder: (_) => InfoDetailScreen(index: index),
                settings: settings,
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const InfoListScreen(),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}

class _ModalNavObserver extends NavigatorObserver {
  final VoidCallback onStackChanged;
  _ModalNavObserver({required this.onStackChanged});

  @override
  void didPop(Route route, Route? previousRoute) {
    onStackChanged();
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    onStackChanged();
    super.didPush(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    onStackChanged();
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    onStackChanged();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
} 