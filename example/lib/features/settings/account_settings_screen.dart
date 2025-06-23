import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '..//settings/account_settings_viewmodel.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('AccountSettingsScreen build');
    final state = ref.watch(accountSettingsViewModelProvider);
    final viewModel = ref.read(accountSettingsViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text('アカウント設定')),
      body: Center(child: Text('アカウント設定ページです')),
    );
  }
} 