// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:chity/views/home_view.dart';
import 'package:chity/views/register_view.dart';
import 'package:chity/widgets/already_have_an_accout.dart';
import 'package:chity/widgets/custom_button.dart';
import 'package:chity/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  static String id = 'LoginId';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool isLoading = false;
  bool _rememberMe = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff005073),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff189ad3),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Center(
          child: ListView(
            children: [
              Form(
                key: _formKey,
                autovalidateMode: _autoValidateMode,
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Center(
                            child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Email',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        )),
                      ],
                    ),
                    CustomTextFormField(
                        obSecure: false,
                        hintText: 'Enter Email',
                        onChanged: (value) {
                          email = value;
                        },
                        onEmpty: "Please Enter Email"),
                    const Row(
                      children: [
                        Center(
                            child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Password',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        )),
                      ],
                    ),
                    CustomTextFormField(
                        obSecure: true,
                        hintText: 'Enter Password',
                        onChanged: (value) {
                          password = value;
                        },
                        onEmpty: "Please Enter Password"),
                    Row(
                      children: [
                        Checkbox(
                            checkColor: const Color(0xff189ad3),
                            activeColor: Colors.white,
                            value: _rememberMe,
                            onChanged: (bool? va) {
                              setState(() {
                                _rememberMe = va!;
                              });
                            }),
                        const Text(
                          'Keep Me Logged In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    CustomButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_rememberMe) {}
                          isLoading = true;
                          setState(() {});
                          try {
                            await loginUser();
                            isLoading = false;
                            setState(() {});
                            Navigator.pushReplacementNamed(context, HomeView.id,
                                arguments: email);
                          } on FirebaseAuthException catch (e) {
                            if (e.message ==
                                'The supplied auth credential is incorrect, malformed or has expired.') {
                              showSnackBar(
                                  context, 'No user found for that email.');
                            } else if (e.message ==
                                'We have blocked all requests from this device due to unusual activity. Try again later.') {
                              showSnackBar(context,
                                  'Too many requests please try again later!');
                            }
                            log(e.message!);
                            isLoading = false;
                            setState(() {});
                          } catch (e) {
                            showSnackBar(context,
                                'There was an error please try again later!');
                            isLoading = false;
                            setState(() {});
                            log(e.toString());
                          }
                        } else {
                          isLoading = false;
                          setState(() {
                            _autoValidateMode = AutovalidateMode.always;
                          });
                        }
                      },
                      text: 'Login',
                    )
                  ],
                ),
              ),
              Center(
                child: AuthAuthenticationOption(
                  action: 'Register',
                  text: 'Don\'t have an account?',
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const RegisterView();
                    }));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> loginUser() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email!, password: password!);

    if (_rememberMe) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('rememberMe', true);
      prefs.setString('userEmail', email!);
    }
  }
}
