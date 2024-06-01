import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
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

  // Generate a key from a password
  encrypt.Key deriveKeyFromPassword(String password) {
    final keyBytes = utf8.encode(password.padRight(32, '*').substring(0, 32));
    return encrypt.Key(keyBytes);
  }

  Future<void> _saveSeed(String seed, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final key = deriveKeyFromPassword(password);
    final iv = encrypt.IV.fromLength(16); // Initialization vector
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(seed, iv: iv);
    final hashedSeed = base64.encode(iv.bytes + encrypted.bytes);

    await prefs.setString('ss_ecrpt', hashedSeed);
    await prefs.setString('password', password);

    // Navigate to the home page with the hashed seed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BetHomePage(hashedSeed: hashedSeed)),
    );
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
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
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
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isFirstTime)
              TextField(
                controller: _seedController,
                decoration: const InputDecoration(labelText: "Seed"),
                obscureText: true,
              ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
