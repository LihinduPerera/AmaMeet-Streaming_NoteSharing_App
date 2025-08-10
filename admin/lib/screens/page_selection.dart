import 'package:ama_meet_admin/screens/admin_dashboard.dart';
import 'package:ama_meet_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class PageSelection extends StatefulWidget {
  const PageSelection({super.key});

  @override
  State<PageSelection> createState() => _PageSelectionState();
}

class _PageSelectionState extends State<PageSelection> {
  int _page = 0;

  final List<Widget> pages = [
    AdminDashboard(),
    Center(child: Text("Page2")),
    Center(child: Text("Page3")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeeedf2),
      body: pages[_page],
      bottomNavigationBar: StylishBottomBar(
        option: BubbleBarOptions(
          barStyle: BubbleBarStyle.horizontal,
          bubbleFillStyle: BubbleFillStyle.fill,
          opacity: 0.3,
        ),
        currentIndex: _page,
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        // iconSpace: 12.0,
        items: [
          BottomBarItem(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: const Icon(Icons.admin_panel_settings),
            title: const Text('Dashboard'),
            backgroundColor: buttonColor,

            // selectedColor: Colors.pink,
            // badge: const Text('1+'),
            // badgeColor: Colors.red,
            // showBadge: true,
          ),
          BottomBarItem(
            icon: const Icon(Icons.note_alt_outlined),
            selectedIcon: const Icon(Icons.note_alt),
            title: const Text('Notes'),
            backgroundColor: buttonColor,
          ),
          BottomBarItem(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            title: const Text('Account'),
            backgroundColor: buttonColor,
          ),
        ],
      ),
    );
  }
}