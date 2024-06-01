import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(BetApp());
}

class BetApp extends StatelessWidget {
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
      home: LoginPage(),
    );
  }
}
