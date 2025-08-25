import 'package:ama_meet/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:blurrycontainer/blurrycontainer.dart';

class HomeBtnWidget extends StatelessWidget {
  final VoidCallback? onPressedFunction;
  final IconData? btnIcon;
  final String btnText;
  final double height;
  final double width;
  
  const HomeBtnWidget({
    super.key,
    required this.onPressedFunction,
    required this.btnIcon,
    required this.btnText,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressedFunction,
      child: Column(
        children: [
          Stack(
            children: [
              // Base colored layer underneath
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
              // Glass effect using BlurryContainer
              BlurryContainer(
                width: width,
                height: height,
                blur: 10,
                elevation: 0,
                // color: Colors.white.withOpacity(0.2),
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    btnIcon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            btnText,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}