import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

import 'constants.dart';

class JoinBetDialog extends StatefulWidget {
  final int bet_id;
  final int option_id;
  final int max_slot_per_option;
  final int remaining_slots;
  final int amount_per_bet_slot;

  const JoinBetDialog({
    super.key,
    required this.bet_id,
    required this.option_id,
    required this.max_slot_per_option,
    required this.remaining_slots,
    required this.amount_per_bet_slot,
  });

  @override
  _JoinBetDialogState createState() => _JoinBetDialogState();
}

class _JoinBetDialogState extends State<JoinBetDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numSlotsController = TextEditingController();

  bool _isJoinButtonEnabled = false;
  num _totalFees = 0;
  String? _errorTextSlots;

  void _updateJoinButtonState() {
    setState(() {
      _isJoinButtonEnabled =
          _numSlotsController.text.isNotEmpty && _errorTextSlots == null;
    });
  }

  void _validateInputs() {
    setState(() {
      int numSlots = int.tryParse(_numSlotsController.text) ?? 0;
      if (numSlots > widget.remaining_slots) {
        _errorTextSlots = 'Cannot exceed ${widget.remaining_slots} slots';
      } else {
        _errorTextSlots = null;
      }
      _updateJoinButtonState();
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

  num _getTotalFees() {
    if (_numSlotsController.text != '') {
      return widget.amount_per_bet_slot * int.parse(_numSlotsController.text);
    }
    return 0;
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
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
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
                    'Enter number of bet slots (max: ${widget.remaining_slots})',
                errorText: _errorTextSlots,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              onChanged: (value) {
                _validateInputs();
                setState(() {
                  _totalFees = _getTotalFees();
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number of bet slots';
                }
                final numSlots = int.tryParse(value);
                if (numSlots == null || numSlots > widget.remaining_slots) {
                  return 'Max number of bet slots is ${widget.remaining_slots}';
                }
                return null;
              },
            ),
            const SizedBox(height: 15.0),
            Row(children: [
              Text('Amount Per Bet Slot: ${widget.amount_per_bet_slot}',
                  style: const TextStyle(
                    color: Colors.orange,
                  )),
            ]),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Total fees: $_totalFees',
              style: const TextStyle(color: Colors.green),
            )
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
