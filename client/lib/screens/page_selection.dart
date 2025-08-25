import 'package:ama_meet/screens/account_screen.dart';
import 'package:ama_meet/screens/meeting_screen.dart';
import 'package:ama_meet/screens/note_screen.dart';
import 'package:ama_meet/utils/colors.dart';
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
    const MeetingScreen(),
    const NoteScreen(),
    const AccountScreen(),
    const Text("page"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: pages[_page],
  bottomNavigationBar: SizedBox(
    height: 95,
    child: Padding(
      padding: EdgeInsets.all(10),
      child: StylishBottomBar(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        backgroundColor: const Color(0xFF252525),
        option: BubbleBarOptions(
          // padding: EdgeInsets.symmetric(vertical: 10),
          // opacity: 0.4,
          barStyle: BubbleBarStyle.horizontal,
          bubbleFillStyle: BubbleFillStyle.fill,
        ),
        currentIndex: _page,
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        items: [
          BottomBarItem(
            icon: const Icon(Icons.linked_camera_outlined, color: Colors.grey),
            selectedIcon: const Icon(Icons.linked_camera, color: Colors.white),
            title: const Text('Live Class', style: TextStyle(color: Colors.white)),
            backgroundColor: buttonColor,
          ),
          BottomBarItem(
            icon: const Icon(Icons.note_alt_outlined, color: Colors.grey),
            selectedIcon: const Icon(Icons.note_alt, color: Colors.white),
            title: const Text('Notes', style: TextStyle(color: Colors.white)),
            backgroundColor: buttonColor,
          ),
          BottomBarItem(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            selectedIcon: const Icon(Icons.person, color: Colors.white),
            title: const Text('Account', style: TextStyle(color: Colors.white)),
            backgroundColor: buttonColor,
          ),
          BottomBarItem(
            icon: const Icon(Icons.settings, color: Colors.grey),
            selectedIcon: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            backgroundColor: buttonColor,
          ),
        ],
      ),
    ),
  ),
);

  }
}