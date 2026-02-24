// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:chity/views/home_view.dart';
import 'package:chity/widgets/already_have_an_accout.dart';
import 'package:chity/widgets/custom_button.dart';
import 'package:chity/widgets/custom_label.dart';
import 'package:chity/widgets/custom_text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chity/widgets/loading_widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});
  static String id = 'RegisterId';

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? name;
  String? userName;
  List<dynamic> usersMap = [];
  int length = 0;
  bool isLoading = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  dynamic token;
  @override
  void initState() {
    super.initState();
    token = getToken();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        length = snapshot.data!.docs.length;
        usersMap = snapshot.data!.docs;
        return Scaffold(
          backgroundColor: const Color(0xff005073),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              'Register',
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
                        const CustomLabel(text: 'Name'),
                        CustomTextFormField(
                            inputType: InputType.text,
                            hintText: 'Enter Name',
                            onChanged: (value) {
                              name = value;
                            }),
                        const CustomLabel(text: 'Username'),
                        CustomTextFormField(
                            inputType: InputType.text,
                            hintText: 'Enter Username',
                            onChanged: (value) {
                              userName = value;
                            }),
                        const CustomLabel(text: 'Email'),
                        CustomTextFormField(
                            inputType: InputType.email,
                            hintText: 'Enter Email',
                            onChanged: (value) {
                              email = value;
                            }),
                        const CustomLabel(text: 'Password'),
                        CustomTextFormField(
                            inputType: InputType.password,
                            hintText: 'Enter Password',
                            onChanged: (value) {
                              password = value;
                            }),
                        CustomButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              isLoading = true;
                              setState(() {});
                              try {
                                if (checkUsername(userName!)) {
                                  await registerUser();
                                  await updateFCMToken(userName!);
                                  isLoading = false;
                                  setState(() {});
                                  Navigator.pushReplacementNamed(
                                      context, HomeView.id,
                                      arguments: email);
                                } else {
                                  isLoading = false;
                                  setState(() {});
                                }
                              } on FirebaseAuthException catch (e) {
                                String errorMessage =
                                    'Registration failed. Please try again.';

                                switch (e.code) {
                                  case 'weak-password':
                                    errorMessage =
                                        'The password provided is too weak.';
                                    break;
                                  case 'email-already-in-use':
                                    errorMessage =
                                        'An account already exists for this email.';
                                    break;
                                  case 'invalid-email':
                                    errorMessage = 'Invalid email address.';
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
                                if (e
                                        .toString()
                                        .contains('PigeonUserDetails') ||
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
                          text: 'Register',
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: AuthAuthenticationOption(
                      action: 'Login',
                      text: 'Don\'t have an account?',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> registerUser() async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email!, password: password!);

    await FirebaseFirestore.instance.collection("users").doc(userName).set({
      'username': userName,
      'name': name,
      'email': email,
      'sentRequests': [],
      'receivedRequests': [],
      'friends': [],
      'uid': userCredential.user!.uid,
    });
  }

  bool checkUsername(String value) {
    for (int i = 0; i < length; i++) {
      if (usersMap[i]['username'] == value) {
        showSnackBar(context, 'Username Is Taken');
        return false;
      }
    }
    return true;
  }

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  Future<void> updateFCMToken(String userId) async {
    try {
      // Await for the FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        // Use the token after awaiting
        await FirebaseFirestore.instance
            .collection('users') // Your collection name
            .doc(userId) // Document ID for the user
            .set({
          'fcmToken': fcmToken,
        }, SetOptions(merge: true)); // Merge to add or update the token
      } else {
        log("FCM Token is null.");
      }
    } catch (e) {
      log("Error updating FCM token: $e");
    }
  }
}
