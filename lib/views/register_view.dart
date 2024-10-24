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
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});
  static String id = 'registedId';

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
                        const CustomLabel(text: 'Name'),
                        CustomTextFormField(
                            obSecure: false,
                            hintText: 'Enter Name',
                            onChanged: (value) {
                              name = value;
                            },
                            onEmpty: "Please Enter Name"),
                        const CustomLabel(text: 'Username'),
                        CustomTextFormField(
                            obSecure: false,
                            hintText: 'Enter Username',
                            onChanged: (value) {
                              userName = value;
                            },
                            onEmpty: "Please Enter Username"),
                        const CustomLabel(text: 'Email'),
                        CustomTextFormField(
                            obSecure: false,
                            hintText: 'Enter Email',
                            onChanged: (value) {
                              email = value;
                            },
                            onEmpty: "Please Enter Email"),
                        const CustomLabel(text: 'Password'),
                        CustomTextFormField(
                            obSecure: true,
                            hintText: 'Enter Password',
                            onChanged: (value) {
                              password = value;
                            },
                            onEmpty: "Please Enter Password"),
                        CustomButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              isLoading = true;
                              setState(() {});
                              try {
                                if (checkUsername(userName!)) {
                                  await registerUser();
                                  updateFCMToken(userName!);
                                  Navigator.pushReplacementNamed(
                                      context, HomeView.id,
                                      arguments: email);
                                }
                                isLoading = false;
                                setState(() {});
                              } on FirebaseAuthException catch (e) {
                                showSnackBar(context, e.message!);
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
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email!, password: password!)
        .then((value) {
      FirebaseFirestore.instance.collection("users").doc(userName).set({
        'username': userName,
        'name': name,
        'email': email,
        'sentRequests': [],
        'recivedRequests': [],
        'friends': [],
      });
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
