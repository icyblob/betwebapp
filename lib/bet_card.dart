import 'package:flutter/material.dart';

import 'bet_detail_dialog.dart';

class BetCard extends StatelessWidget {
  final int bet_id;
  final int no_options;
  final String creator;
  final String bet_desc;
  final List<String> option_desc;
  final int max_slot_per_option;
  final int min_bet_amount;
  final String open_date;
  final String close_date;
  final String end_date;
  final int result;
  final int no_ops;
  final List<String> oracle_id;
  final List<double> oracle_fee;
  final String userId;
  // final bool status;

  BetCard({super.key,
    required this.bet_id,
    required this.no_options,
    required this.creator,
    required this.bet_desc,
    required this.option_desc,
    required this.max_slot_per_option,
    required this.min_bet_amount,
    required this.open_date,
    required this.close_date,
    required this.end_date,
    required this.result,
    required this.no_ops,
    required this.oracle_id,
    required this.oracle_fee,
    required this.userId
    // required this.status
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardArea = constraints.maxWidth * constraints.maxHeight;
        double textSize = cardArea * 0.00025;

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => BetDetailDialog(
                bet_id: bet_id,
                no_options: no_options,
                creator: creator,
                bet_desc: bet_desc,
                option_desc: option_desc,
                max_slot_per_option: max_slot_per_option,
                min_bet_amount: min_bet_amount,
                open_date: open_date,
                close_date: close_date,
                end_date: end_date,
                result: result,
                no_ops: no_ops,
                oracle_id: oracle_id,
                oracle_fee: oracle_fee,
                userId: userId,
                // status: status,
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.white,
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    bet_desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                  ),
                  const SizedBox(height: 10.0),
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
                        child: Text(option, style: TextStyle(fontSize: textSize/1.5, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
