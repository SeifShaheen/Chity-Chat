import 'package:flutter/material.dart';

class CustomLabel extends StatelessWidget {
  const CustomLabel({
    super.key,
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
        )),
      ],
    );
  }
}
