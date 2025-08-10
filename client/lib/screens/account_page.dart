import 'package:ama_meet/models/user_model.dart';
import 'package:ama_meet/utils/colors.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  // final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoadng = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // UserModel? user = await _authService.getUserData();
    if(mounted) {
      setState(() {
        // _userModel = user;
        _isLoadng = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeeedf2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFeeedf2),
        elevation: 0,
        title: const Text("Your Account"),
        centerTitle: true,
      ),

      body: _isLoadng
        ? const Center(
          child: CircularProgressIndicator(),
        )
        : _userModel == null
          ? const Center(
            child: Text("No User Data Found !!")
          )
          :Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_userModel!.profilePhoto),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    _userModel!.username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _userModel!.uid,
                    style: const TextStyle(
                      fontSize: 16,
                      color:  Colors.grey
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async{
                      // await _authService.signOut();
                      if(context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.white,),
                    label: const Text("Sign Out", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: buttonColor,
                    )
                  )
                ],
              ),
            ),
          )
    );
  }
}