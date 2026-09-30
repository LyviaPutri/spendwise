import 'package:flutter/material.dart';
import '../models/item.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as Item;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${item.id}', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
            const Divider(height: 32),
            Text('Keterangan:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(item.subtitle, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}