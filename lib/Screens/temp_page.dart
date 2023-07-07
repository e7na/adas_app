import 'package:flutter/material.dart';

class tempPage extends StatelessWidget {
  final String text;
  tempPage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}
