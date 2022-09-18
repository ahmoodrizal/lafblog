import 'package:flutter/material.dart';
import 'package:lafblog/theme.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          'Profile Screen',
          style: darkTextStyle,
        ),
      ),
    );
  }
}
