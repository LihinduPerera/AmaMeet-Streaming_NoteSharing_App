import 'package:ama_meet/utils/colors.dart';
import 'package:flutter/material.dart';

class HomeBtnWidget extends StatelessWidget {
  final VoidCallback? onPressedFunction;
  final IconData? btnIcon;
  final String btnText;
  final double height;
  final double width;
  const HomeBtnWidget({super.key,
    required this.onPressedFunction,
    required this.btnIcon,
    required this.btnText,
    required this.height,
    required this.width,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressedFunction,
      child: Column(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.6),
                  offset: const Offset(0, 4)
                )
              ]
            ),

            child: Icon(btnIcon, color: Colors.white, size: 30,),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            btnText,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10
            ),
          )
        ],
      ),
    );
  }
}