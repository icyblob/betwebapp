import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'bet_home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _seedController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('ss_ecrpt')) {
      setState(() {
        _isFirstTime = false;
      });
    }
  }

  Future<void> _saveSeed(String seed, String password) async {
    final prefs = await SharedPreferences.getInstance();
    var key = utf8.encode(password);
    var bytes = utf8.encode(seed);

    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);

    await prefs.setString('ss_ecrpt', digest.toString());
    await prefs.setString('password', password);
  }

  Future<bool> _checkPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('password')) return false;
    return prefs.getString('password') == password;
  }

  void _login() async {
    if (_isFirstTime) {
      if (_seedController.text.length == 55 && _seedController.text == _seedController.text.toLowerCase()) {
        _saveSeed(_seedController.text, _passwordController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BetHomePage()),
        );
      } else {
        _showError("Seed must consist of 55 lowercase characters.");
      }
    } else {
      if (await _checkPassword(_passwordController.text)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BetHomePage()),
        );
      } else {
        _showError("Incorrect password.");
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isFirstTime)
              TextField(
                controller: _seedController,
                decoration: InputDecoration(labelText: "Seed"),
                obscureText: true,
              ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
