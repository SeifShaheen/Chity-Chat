import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendRequest extends StatelessWidget {
  const FriendRequest({
    super.key,
    required this.userData,
    required this.requestUsername,
    required this.userProfile,
  });

  final Map<String, dynamic> userData;
  final dynamic requestUsername;
  final Map<String, dynamic> userProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xff71c7ec),
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData['name'],
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  Text(
                    " @$requestUsername",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: () async {
                      // Update Firestore: Accept friend request
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userProfile['username'])
                          .update({
                        'receivedRequests':
                            FieldValue.arrayRemove([requestUsername]),
                        'friends': FieldValue.arrayUnion([requestUsername])
                      });

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(requestUsername)
                          .update({
                        'sentRequests':
                            FieldValue.arrayRemove([userProfile['username']]),
                        'friends':
                            FieldValue.arrayUnion([userProfile['username']])
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.highlight_remove_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: () async {
                      // Update Firestore: Remove friend request
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userProfile['username'])
                          .update({
                        'receivedRequests':
                            FieldValue.arrayRemove([requestUsername])
                      });

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(requestUsername)
                          .update({
                        'sentRequests':
                            FieldValue.arrayRemove([userProfile['username']])
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
