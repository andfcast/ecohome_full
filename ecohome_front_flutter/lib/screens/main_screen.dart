import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'chat_screen.dart';

class MainScreen extends StatefulWidget {
  final String currentUserEmail;
  final VoidCallback onLogout;

  const MainScreen({
    super.key,
    required this.currentUserEmail,
    required this.onLogout,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Usamos IndexedStack para conservar el estado de Socket.IO del chat
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CatalogScreen(
            currentUserEmail: widget.currentUserEmail,
            onLogout: widget.onLogout,
          ),
          ChatScreen(
            currentUserEmail: widget.currentUserEmail,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}