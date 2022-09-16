import 'package:flutter/material.dart';
import 'package:lafblog/screens/login.dart';
import 'package:lafblog/services/user_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          onTap: (() {
            logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => Login(),
                ),
                (route) => false));
          }),
          child: Text('HomePage - Logout'),
        ),
      ),
    );
  }
}
