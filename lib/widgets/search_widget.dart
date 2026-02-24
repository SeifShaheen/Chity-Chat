import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                child: Text(
                  " @$username",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
