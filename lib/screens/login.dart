import 'package:flutter/material.dart';
import 'package:lafblog/models/api_response.dart';
import 'package:lafblog/models/user.dart';
import 'package:lafblog/screens/Home.dart';
import 'package:lafblog/screens/register.dart';
import 'package:lafblog/services/user_service.dart';
import 'package:lafblog/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController mailField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(mailField.text, passwordField.text);
    // success login and fetching API
    if (response.error == null) {
      _saveTokenAndRedirectToHome(response.data as User);
    } else {
      // error
      setState(() {
        loading = false;
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
    await pref.setInt('user_id', user.id ?? 0);

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
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
                'Please enter your personal data with email and password, contact the admin if there is a problem.',
                style: darkTextStyle,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 30,
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
              loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
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
                            _loginUser();
                          });
                        }
                      },
                      child: Text(
                        'Login',
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
                  Text('Doesn\'t have an account ?', style: darkTextStyle),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      // print('redirect to register page');
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                          (route) => false);
                    },
                    child: Text('Register', style: darkTextStyle.copyWith(fontWeight: semibold)),
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
