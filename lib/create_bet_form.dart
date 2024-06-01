import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'decimal_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;


class CreateBetForm extends StatefulWidget {
  final String creatorId;

  CreateBetForm({required this.creatorId});

  @override
  _CreateBetFormState createState() => _CreateBetFormState();
}

class _CreateBetFormState extends State<CreateBetForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _betDescriptionController = TextEditingController();
  int _numberOfOptions = 2;
  int _numberOfOracles = 1;
  DateTime _closeDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<TextEditingController> _optionControllers = [];
  List<TextEditingController> _oracleIdControllers = [];
  List<TextEditingController> _oracleFeeControllers = [];
  final TextEditingController _numQusPerBetSlotController = TextEditingController();
  final TextEditingController _maxBetSlotsPerOptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeOptionControllers();
    _initializeOracleControllers();
  }

  void _initializeOptionControllers() {
    _optionControllers = List.generate(
      _numberOfOptions,
          (index) => TextEditingController(),
    );
  }

  void _initializeOracleControllers() {
    _oracleIdControllers = List.generate(
      _numberOfOracles,
          (index) => TextEditingController(),
    );
    _oracleFeeControllers = List.generate(
      _numberOfOracles,
          (index) => TextEditingController(),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isCloseDate) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: isCloseDate ? _closeDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ) ?? (isCloseDate ? _closeDate : _endDate);

    if (picked != (isCloseDate ? _closeDate : _endDate)) {
      setState(() {
        if (isCloseDate) {
          _closeDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _createBet() async {
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

    // Prepare bet data
    final data = {
      'no_options': _numberOfOptions,
      'creator': widget.creatorId,
      'bet_desc': _betDescriptionController.text,
      'no_ops': _numberOfOptions,
      'option_desc': _optionControllers.map((controller) => controller.text).toList(),
      'max_slot_per_option': _maxBetSlotsPerOptionController.text,
      'amount_per_bet_slot': _numQusPerBetSlotController.text,
      'open_date': DateFormat('yy-MM-dd').format(DateTime.now()),
      'close_date': DateFormat('yy-MM-dd').format(_closeDate),
      'end_date': DateFormat('yy-MM-dd').format(_endDate),
      'result': null,
      'oracle_id': _oracleIdControllers.map((controller) => controller.text).toList(),
      'oracle_fee': _oracleFeeControllers.map((controller) => controller.text).toList(),
      'status': 1,
      'seed': decryptedSeed,
    };

    final response = await http.post(
      Uri.parse('http://192.168.1.211:5000/add_bet'),
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
                  _formKey.currentState?.reset();
                  _betDescriptionController.clear();
                  _numQusPerBetSlotController.clear();
                  _maxBetSlotsPerOptionController.clear();
                  _initializeOptionControllers();
                  _initializeOracleControllers();
                  setState(() {});
                }
              },
              child: Text('OK'),
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
          title: Text('Enter Password'),
          content: TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                password = _passwordController.text;
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Bet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _betDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Bet Description',
                  hintText: 'Enter bet description/question',
                ),
                maxLength: 32,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bet description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _numberOfOptions,
                      decoration: const InputDecoration(
                        labelText: 'Number of Options',
                      ),
                      items: List.generate(7, (index) => index + 2).map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _numberOfOptions = value ?? 2;
                          _initializeOptionControllers();
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Number of options to choose. Maximum: 8 options.')),
                      );
                    },
                  ),
                ],
              ),
              Column(
                children: List.generate(_numberOfOptions, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _optionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}',
                        hintText: 'Enter option description',
                        counterText: '${_optionControllers[index].text.length}/32',
                      ),
                      maxLength: 32,
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _numberOfOracles,
                      decoration: const InputDecoration(
                        labelText: 'Number of Oracle Providers',
                      ),
                      items: List.generate(8, (index) => index + 1).map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _numberOfOracles = value ?? 1;
                          _initializeOracleControllers();
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Oracle provider\'s ID (60 characters) and fee. Maximum: 8 oracles.')),
                      );
                    },
                  ),
                ],
              ),
              Column(
                children: List.generate(_numberOfOracles, (index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            controller: _oracleIdControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Oracle ID ${index + 1}',
                              hintText: 'Enter Oracle ID',
                            ),
                            maxLength: 60,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            controller: _oracleFeeControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Oracle Fee ${index + 1}',
                              hintText: '00.00',
                            ),
                            maxLength: 5,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              DecimalTextInputFormatter(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text("Close Date: ${DateFormat.yMd().format(_closeDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: Text("End Date: ${DateFormat.yMd().format(_endDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              TextFormField(
                controller: _numQusPerBetSlotController,
                decoration: const InputDecoration(
                  labelText: 'Number of Qus Per Bet Slot',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of qus per bet slot';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _maxBetSlotsPerOptionController,
                decoration: const InputDecoration(
                  labelText: 'Max Number of Bet Slots Per Option',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the max number of bet slots per option';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Perform the create bet action
                    _createBet();
                  }
                },
                child: const Text('Create Bet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _betDescriptionController.dispose();
    _numQusPerBetSlotController.dispose();
    _maxBetSlotsPerOptionController.dispose();
    _optionControllers.forEach((controller) => controller.dispose());
    _oracleIdControllers.forEach((controller) => controller.dispose());
    _oracleFeeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
