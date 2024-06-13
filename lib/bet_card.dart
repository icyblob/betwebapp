import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'bet_detail_dialog.dart';

class BetCard extends StatelessWidget {
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
  final List<double> oracle_fee;
  final List<String> current_num_selection;
  final String current_total_qus; // used for stats
  final List<String> betting_odds; // betting odds
  final bool isPastBet;
  // final bool status;

  BetCard({
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
    required this.current_num_selection,
    required this.current_total_qus,
    required this.betting_odds,
    this.isPastBet = false,
    // required this.status
  });

  int _calculateDaysToExpire() {
    final now = DateTime.now();
    final closeDate = DateFormat('yy-MM-dd').parse(close_date);
    return closeDate.difference(now).inDays;
  }

  double _calculateTotalFees() {
    return oracle_fee
        .map((fee) => fee ?? 0)
        .reduce((a, b) => a + b);
  }

  List<int> _calculateRemainingSlots() {
    List<int> selections =
        current_num_selection.map((e) => int.parse(e)).toList();
    return selections
        .map((selection) => max_slot_per_option - selection)
        .toList();
  }

  Color _determineColor(int remainingSlots) {
    double percentage = remainingSlots / max_slot_per_option;
    if (percentage > 0.66) {
      return Colors.green;
    } else if (percentage > 0.33) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysToExpire = _calculateDaysToExpire();
    final totalFees = _calculateTotalFees();
    final remainingSlots = _calculateRemainingSlots();
    final slotColors =
        remainingSlots.map((slots) => _determineColor(slots)).toList();

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
                amount_per_bet_slot: amount_per_bet_slot,
                open_date: open_date,
                close_date: close_date,
                end_date: end_date,
                result: result,
                no_ops: no_ops,
                oracle_id: oracle_id,
                oracle_fee: oracle_fee,
                current_num_selection: current_num_selection,
                current_total_qus: current_total_qus,
                remaining_slots: remainingSlots,
                slot_colors: slotColors,
                betting_odds: betting_odds,
                isPastBet: isPastBet,
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
              padding: EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      bet_desc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900]),
                    ),
                    const SizedBox(height: 10.0),
                    for (int i = 0; i < option_desc.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          children: [
                            Container(
                              width: textSize,
                              height: textSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: slotColors[i],
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPastBet && result == i
                                      ? Colors.green
                                      : Colors.blue[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  '${option_desc[i]}',
                                  style: TextStyle(
                                      fontSize: textSize / 1.5,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10.0),
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue[900] ?? Colors.blue),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                double.parse(betting_odds[i]).toStringAsFixed(1),
                                style: TextStyle(fontSize: textSize / 1.5, color: Colors.blue[900]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Expires in $daysToExpire days',
                      // Display the days to expire
                      style: TextStyle(
                          fontSize: textSize * 0.5, color: Colors.grey),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Fees: ${totalFees.toStringAsFixed(2)}%',
                      style: TextStyle(
                          fontSize: textSize * 0.5, color: Colors.black),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '$current_total_qus qus',
                      style: TextStyle(
                          fontSize: textSize * 0.5,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
