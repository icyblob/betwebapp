import 'package:flutter/material.dart';
import 'bet_detail_dialog.dart';

class BetCard extends StatelessWidget {
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

  BetCard({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardArea = constraints.maxWidth * constraints.maxHeight;
        double textSize = cardArea * 0.00025;

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => BetDetailDialog(
                question: question,
                options: options,
                betId: betId,
                numberOfOptions: numberOfOptions,
                creatorId: creatorId,
                maxBetAmount: maxBetAmount,
                openDate: openDate,
                closeDate: closeDate,
                endDate: endDate,
                oracleProviderIds: oracleProviderIds,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    question,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                  ),
                  SizedBox(height: 10.0),
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
                        child: Text(option, style: TextStyle(fontSize: textSize/1.5, color: Colors.white),
                      ),
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
