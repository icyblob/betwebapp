import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:http/http.dart' as http;

class JoinBetDialog extends StatefulWidget {
  final int bet_id;
  final int option_id;
  final int max_slot_per_option;
  final String creatorId;
  final String userId;

  const JoinBetDialog({super.key,
    required this.bet_id,
    required this.option_id,
    required this.max_slot_per_option,
    required this.creatorId,
    required this.userId,
  });

  @override
  _JoinBetDialogState createState() => _JoinBetDialogState();
}

class _JoinBetDialogState extends State<JoinBetDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numSlotsController = TextEditingController();
  final TextEditingController _amountPerSlotController = TextEditingController();
  bool _isJoinButtonEnabled = false;

  void _updateJoinButtonState() {
    setState(() {
      _isJoinButtonEnabled = _numSlotsController.text.isNotEmpty && _amountPerSlotController.text.isNotEmpty;
    });
  }

  void _joinBet() async {
    // Prompt for password
    final password = await _promptForPassword();
    if (password == null) {
      return;
    }

    // Decrypt the seed
    final decryptedSeed = await _decryptSeed(password);
    if (decryptedSeed == null) {
      _showErrorDialog('Incorrect password');
      return;
    }

    // Prepare join bet data
    final data = {
      'bet_id': widget.bet_id,
      'user_id': widget.userId,
      'option_id': widget.option_id,
      'num_slots': int.parse(_numSlotsController.text),
      'amount_per_slot': double.parse(_amountPerSlotController.text),
      'seed': decryptedSeed,
    };

    final response = await http.post(
      Uri.parse('http://192.168.1.211:5000/join_bet'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    final responseJson = json.decode(response.body);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(response.statusCode == 201 ? 'Success' : 'Failed'),
          content: Text(responseJson['message'] ?? responseJson['error']),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (response.statusCode == 201) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _promptForPassword() async {
    String? password;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final _passwordController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                password = _passwordController.text;
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return password;
  }

  // Generate a key from a password
  encrypt.Key deriveKeyFromPassword(String password) {
    final keyBytes = utf8.encode(password.padRight(32, '*').substring(0, 32));
    return encrypt.Key(keyBytes);
  }

  Future<String?> _decryptSeed(String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('password')) {
      return null;
    }

    final encryptedSeed = prefs.getString('ss_ecrpt');
    if (encryptedSeed == null) {
      return null;
    }

    final key = deriveKeyFromPassword(password);
    final encryptedBytes = base64.decode(encryptedSeed);

    final iv = encrypt.IV(encryptedBytes.sublist(0, 16));
    final encrypted = encrypt.Encrypted(encryptedBytes.sublist(16));
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final seed = encrypter.decrypt(encrypted, iv: iv);
    return seed;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Join Bet',
        style: TextStyle(fontSize: 20.0),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _numSlotsController,
              decoration: InputDecoration(
                labelText: 'Number of Bet Slots',
                hintText: 'Enter number of bet slots (max: ${widget.max_slot_per_option})',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateJoinButtonState(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number of bet slots';
                }
                final numSlots = int.tryParse(value);
                if (numSlots == null || numSlots > widget.max_slot_per_option) {
                  return 'Max number of bet slots is ${widget.max_slot_per_option}';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _amountPerSlotController,
              decoration: const InputDecoration(
                labelText: 'Amount Per Bet Slot',
                hintText: 'Enter amount per bet slot',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateJoinButtonState(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the amount per bet slot';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Invalid amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _isJoinButtonEnabled
              ? () {
            if (_formKey.currentState?.validate() ?? false) {
              _joinBet();
            }
          }
              : null,
          child: Text(
            'Join',
            style: TextStyle(color: _isJoinButtonEnabled ? Colors.blue : Colors.grey),
          ),
        ),
      ],
    );
  }
}
