import 'package:flutter/material.dart';
import 'beranda_screen.dart';
import 'expense_list_screen.dart'; 
import 'add_expense_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Daftar layar berdasarkan urutan navigasi bawah
  final List<Widget> _screens = [
    const BerandaScreen(),
    const ExpenseListScreen(), 
    const Center(child: Text('Halaman Anggaran\n(Tempat kerja Nasywa besok)', textAlign: TextAlign.center)),
    const Center(child: Text('Halaman Profil\n(Tempat kerja Lyvia besok)', textAlign: TextAlign.center)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // Tombol tambah muncul kecuali di tab Profil (Index 3)
      floatingActionButton: _selectedIndex != 3 
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2563EB),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
                );
                // UniqueKey() memaksa Flutter untuk menghapus memori layar lama 
                // dan memuat ulang (refresh) data terbaru dari SQLite
                setState(() {
                  _screens[0] = BerandaScreen(key: UniqueKey());
                  _screens[1] = ExpenseListScreen(key: UniqueKey());
                });
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Anggaran'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}