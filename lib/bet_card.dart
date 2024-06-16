import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'bet_detail_dialog.dart';

class BetCard extends StatefulWidget {
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
  final List<int> current_num_selection;
  final String current_total_qus; // used for stats
  final List<String> betting_odds; // betting odds
  final bool isPastBet;
  final DateTime? lastUpdateTime;

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
    this.lastUpdateTime,
  });

  @override
  _BetCardState createState() => _BetCardState();
}

class _BetCardState extends State<BetCard> {
  final GlobalKey _contentKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool _isOverflowing = false;
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final contentBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      final cardBox = context.findRenderObject() as RenderBox?;
      if (contentBox != null && cardBox != null) {
        setState(() {
          _isOverflowing = contentBox.size.height > cardBox.size.height;
        });
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent) {
        setState(() {
          _isAtBottom = true;
        });
      } else {
        setState(() {
          _isAtBottom = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showBetDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => BetDetailDialog(
        bet_id: widget.bet_id,
        no_options: widget.no_options,
        creator: widget.creator,
        bet_desc: widget.bet_desc,
        option_desc: widget.option_desc,
        max_slot_per_option: widget.max_slot_per_option,
        amount_per_bet_slot: widget.amount_per_bet_slot,
        open_date: widget.open_date,
        close_date: widget.close_date,
        end_date: widget.end_date,
        result: widget.result,
        no_ops: widget.no_ops,
        oracle_id: widget.oracle_id,
        oracle_fee: widget.oracle_fee,
        current_num_selection: widget.current_num_selection,
        current_total_qus: widget.current_total_qus,
        remaining_slots: _calculateRemainingSlots(),
        slot_colors: _calculateSlotColors(),
        betting_odds: widget.betting_odds,
        isPastBet: widget.isPastBet,
        lastUpdateTime: widget.lastUpdateTime,
      ),
    );
  }

  int _calculateDaysToExpire() {
    final now = DateTime.now();
    final closeDate = DateFormat('yy-MM-dd').parse(widget.close_date);
    return closeDate.difference(now).inDays;
  }

  double _calculateTotalFees() {
    if (widget.oracle_fee.isNotEmpty) {
      return widget.oracle_fee.map((fee) => fee ?? 0).reduce((a, b) => a + b);
    }
    return 0;
  }

  List<int> _calculateRemainingSlots() {
    List<int> selections = widget.current_num_selection.map((e) => e).toList();
    return selections
        .map((selection) => widget.max_slot_per_option - selection)
        .toList();
  }

  List<Color> _calculateSlotColors() {
    return _calculateRemainingSlots()
        .map((slots) => _determineColor(slots))
        .toList();
  }

  Color _determineColor(int remainingSlots) {
    double percentage = remainingSlots / widget.max_slot_per_option;
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

    return GestureDetector(
      onTap: _showBetDetailsDialog,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.white,
        elevation: 5.0,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  key: _contentKey,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.bet_desc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    for (int i = 0; i < widget.option_desc.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: slotColors[i],
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      widget.isPastBet && widget.result == i
                                          ? Colors.green
                                          : Colors.blue[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: _showBetDetailsDialog,
                                child: Text(
                                  widget.option_desc[i],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10.0),
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.blue[900] ?? Colors.blue),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                double.parse(widget.betting_odds[i])
                                    .toStringAsFixed(1),
                                style: TextStyle(
                                    fontSize: 18, color: Colors.blue[900]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    if (!widget.isPastBet)
                      Text(
                        'Expires in $daysToExpire days',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Fees: ${totalFees.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '${widget.current_total_qus} qus',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isOverflowing && !_isAtBottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
