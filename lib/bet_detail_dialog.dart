import 'package:flutter/material.dart';

class BetDetailDialog extends StatelessWidget {
  final String question;
  final List<String> options;
  final String betId;
  final int numberOfOptions;
  final String creatorId;
  final double maxBetAmount;
  final String openDate;
  final String closeDate;
  final String endDate;
  final List<String> oracleProviderIds;

  BetDetailDialog({
    required this.question,
    required this.options,
    required this.betId,
    required this.numberOfOptions,
    required this.creatorId,
    required this.maxBetAmount,
    required this.openDate,
    required this.closeDate,
    required this.endDate,
    required this.oracleProviderIds,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Bet Details',
        style: TextStyle(fontSize: 20.0),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Question: $question',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 10),
            Text(
              'Bet ID: $betId',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Number of Options: $numberOfOptions',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Creator ID: $creatorId',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Maximum Bet Amount: $maxBetAmount',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Open Date: $openDate',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Close Date: $closeDate',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'End Date: $endDate',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Oracle Provider IDs: ${oracleProviderIds.join(", ")}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Options:',
              style: TextStyle(fontSize: 20.0),
            ),
            for (var option in options)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
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
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
