import 'package:flutter/material.dart';

import 'cards_icon_icons.dart';

class TitleWidget extends StatelessWidget {
  String? title;

  TitleWidget({this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: const [
              Icon(CardsIcon.spade, color: Colors.black, size: 20),
              Icon(CardsIcon.heart, color: Colors.red, size: 20),
            ],
          ),
          Text(
            title ?? '',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                color: Colors.black),
          ),
          Column(
            children: const [
              Icon(CardsIcon.diamond, color: Colors.red, size: 20),
              Icon(CardsIcon.club, color: Colors.black, size: 20),
            ],
          )
        ],
      ),
    );
  }
}
