import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavScreen extends StatefulWidget {
  final Widget child;
  const BottomNavScreen({super.key, required this.child});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  static const List<String> _routes = ['/map', '/community', '/mypage'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    setState(() {
      if (location.startsWith('/community')) {
        _selectedIndex = 1;
      } else if (location.startsWith('/mypage')) {
        _selectedIndex = 2;
      } else {
        _selectedIndex = 0;
      }
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(child: widget.child),
              BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: '지도'),
                  BottomNavigationBarItem(icon: Icon(Icons.sports_kabaddi_outlined), label: '커뮤니티'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '마이'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}