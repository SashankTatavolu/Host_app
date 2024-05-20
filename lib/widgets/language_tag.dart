import 'package:flutter/material.dart';

class LanguageTag extends StatelessWidget {
  final String language;

  const LanguageTag({Key? key, required this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 1,),
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
