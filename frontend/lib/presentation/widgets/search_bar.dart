import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final Color primaryColor;
  final Color hintTextColor;

  const CustomSearchBar({
    super.key,
    required this.primaryColor,
    required this.hintTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for service...',
          hintStyle: TextStyle(color: hintTextColor, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFB3B3B3)),
          filled: true,
          fillColor: primaryColor.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
