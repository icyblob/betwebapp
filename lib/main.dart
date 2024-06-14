import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bet_home_page.dart';

void main() {
  runApp(QuotteryApp());
}

class QuotteryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue[900], // Dark blue color
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.blue[900], // Dark blue color for accents
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue[900], // Dark blue color for buttons
        ),
      ),
      home: const BetHomePage(),
    );
  }
}
