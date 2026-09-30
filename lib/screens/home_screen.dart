import 'package:flutter/material.dart';
import '../data/item_repository.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';
import '../widgets/state_views.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemRepository _repository = ItemRepository();
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureItems = _repository.getItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise - Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.error_outline),
            onPressed: () {
              // Uji rute 404
              Navigator.pushNamed(context, '/halaman-salah');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(message: 'Memuat data SpendWise...');
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: 'Gagal memuat: ${snapshot.error}',
              onRetry: _loadData,
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const EmptyView(message: 'Belum ada transaksi');
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt_long),
                ),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.detail,
                    arguments: item,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.catatanForm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}