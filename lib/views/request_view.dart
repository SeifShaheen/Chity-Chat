import 'package:chity/helpers/helpers.dart';
import 'package:chity/widgets/friend_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestView extends StatefulWidget {
  const RequestView({super.key});
  static String id = 'RequestId';
  @override
  State<RequestView> createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> {
  @override
  Widget build(BuildContext context) {
    // Get the username from the ModalRoute arguments
    final dynamic username =
        ModalRoute.of(context)!.settings.arguments as dynamic;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(username['username'])
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xff005073),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        var userProfile = userSnapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: const Color(0xff005073),
          appBar: AppBar(
            leading: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: const Color(0xff189ad3),
            title: const Text(
              'Friend Requests',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: userProfile['receivedRequests'].isEmpty
              ? const Center(
                  child: Text('No Recieved Friend Requests',
                      style: TextStyle(color: Colors.white, fontSize: 22)))
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var userData = snapshot.data!.docs[index].data();
                        var requestUsername = userData['username'];

                        if (Helpers.findById(userProfile['receivedRequests'],
                                requestUsername) !=
                            null) {
                          return FriendRequest(
                              userData: userData,
                              requestUsername: requestUsername,
                              userProfile: userProfile);
                        } else {
                          return const SizedBox(height: 0);
                        }
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
