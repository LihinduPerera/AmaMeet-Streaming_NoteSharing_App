import 'dart:ui';

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
    _btnAnimationController = rive.SimpleAnimation(
      "Timeline 1"
    );
    _btnClickAnimationController = rive.OneShotAnimation(
      "click",
      autoplay: false,
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
              child: Image.asset("assets/backgrounds/spline.png")
              ),
          
          rive.RiveAnimation.asset("assets/rive/shapes.riv"),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 30,
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
                          child: rive.RiveAnimation.asset("assets/rive/amameet.riv")
                          ),
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
                  const Spacer(flex: 2,),
                  AnimatedBtn(
                    btnAnimationController: _btnAnimationController,
                    btnClickAnimationController: _btnClickAnimationController,
                    onPress: () {
                      _btnClickAnimationController.isActive = true;
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
}
