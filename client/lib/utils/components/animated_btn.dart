import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class AnimatedBtn extends StatelessWidget {
  const AnimatedBtn({
    super.key,
    required rive.RiveAnimationController btnAnimationController, required this.onPress,
  }) : _btnAnimationController = btnAnimationController;

  final rive.RiveAnimationController _btnAnimationController;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: SizedBox(
        height: 64,
        width: 260,
        child: Stack(
          children: [
            rive.RiveAnimation.asset("assets/rive/button.riv",
            controllers: [_btnAnimationController],
            ),
            Positioned.fill(
              top: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.arrow_right),
                  SizedBox(width: 8,),
                  Text("Click to Start",
                  style: TextStyle(
                    fontWeight: FontWeight.w600
                  ),),
                ],
              ),
            )
          ],
        ) 
        ),
    );
  }
}
