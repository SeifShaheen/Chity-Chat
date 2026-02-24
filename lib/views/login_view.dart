// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:chity/views/home_view.dart';
import 'package:chity/views/register_view.dart';
import 'package:chity/widgets/already_have_an_accout.dart';
import 'package:chity/widgets/custom_button.dart';
import 'package:chity/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chity/widgets/loading_widget.dart';
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
      body: LoadingOverlay(
        isLoading: isLoading,
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
                        inputType: InputType.email,
                        hintText: 'Enter Email',
                        onChanged: (value) {
                          email = value;
                        }),
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
                        inputType: InputType.password,
                        hintText: 'Enter Password',
                        onChanged: (value) {
                          password = value;
                        }),
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
                            String errorMessage =
                                'Login failed. Please try again.';

                            switch (e.code) {
                              case 'user-not-found':
                                errorMessage = 'No user found for that email.';
                                break;
                              case 'wrong-password':
                                errorMessage = 'Wrong password provided.';
                                break;
                              case 'invalid-email':
                                errorMessage = 'Invalid email address.';
                                break;
                              case 'user-disabled':
                                errorMessage =
                                    'This user account has been disabled.';
                                break;
                              case 'too-many-requests':
                                errorMessage =
                                    'Too many requests. Please try again later.';
                                break;
                              case 'operation-not-allowed':
                                errorMessage =
                                    'Email/password accounts are not enabled.';
                                break;
                            }

                            showSnackBar(context, errorMessage);
                            log('Firebase Auth Error: ${e.code} - ${e.message}');
                            isLoading = false;
                            setState(() {});
                          } catch (e) {
                            String errorMessage =
                                'An unexpected error occurred. Please try again.';

                            // Handle specific Firebase Auth type casting errors
                            if (e.toString().contains('PigeonUserDetails') ||
                                e.toString().contains(
                                    'type \'List<Object?>\' is not a subtype')) {
                              errorMessage =
                                  'Authentication service is temporarily unavailable. Please try again.';
                            }

                            showSnackBar(context, errorMessage);
                            isLoading = false;
                            setState(() {});
                            log('Unexpected error: $e');
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
