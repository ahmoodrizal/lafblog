import 'package:flutter/material.dart';
import 'package:lafblog/models/api_response.dart';
import 'package:lafblog/models/user.dart';
import 'package:lafblog/screens/Home.dart';
import 'package:lafblog/screens/login.dart';
import 'package:lafblog/services/user_service.dart';
import 'package:lafblog/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController nameField = TextEditingController();
  TextEditingController mailField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  TextEditingController passwordConfirmationField = TextEditingController();
  bool loading = false;

  void _registerUser() async {
    ApiResponse response = await register(mailField.text, nameField.text, passwordField.text);
    if (response.error == null) {
      _saveTokenAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = !loading;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${response.error}',
            style: whiteTextStyle,
          ),
        ),
      );
    }
  }

  void _saveTokenAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: formkey,
          child: ListView(
            padding: EdgeInsetsDirectional.all(defaultmargin),
            children: [
              Text(
                'Login',
                style: darkTextStyle.copyWith(
                  fontSize: 26,
                  fontWeight: semibold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Please enter your personal data with full name, email and password, contact the admin if there is a problem.',
                style: darkTextStyle,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                enableSuggestions: false,
                autocorrect: false,
                controller: nameField,
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
                style: darkTextStyle.copyWith(
                  fontSize: 16,
                ),
                showCursor: false,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                  ),
                  label: Text(
                    'Full Name',
                    style: darkTextStyle.copyWith(
                      color: greyColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              TextFormField(
                enableSuggestions: false,
                autocorrect: false,
                controller: mailField,
                validator: (value) => value!.isEmpty ? 'Invalid Email Address' : null,
                keyboardType: TextInputType.emailAddress,
                style: darkTextStyle.copyWith(
                  fontSize: 16,
                ),
                showCursor: false,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                  ),
                  label: Text(
                    'Email Address',
                    style: darkTextStyle.copyWith(
                      color: greyColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              TextFormField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: passwordField,
                validator: (value) => value!.length < 6 ? 'Required min 6 character' : null,
                keyboardType: TextInputType.emailAddress,
                style: darkTextStyle.copyWith(
                  fontSize: 16,
                ),
                showCursor: false,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                  ),
                  label: Text(
                    'Password',
                    style: darkTextStyle.copyWith(
                      color: greyColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              TextFormField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: passwordConfirmationField,
                validator: (value) => value != passwordField.text ? 'Password didn\'t match' : null,
                keyboardType: TextInputType.emailAddress,
                style: darkTextStyle.copyWith(
                  fontSize: 16,
                ),
                showCursor: false,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                  ),
                  label: Text(
                    'Repeat Password',
                    style: darkTextStyle.copyWith(
                      color: greyColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : TextButton(
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
                        if (formkey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                            _registerUser();
                          });
                        }
                      },
                      child: Text(
                        'Register',
                        style: whiteTextStyle.copyWith(
                          fontSize: 16,
                          fontWeight: medium,
                        ),
                      ),
                    ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account ?', style: darkTextStyle),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      // print('redirect to register page');
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                          (route) => false);
                    },
                    child: Text('Login', style: darkTextStyle.copyWith(fontWeight: semibold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
