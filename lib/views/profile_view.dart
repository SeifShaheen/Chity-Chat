import 'dart:math';

import 'package:chity/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chity/helpers/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  static String id = 'profileId';
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  List<DocumentSnapshot> documents = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      documents = querySnapshot.docs; // Store documents in the list
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> map =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          int post = 0;
          List<DocumentSnapshot> posts = [];
          for (var element in documents) {
            if (element['author'] == map['username']) {
              post++;
              posts.add(element);
            }
          }
          dynamic guest, profile;
          if (snapshot.hasData) {
            int length = snapshot.data!.docs.length;
            for (var i = 0; i < length; i++) {
              if (snapshot.data!.docs[i]['username'] == map['username']) {
                profile = snapshot.data!.docs[i];
              } else if (snapshot.data!.docs[i]['username'] ==
                  map['userUserName']) {
                guest = snapshot.data!.docs[i];
              }
              if (guest != null && profile != null) break;
            }
            return Scaffold(
                appBar: AppBar(
                  actions: [
                    if (Helpers.findById(guest['friends'], map['username']!) !=
                        null)
                      IconButton(
                        icon: const ImageIcon(
                            AssetImage('assets/icons/add-friend-accepted.png'),
                            color: Colors.white),
                        onPressed: () {
                          showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 200,
                                  color: const Color(0xff005073),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Chity-Chat',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25),
                                        ),
                                        CustomButton(
                                          text: 'Unfriend',
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['userUserName']!)
                                                .update({
                                              'friends': FieldValue.arrayRemove(
                                                  [map['username']])
                                            });
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['username']!)
                                                .update({
                                              'friends': FieldValue.arrayRemove(
                                                  [map['userUserName']])
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    if (Helpers.findById(
                            guest['sentRequests'], map['username']!) !=
                        null)
                      IconButton(
                        icon: const ImageIcon(
                            AssetImage('assets/icons/pending.png'),
                            color: Colors.white),
                        onPressed: () {
                          showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 200,
                                  color: const Color(0xff005073),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Chity-Chat',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25),
                                        ),
                                        CustomButton(
                                          text: 'Cancel Friend Request',
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['userUserName']!)
                                                .update({
                                              'sentRequests':
                                                  FieldValue.arrayRemove(
                                                      [map['username']])
                                            });
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['username']!)
                                                .update({
                                              'recivedRequests':
                                                  FieldValue.arrayRemove(
                                                      [map['userUserName']])
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    if (Helpers.findById(
                            guest['recivedRequests'], map['username']!) !=
                        null)
                      IconButton(
                        icon: const ImageIcon(
                            AssetImage('assets/icons/pending.png'),
                            color: Colors.white),
                        onPressed: () {
                          showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 250,
                                  color: const Color(0xff005073),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Chity-Chat',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25),
                                        ),
                                        CustomButton(
                                          text: 'Accept Friend Request',
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['userUserName']!)
                                                .update({
                                              'recivedRequests':
                                                  FieldValue.arrayRemove(
                                                      [map['username']])
                                            });
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['username']!)
                                                .update({
                                              'sentRequests':
                                                  FieldValue.arrayRemove(
                                                      [map['userUserName']])
                                            });
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['userUserName']!)
                                                .update({
                                              'friends': FieldValue.arrayUnion(
                                                  [map['username']])
                                            });
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['username']!)
                                                .update({
                                              'friends': FieldValue.arrayUnion(
                                                  [map['userUserName']])
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CustomButton(
                                          text: 'Cancel Friend Request',
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['userUserName']!)
                                                .update({
                                              'sentRequests':
                                                  FieldValue.arrayRemove(
                                                      [map['username']])
                                            });
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(map['username']!)
                                                .update({
                                              'recivedRequests':
                                                  FieldValue.arrayRemove(
                                                      [map['userUserName']])
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    if (Helpers.findById(
                                guest['recivedRequests'], map['username']!) ==
                            null &&
                        Helpers.findById(
                                guest['sentRequests'], map['username']!) ==
                            null &&
                        Helpers.findById(guest['friends'], map['username']!) ==
                            null)
                      IconButton(
                        icon: const ImageIcon(
                            AssetImage('assets/icons/add-friend.png'),
                            color: Colors.white),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(map['userUserName']!)
                              .update({
                            'sentRequests':
                                FieldValue.arrayUnion([map['username']])
                          });
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(map['username']!)
                              .update({
                            'recivedRequests':
                                FieldValue.arrayUnion([map['userUserName']])
                          });
                          setState(() {});
                        },
                      ),
                  ],
                  backgroundColor: const Color(0xff189ad3),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(
                    '@${map['username']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                backgroundColor: const Color(0xff005073),
                body: ListView.builder(
                    itemCount: max(1, post),
                    itemBuilder: (context, index) {
                      if (post == 0) {
                        return const Center(
                            heightFactor: 15,
                            child: Text(
                              'No Post Here Yet!',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ));
                      } else if (posts[index]['author'] == map['username']) {
                        DateTime postTime = posts[index]['createdAt']
                            .toDate()
                            .subtract(Duration.zero); // Example time
                        String timeAgo = timeago.format(postTime);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${posts[index]['author']}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  timeAgo,
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 17),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  posts[index]['body'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ),
                              const Divider()
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox(
                          height: 0,
                        );
                      }
                    }));
          } else {
            return const Scaffold(
              backgroundColor: Color(0xff005073),
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }
        });
  }
}
