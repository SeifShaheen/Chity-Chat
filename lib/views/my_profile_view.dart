import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});
  static String id = 'MyProfileId';
  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String username = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        backgroundColor: const Color(0xff005073),
        appBar: AppBar(
          backgroundColor: const Color(0xff189ad3),
          leading: IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '@$username',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: textController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.post_add_sharp),
                          onPressed: () {
                            if (textController.text.isNotEmpty) {
                              FirebaseFirestore.instance
                                  .collection("posts")
                                  .doc()
                                  .set({
                                'createdAt': DateTime.now(),
                                'author': username,
                                'body': textController.text,
                                'likes': [],
                                'comments': [],
                              });
                              textController.clear();
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        hintText: 'What is going inside your mind?',
                        hintStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: max(snapshot.data!.docs.length, 1),
                      itemBuilder: (context, index) {
                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(
                            heightFactor: 15,
                            child: Text(
                              'No Posts Here Yet!',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                          );
                        } else {
                          if (snapshot.data!.docs[index]['author'] ==
                              username) {
                            DateTime postTime = snapshot
                                .data!.docs[index]['createdAt']
                                .toDate()
                                .subtract(Duration.zero); // Example time
                            String timeAgo = timeago.format(postTime);
                            return Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xff005073),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '@${snapshot.data!.docs[index]['author']}',
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
                                      snapshot.data!.docs[index]['body'],
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
                        }
                      },
                    ),
                  )
                ],
              );
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
          },
        ));
  }
}
