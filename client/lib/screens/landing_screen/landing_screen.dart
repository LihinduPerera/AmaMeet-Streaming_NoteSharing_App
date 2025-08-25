import 'dart:ui';

import 'package:ama_meet/screens/components/sign_in_form.dart';
import 'package:ama_meet/screens/components/animated_btn.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  bool isSignInDialogShown = false;
  late rive.RiveAnimationController _btnClickAnimationController;
  late rive.RiveAnimationController _btnAnimationController;
  
  // Cache the backdrop filter widget
  Widget? _backdropFilter;
  
  @override
  void initState() {
    super.initState();
    _btnAnimationController = rive.SimpleAnimation("Timeline 1");
    _btnClickAnimationController = rive.OneShotAnimation(
      "click",
      autoplay: false,
      onStop: () {
        if (mounted) {
          _btnClickAnimationController.isActive = false;
        }
      },
    );
    
    // Pre-build the backdrop filter
    _backdropFilter = Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: const SizedBox(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use addPostFrameCallback to avoid blocking the UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage("assets/backgrounds/spline.png"), context);
    });
  }

  @override
  void dispose() {
    _btnAnimationController.dispose();
    _btnClickAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: RepaintBoundary( // Isolate repaints
        child: Stack(
          children: [
            // Background image with reduced overdraw
            _buildBackgroundImage(screenWidth),
            
            // Rive animation with repaint boundary
            RepaintBoundary(
              child: rive.RiveAnimation.asset(
                "assets/rive/amameet_background.riv",
                fit: BoxFit.cover, // Ensure proper fitting
              ),
            ),
            
            // Cached backdrop filter
            if (_backdropFilter != null) _backdropFilter!,
            
            // Main content
            _buildMainContent(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(double screenWidth) {
    return Positioned(
      width: screenWidth * 1.7,
      left: 100,
      bottom: 200,
      child: RepaintBoundary(
        child: Image.asset(
          "assets/backgrounds/spline.png",
          // Add these for better performance
          filterQuality: FilterQuality.low,
          isAntiAlias: false,
        ),
      ),
    );
  }

  Widget _buildMainContent(double screenWidth, double screenHeight) {
    return AnimatedPositioned(
      top: isSignInDialogShown ? -50 : 0,
      duration: const Duration(milliseconds: 240), // Fixed duration
      height: screenHeight,
      width: screenWidth,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              _buildTitleSection(),
              const Spacer(flex: 2),
              _buildAnimatedButton(),
              _buildFooterText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return SizedBox(
      width: 260,
      child: Column(
        children: [
          // Rive animation with repaint boundary and reduced size if possible
          RepaintBoundary(
            child: SizedBox(
              height: 130,
              width: 330,
              child: rive.RiveAnimation.asset(
                "assets/rive/amameet.riv",
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Text(
            "Connected & Organized",
            style: TextStyle(
              fontSize: 40,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Join live sessions, share notes, and watch past recordings — all in one place. Simple, fast, and built for your class.",
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton() {
    return AnimatedBtn(
      btnAnimationController: _btnAnimationController,
      btnClickAnimationController: _btnClickAnimationController,
      onPress: _handleButtonPress,
    );
  }

  void _handleButtonPress() {
    if (!_btnClickAnimationController.isActive && mounted) {
      _btnClickAnimationController.isActive = true;

      // Use shorter delay for better responsiveness
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            isSignInDialogShown = true;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showSignInDialog();
            }
          });
        }
      });
    }
  }

  Widget _buildFooterText() {
    return Padding(
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
    );
  }

  void _showSignInDialog() {
    showGeneralDialog<Object?>(
      barrierDismissible: true,
      barrierLabel: "Sign In",
      context: context,
      transitionDuration: const Duration(milliseconds: 300), // Reduced duration
      transitionBuilder: (_, animation, __, child) {
        // Use more efficient animation
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut, // More efficient curve
          )),
          child: child,
        );
      },
      pageBuilder: (context, _, __) => _buildDialogContent(),
    ).then((value) {
      if (mounted) {
        setState(() {
          isSignInDialogShown = false;
        });
      }
    });
  }

  Widget _buildDialogContent() {
    return Center(
      child: RepaintBoundary(
        child: Container(
          height: 560,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: const BorderRadius.all(Radius.circular(40)),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false, // Prevent layout shifts
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                SingleChildScrollView( // Handle overflow
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 34,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Sign in to stay connected with your classes and resources",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SignInForm(),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Don't Have An Account?",
                              style: TextStyle(color: Colors.black26),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 8, right: 8),
                        child: Text(
                          "Need an account? Please contact your teacher to receive your login details.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: -65,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}