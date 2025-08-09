import 'package:ama_meet/controllers/jitsi_meet_controller.dart';
import 'package:ama_meet/widgets/home_btn_widget.dart';
import 'package:flutter/material.dart';

class Meetingpage extends StatelessWidget {
  const Meetingpage({super.key});

  @override
  Widget build(BuildContext context) {
    final JitsiMeetController _jmc = JitsiMeetController();

    return Scaffold(
      backgroundColor: const Color(0xFFeeedf2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFeeedf2),
        elevation: 0,
        title: const Text("Join to the Class"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HomeBtnWidget(
                onPressedFunction: () {
                  _jmc.joinMeeting(
                    'amameet123ama',
                    'User Name',
                    'user@example.com',
                  );
                },
                btnText: 'New Meeting',
                btnIcon: Icons.videocam,
                height: 60,
                width: 60,
              ),
              HomeBtnWidget(
                // onPressedFunction: () => joinMeeting(context) ,
                onPressedFunction: () {},
                btnText: 'Join Meeting',
                btnIcon: Icons.add_box_rounded,
                height: 60,
                width: 60,
              ),
              HomeBtnWidget(
                onPressedFunction: () {},
                btnText: 'Shedule',
                btnIcon: Icons.calendar_today,
                height: 60,
                width: 60,
              ),
            ],
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Join to the class",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}