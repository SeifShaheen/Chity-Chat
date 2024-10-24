import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      this.obSecure = false,
      required this.onEmpty,
      required this.hintText,
      required this.onChanged});
  final bool? obSecure;
  final String onEmpty;
  final String hintText;
  final void Function(String?) onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        obscureText: obSecure!,
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return onEmpty;
          }
          return null;
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
