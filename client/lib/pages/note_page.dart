import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeeedf2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFeeedf2),
        elevation: 0,
        title: const Text("Notes"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              
            ],
          )
        ],
      ),
    );
  }
}