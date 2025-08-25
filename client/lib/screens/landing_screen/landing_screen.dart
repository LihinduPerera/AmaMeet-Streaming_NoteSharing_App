import 'dart:ui';

import 'package:ama_meet/screens/forms/sign_in_form.dart';
import 'package:ama_meet/utils/components/animated_btn.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late rive.RiveAnimationController _btnClickAnimationController;
  late rive.RiveAnimationController _btnAnimationController;
  @override
  void initState() {
    _btnAnimationController = rive.SimpleAnimation("Timeline 1");
    _btnClickAnimationController = rive.OneShotAnimation(
      "click",
      autoplay: false,
      onStop: () {
        _btnClickAnimationController.isActive = false;
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              width: MediaQuery.of(context).size.width * 1.7,
              left: 100,
              bottom: 200,
              child: Image.asset("assets/backgrounds/spline.png")),
          rive.RiveAnimation.asset("assets/rive/amameet_background.riv"),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 45,
                sigmaY: 25,
              ),
              child: SizedBox(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  SizedBox(
                    width: 260,
                    child: Column(
                      children: [
                        SizedBox(
                            height: 130,
                            width: 330,
                            child: rive.RiveAnimation.asset(
                                "assets/rive/amameet.riv")),
                        Text(
                          "Connected & Organized",
                          style: TextStyle(
                              fontSize: 40,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w800,
                              height: 1.2),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                            "Join live sessions, share notes, and watch past recordings — all in one place. Simple, fast, and built for your class.")
                      ],
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  AnimatedBtn(
                    btnAnimationController: _btnAnimationController,
                    btnClickAnimationController: _btnClickAnimationController,
                    onPress: () {
                      if (!_btnClickAnimationController.isActive) {
                        _btnClickAnimationController.isActive = true;

                        Future.delayed(
                          Duration(milliseconds: 800),
                          () {
                            customSignInDialog(context);
                          }
                          );
                        
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      "No more missed updates or scattered resources — everything you need is right here.",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Poppins",
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<Object?> customSignInDialog(BuildContext context) {
    return showGeneralDialog(
      barrierDismissible: true, //close when tap outside
      barrierLabel: "Sign In",
      context: context,
      transitionDuration: Duration(milliseconds: 400),

      transitionBuilder: (_, animation, __, child) {
        Tween<Offset> tween;
        tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
        return SlideTransition(position: tween.animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut)
        ),
        child: child,
        );
      },

      pageBuilder: (context, _, __) => Center(
        child: Container(
          height: 560,
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.94),
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                          fontSize: 34,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Sign in to stay connected with your classes and resources",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SignInForm(),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Don't Have An Account?",
                            style: TextStyle(color: Colors.black26),
                          ),
                        ),
                        Expanded(
                          child: Divider(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                      child: Text(
                        "Need an account? Please contact your teacher to receive your login details.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontFamily: "Poppins",
                        ),
                      ),
                    )
                  ],
                ),
                // Still use barrierDismissible = true to close the dialog
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -50,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.black,),
                  ), 
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
