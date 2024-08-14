import 'package:flutter/material.dart';

class LanguageTag extends StatelessWidget {
  final String language;

  const LanguageTag({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 1,),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.orangeAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(language, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
