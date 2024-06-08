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
  final String current_total_qus;
  final String current_num_selection;
  final List<int> remaining_slots;
  final List<Color> slot_colors;

  BetDetailDialog({
    super.key,
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
    required this.current_total_qus,
    required this.current_num_selection,
    required this.remaining_slots,
    required this.slot_colors,
  });

  @override
  _BetDetailDialogState createState() => _BetDetailDialogState();
}

class _BetDetailDialogState extends State<BetDetailDialog> {
  int? _selectedOption;

  @override
  Widget build(BuildContext context) {
    var current_slot = widget.remaining_slots.map((slot) => widget.max_slot_per_option - slot).toList();
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Bet Details',
        style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.orange),
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
              'Current Total Qus: ${widget.current_total_qus}',
              // Display the new field
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 20.0),
            Text(
              widget.bet_desc,
              style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 10.0),
            for (var i = 0; i < widget.option_desc.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.slot_colors[i],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedOption == i
                              ? Colors.green
                              : Colors.blue[900],
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
                          '${widget.option_desc[i]} (${current_slot[i]}/${widget.max_slot_per_option})',
                          style: const TextStyle(
                              fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
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
                    ),
                  );
                },
          child: Text(
            'Join Bet',
            style: TextStyle(
                color: _selectedOption == null ? Colors.grey : Colors.blue),
          ),
        ),
      ],
    );
  }
}
