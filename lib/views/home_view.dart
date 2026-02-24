// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:chity/helpers/helpers.dart';
import 'package:chity/views/chat_view.dart';
import 'package:chity/views/login_view.dart';
import 'package:chity/views/my_profile_view.dart';
import 'package:chity/views/request_view.dart';
import 'package:chity/views/search_view.dart';
import 'package:chity/widgets/custom_button.dart';
import 'package:chity/widgets/user_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  static String id = 'homeId';
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

SharedPreferences? prefs;

class _HomeViewState extends State<HomeView> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  String name = "";
  @override
  void initState() {
    getPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int friendsCount = 0;
    bool flag = false;
    dynamic userProfile;
    String userUserName = "";
    String email = ModalRoute.of(context)!.settings.arguments as String;
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            if (snapshot.data!.docs[i]['email'] == email) {
              userProfile = snapshot.data!.docs[i];
              name = snapshot.data!.docs[i]['name'];
              userUserName = snapshot.data!.docs[i]['username'];
              friendsCount = snapshot.data!.docs[i]['friends'].length;
              break;
            }
          }
          if (friendsCount == 0) {
            flag = true;
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              backgroundColor: Color(0xff005073),
              body: Center(child: CircularProgressIndicator()));
        } else {
          return Scaffold(
            backgroundColor: const Color(0xff005073),
            appBar: AppBar(
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RequestView.id,
                        arguments: userProfile);
                  },
                  child: Stack(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pushNamed(context, RequestView.id,
                              arguments: userProfile);
                        },
                      ),
                      Positioned(
                          right: 10,
                          top: 6,
                          child: userProfile['receivedRequests'].isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    userProfile['receivedRequests'].isEmpty
                                        ? ''
                                        : userProfile['receivedRequests']
                                            .length
                                            .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : const SizedBox(
                                  height: 0,
                                )),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, SearchView.id,
                        arguments: userUserName);
                  },
                )
              ],
              leading: IconButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 250,
                          color: const Color(0xff005073),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Chity-Chat',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                ),
                                CustomButton(
                                  text: 'My Profile',
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, MyProfileView.id,
                                        arguments: userUserName);
                                  },
                                ),
                                CustomButton(
                                  text: 'Signout',
                                  onPressed: () {
                                    signOut();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color(0xff189ad3),
              title: const Text(
                'Chity-Chat',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome, $name",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (flag)
                        const Text(
                          "Friends (0)",
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      if (!flag)
                        Text(
                          "Friends ($friendsCount)",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 24),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: flag ? 1 : snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      if (!flag) {
                        if (Helpers.findById(userProfile['friends'],
                                snapshot.data!.docs[index]['username']) !=
                            null) {
                          return GestureDetector(
                            onTap: () {
                              Map<String, String> map = {
                                'username': snapshot.data!.docs[index]
                                    ['username'],
                                'email': snapshot.data!.docs[index]['email'],
                                'name': snapshot.data!.docs[index]['name'],
                                'userEmail': email,
                                'userUserName': userUserName,
                              };
                              Navigator.pushNamed(context, ChatView.id,
                                  arguments: map);
                              setState(() {});
                            },
                            child: UserChat(
                              map: {
                                'username': snapshot.data!.docs[index]
                                    ['username'],
                                'email': snapshot.data!.docs[index]['email'],
                                'name': snapshot.data!.docs[index]['name'],
                                'userEmail': email,
                                'userUserName': userUserName,
                              },
                              name: snapshot.data!.docs[index]['name'],
                              username: snapshot.data!.docs[index]['username'],
                              email: snapshot.data!.docs[index]['email'],
                            ),
                          );
                        } else {
                          return const SizedBox(
                            height: 0,
                          );
                        }
                      } else {
                        return const Center(
                            child: Text('You Haves No Friends',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)));
                      }
                    },
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('rememberMe');
    prefs.remove('userEmail');
    Navigator.of(context)
        .pushNamedAndRemoveUntil(LoginView.id, (Route<dynamic> route) => false);
  }
}

Future<SharedPreferences> getPref() async {
  prefs = await SharedPreferences.getInstance();
  return prefs!;
}
