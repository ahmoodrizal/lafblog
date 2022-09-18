import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lafblog/models/api_response.dart';
import 'package:lafblog/models/user.dart';
import 'package:lafblog/screens/login.dart';
import 'package:lafblog/services/config.dart';
import 'package:lafblog/services/user_service.dart';
import 'package:lafblog/theme.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  bool loading = true;
  File? _imageFile;
  final _picker = ImagePicker();
  TextEditingController nameField = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        loading = false;
        nameField.text = user!.name ?? '';
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
          (route) => false));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response.error}'),
        ),
      );
    }
  }

  void updateProfile() async {
    ApiResponse response = await updateUserProfile(nameField.text, getStringImage(_imageFile));
    setState(() {
      loading = false;
    });
    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response.data}'),
        ),
      );
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
          (route) => false));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response.error}'),
        ),
      );
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 40,
                right: 40,
              ),
              child: ListView(
                children: [
                  Center(
                    child: GestureDetector(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          image: _imageFile == null
                              ? user!.profile != null
                                  ? DecorationImage(image: NetworkImage('${user!.profile}'), fit: BoxFit.cover)
                                  : null
                              : DecorationImage(image: FileImage(_imageFile ?? File('')), fit: BoxFit.cover),
                          color: Colors.blueGrey,
                        ),
                      ),
                      onTap: () {
                        getImage();
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      style: darkTextStyle,
                      controller: nameField,
                      enableSuggestions: false,
                      autocorrect: false,
                      showCursor: false,
                      validator: (value) => value!.isEmpty ? 'write something' : null,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryColor,
                          ),
                        ),
                        label: Text(
                          'Name',
                          style: darkTextStyle.copyWith(
                            color: greyColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith((states) => primaryColor),
                      padding: MaterialStateProperty.resolveWith(
                        (states) => const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 30,
                        ),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                      }
                      updateProfile();
                    },
                    child: Text(
                      'Update Personal Data',
                      style: whiteTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
