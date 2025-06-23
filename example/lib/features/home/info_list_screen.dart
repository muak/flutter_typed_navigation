import 'package:flutter/material.dart';

class InfoListScreen extends StatelessWidget {
  const InfoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text('お知らせ ${index + 1}'),
          subtitle: const Text('これはダミーのお知らせです。'),
          onTap: () {
            Navigator.of(context).pushNamed('/infoDetail', arguments: index);
          },
        );
      },
    );
  }
} 