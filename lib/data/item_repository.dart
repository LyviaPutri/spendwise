import '../models/item.dart';

class ItemRepository {
  Future<List<Item>> getItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Item(
        id: '1',
        title: 'Makan Siang Nasi Padang',
        subtitle: 'Rp 25.000',
        description: 'Pengeluaran makan siang di Ampera',
      ),
      Item(
        id: '2',
        title: 'Top Up Saldo GoPay',
        subtitle: 'Rp 50.000',
        description: 'Pengeluaran transportasi harian',
      ),
      Item(
        id: '3',
        title: 'Beli Buku Catatan Kuliah',
        subtitle: 'Rp 15.000',
        description: 'Pengeluaran perlengkapan kuliah',
      ),
    ];
  }
}