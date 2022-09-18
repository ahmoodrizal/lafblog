import 'package:flutter/material.dart';
import 'package:lafblog/screens/login.dart';
import 'package:lafblog/screens/post_form.dart';
import 'package:lafblog/screens/posts.dart';
import 'package:lafblog/screens/profile.dart';
import 'package:lafblog/services/user_service.dart';
import 'package:lafblog/theme.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Dummy Blog App',
          style: whiteTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                  (route) => false));
            },
            icon: Icon(
              Icons.exit_to_app_rounded,
              color: whiteColor,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PostForm(
              title: 'Create New Post',
            ),
          ));
        },
        child: Icon(
          Icons.add,
          color: whiteColor,
        ),
      ),
      body: currentIndex == 0 ? Posts() : Profile(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: const CircularNotchedRectangle(),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          backgroundColor: whiteColor,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_rounded,
                  color: currentIndex == 0 ? primaryColor : greyColor,
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_rounded,
                  color: currentIndex == 1 ? primaryColor : greyColor,
                ),
                label: ''),
          ],
        ),
      ),
    );
  }
}
