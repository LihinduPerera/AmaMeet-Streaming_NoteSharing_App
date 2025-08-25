import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class AnimatedBtn extends StatelessWidget {
  const AnimatedBtn({
    super.key,
    required rive.RiveAnimationController btnAnimationController, required rive.RiveAnimationController btnClickAnimationController, required this.onPress,
  }) : _btnAnimationController = btnAnimationController , _btnClickAnimationController = btnClickAnimationController;

  final rive.RiveAnimationController _btnClickAnimationController;
  final rive.RiveAnimationController _btnAnimationController;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: SizedBox(
        height: 150,
        width: 260,
        child: Stack(
          children: [
            rive.RiveAnimation.asset("assets/rive/bird_button.riv",
            controllers: [_btnAnimationController, _btnClickAnimationController],
            ),
            Positioned.fill(
              top: 29,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 33,),
                  Icon(CupertinoIcons.arrow_right, color: Colors.white,),
                  SizedBox(width: 8,),
                  Text("Click to Start",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white
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
