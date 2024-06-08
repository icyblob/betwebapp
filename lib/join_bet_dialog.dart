import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

import 'constants.dart';

class JoinBetDialog extends StatefulWidget {
  final int bet_id;
  final int option_id;
  final int max_slot_per_option;

  const JoinBetDialog({
    super.key,
    required this.bet_id,
    required this.option_id,
    required this.max_slot_per_option,
  });

  @override
  _JoinBetDialogState createState() => _JoinBetDialogState();
}

class _JoinBetDialogState extends State<JoinBetDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numSlotsController = TextEditingController();
  final TextEditingController _amountPerSlotController =
      TextEditingController();
  bool _isJoinButtonEnabled = false;

  void _updateJoinButtonState() {
    setState(() {
      _isJoinButtonEnabled = _numSlotsController.text.isNotEmpty &&
          _amountPerSlotController.text.isNotEmpty;
    });
  }

  void _joinBet() async {
    // Prompt for seed
    final seed = await _promptForSeed();
    if (seed == null) {
      return;
    }

    // Prepare join bet data
    final data = {
      'bet_id': widget.bet_id,
      'seed': seed,
      'option_id': widget.option_id,
      'num_slots': int.parse(_numSlotsController.text),
      'amount_per_slot': double.parse(_amountPerSlotController.text),
    };

    final response = await http.post(
      Uri.parse('$DATABASE_SERVER/join_bet'),
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

  Future<String?> _promptForSeed() async {
    String? seed;
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final seedController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            // bool isButtonEnabled = seedController.text.length == 55;
            bool isButtonEnabled = seedController.text.length == 55;
            // Update the button state when the text changes
            seedController.addListener(() {
              setState(() {
                isButtonEnabled = seedController.text.length == 55;
              });
            });
            return AlertDialog(
              title: const Text('Enter Seed'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: seedController,
                    decoration: InputDecoration(
                      labelText: 'Seed',
                      errorText: errorMessage,
                    ),
                    obscureText: true,
                    maxLength: 55,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-z]')),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (seedController.text.length == 55) {
                      seed = seedController.text;
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        errorMessage = 'Seed must be exactly 55 characters';
                      });
                    }
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: isButtonEnabled ? Colors.blueAccent : Colors.grey,
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
    return seed;
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
                hintText:
                    'Enter number of bet slots (max: ${widget.max_slot_per_option})',
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
            style: TextStyle(
                color: _isJoinButtonEnabled ? Colors.blue : Colors.grey),
          ),
        ),
      ],
    );
  }
}