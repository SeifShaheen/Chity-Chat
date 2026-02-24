import 'package:chity/views/profile_view.dart';
import 'package:flutter/material.dart';

class UserChat extends StatelessWidget {
  const UserChat({
    super.key,
    required this.name,
    required this.email,
    required this.username,
    required this.map,
  });
  final String email;
  final String name;
  final String username;
  final Map<String, String> map;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 70,
        decoration: const BoxDecoration(
            color: Color(0xff71c7ec),
            borderRadius: BorderRadius.all(Radius.circular(9))),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        " @$username",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, ProfileView.id,
                        arguments: map);
                  },
                  icon: const Icon(
                    Icons.info,
                    color: Colors.white,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
