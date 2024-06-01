import 'package:flutter/material.dart';
import 'join_bet_dialog.dart';

class BetDetailDialog extends StatefulWidget {
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
  final String userId;
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
    required this.userId,
    // required this.status
  });

  @override
  _BetDetailDialogState createState() => _BetDetailDialogState();
}

class _BetDetailDialogState extends State<BetDetailDialog> {
  int? _selectedOption;

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
              'Bet ID: ${widget.bet_id}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Creator: ${widget.creator}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Max slot per option: ${widget.max_slot_per_option}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Amount of qus per bet slot: ${widget.amount_per_bet_slot}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Open date: ${widget.open_date}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Close date: ${widget.close_date}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'End date: ${widget.end_date}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Oracle Provider IDs: ${widget.oracle_id}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              'Oracle Provider fees: ${widget.oracle_fee}',
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              widget.bet_desc,
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Options:',
              style: TextStyle(fontSize: 20.0),
            ),
            for (var i = 0; i < widget.option_desc.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption == i ? Colors.green : Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedOption = i;
                    });
                  },
                  child: Text(
                    widget.option_desc[i],
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
        TextButton(
          onPressed: _selectedOption == null
              ? null
              : () {
            showDialog(
              context: context,
              builder: (context) => JoinBetDialog(
                bet_id: widget.bet_id,
                option_id: _selectedOption!,
                max_slot_per_option: widget.max_slot_per_option,
                creatorId: widget.creator,
                userId: widget.userId,
              ),
            );
          },
          child: Text(
            'Join Bet',
            style: TextStyle(color: _selectedOption == null ? Colors.grey : Colors.blue),
          ),
        ),
      ],
    );
  }
}
