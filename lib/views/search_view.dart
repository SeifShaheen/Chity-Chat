// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:chity/constants/app_colors.dart';
import 'package:chity/views/profile_view.dart';
import 'package:chity/widgets/search_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});
  static String id = "SearchId";

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = "";
  @override
  Widget build(BuildContext context) {
    String username = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff189ad3),
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: const Color(0xff005073),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textDark),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                hintText: 'Search by username',
                hintStyle: const TextStyle(color: AppColors.textDarkSecondary),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.iconWhite,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchText = "";
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (searchText.isEmpty)
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .where('username', isNotEqualTo: username)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('users')
                      .where('username', isGreaterThanOrEqualTo: searchText)
                      .where('username',
                          isLessThanOrEqualTo: '$searchText\uf8ff')
                      .where('username', isNotEqualTo: username)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.white,
                  ));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    'No users found',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ));
                }
                var users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: min(users.length, 10),
                  itemBuilder: (context, index) {
                    var user = users[index].data() as Map<String, dynamic>;
                    Map<String, String> map = {
                      'username': snapshot.data!.docs[index]['username'],
                      'email': snapshot.data!.docs[index]['email'],
                      'name': snapshot.data!.docs[index]['name'],
                      'userEmail': FirebaseAuth.instance.currentUser!.email!,
                      'userUserName': username,
                    };
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, ProfileView.id,
                            arguments: map);
                      },
                      child: SearchWidget(
                          map: {
                            'username': snapshot.data!.docs[index]['username'],
                            'email': snapshot.data!.docs[index]['email'],
                            'name': snapshot.data!.docs[index]['name'],
                            'userEmail':
                                FirebaseAuth.instance.currentUser!.email!,
                            'userUserName': username,
                          },
                          name: user['name']!,
                          email: user['email']!,
                          username: user['username']!),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
