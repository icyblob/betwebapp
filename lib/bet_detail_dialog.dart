import 'package:flutter/material.dart';

class BetDetailDialog extends StatelessWidget {
  final int bet_id;
  final int no_options;
  final String creator;
  final String bet_desc;
  final List<String> option_desc;
  final int max_slot_per_option;
  final int amount_per_bet_slot;
  final String open_date;
  final String close_date;
  final String end_date;
  final int result;
  final int no_ops;
  final List<String> oracle_id;
  final List<String> oracle_fee;
  // final bool status;

  BetDetailDialog({
    required this.bet_id,
    required this.no_options,
    required this.creator,
    required this.bet_desc,
    required this.option_desc,
    required this.max_slot_per_option,
    required this.amount_per_bet_slot,
    required this.open_date,
    required this.close_date,
    required this.end_date,
    required this.result,
    required this.no_ops,
    required this.oracle_id,
    required this.oracle_fee,
    // required this.status
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Bet Details',
        style: TextStyle(fontSize: 20.0),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Bet ID: $bet_id',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Creator: $creator',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Max slot per option: $max_slot_per_option',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Amount of qus per bet slot: $amount_per_bet_slot',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Open date: $open_date',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Close date: $close_date',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'End date: $end_date',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Oracle Provider IDs: $oracle_id',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Oracle Provider fees: $oracle_fee',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              bet_desc,
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Options:',
              style: TextStyle(fontSize: 20.0),
            ),
            for (var option in option_desc)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900], // Dark blue color for button background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
