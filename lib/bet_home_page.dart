import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'bet_card.dart';
import 'constants.dart';
import 'create_bet_form.dart';

class BetHomePage extends StatefulWidget {
  const BetHomePage({super.key});

  @override
  _BetHomePageState createState() => _BetHomePageState();
}

class _BetHomePageState extends State<BetHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> ongoingBets = [];
  List<dynamic> pastBets = [];
  Timer? _timer;  // Timer for periodic fetch
  DateTime? lastUpdateTime;  // Store the last update time

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  Future<void> _fetchBets() async {
    try {
      final response =
          await http.get(Uri.parse('$DATABASE_SERVER/get_active_bets'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          ongoingBets = data.where((bet) => bet['status'] == 1).toList();
          pastBets = data.where((bet) => bet['status'] == 0).toList();
          lastUpdateTime = DateTime.now();  // Update the last update time
        });
      } else {
        print(
            'Failed to load bets: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to load bets');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load bets');
    } finally {
      _startTimer();  // Start the timer after fetch completes
    }
  }

  void _startTimer() {
    _timer?.cancel();  // Cancel any existing timer
    _timer = Timer(const Duration(seconds: 3), _fetchBets);  // Fetch bets every 3 seconds
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double tabBarTextSize = TAB_BAR_TEXT_SIZE;
    bool isSmallScreen = screenWidth < SMALL_SCREEN_THRESHOLD;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: isSmallScreen ? const Text('Quottery App') : null,
        bottom: isSmallScreen
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Ongoing'),
                  Tab(text: 'Past Bets'),
                  Tab(text: 'Create Bet'),
                ],
                labelStyle: TextStyle(fontSize: tabBarTextSize),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBets,
          ),
        ],
      ),
      drawer: isSmallScreen
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                    ),
                    child: const Text(
                      'Quottery App',
                      style: TextStyle(
                        color: Colors.white,
                        // color: Color.fromRGBO(7, 21, 27, 1.0),
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Ongoing'),
                    onTap: () {
                      Navigator.pop(context);
                      _tabController.animateTo(0);
                    },
                  ),
                  ListTile(
                    title: const Text('Past Bets'),
                    onTap: () {
                      Navigator.pop(context);
                      _tabController.animateTo(1);
                    },
                  ),
                  ListTile(
                    title: const Text('Create Bet'),
                    onTap: () {
                      Navigator.pop(context);
                      _tabController.animateTo(2);
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                BetList(bets: ongoingBets, isSmallScreen: isSmallScreen, lastUpdateTime: lastUpdateTime),
                BetList(bets: pastBets, isSmallScreen: isSmallScreen, isPastBet: true, lastUpdateTime: lastUpdateTime),
                CreateBetForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BetList extends StatelessWidget {
  final List<dynamic> bets;
  final bool isSmallScreen;
  final bool isPastBet;
  final DateTime? lastUpdateTime;

  BetList({super.key,
    required this.bets,
    required this.isSmallScreen,
    this.isPastBet = false,
    this.lastUpdateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent:
              isSmallScreen ? double.infinity : MAX_GRID_COLUMN_WIDTH,
          childAspectRatio: 300.0 / 200.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: bets.length,
        itemBuilder: (context, index) {
          final bet = bets[index];

          if (kDebugMode) {
            print(bet);
            final int bet_id = bet['bet_id'];
            final int no_options = bet['no_options'];
            final String creator = bet['creator'];
            final String bet_desc = bet['bet_desc'];
            final List<String> option_desc =
                List<String>.from(json.decode(bet['option_desc']));
            final int max_slot_per_option = bet['max_slot_per_option'];
            final int amount_per_bet_slot = bet['amount_per_bet_slot'];
            final String open_date = bet['open_date'];
            final String close_date = bet['close_date'];
            final String end_date = bet['end_date'];
            final int result = bet['result'] == "none" ? -1 : bet['result'];
            final int no_ops = bet['no_ops'];
            final List<String> oracle_id =
                List<String>.from(json.decode(bet['oracle_id']));
            final List<double> oracle_fee =
                List<double>.from(json.decode(bet['oracle_fee']));
            final List<int> current_num_selection =
                List<int>.from(json.decode(bet['current_bet_state']));
            final String current_total_qus = bet['current_total_qus'];
            final List<String> betting_odds =
                List<String>.from(json.decode(bet['betting_odds']));
          }

          return BetCard(
            bet_id: bet['bet_id'],
            no_options: bet['no_options'],
            creator: bet['creator'],
            bet_desc: bet['bet_desc'],
            option_desc: List<String>.from(json.decode(bet['option_desc'])),
            max_slot_per_option: bet['max_slot_per_option'],
            amount_per_bet_slot: bet['amount_per_bet_slot'],
            open_date: bet['open_date'],
            close_date: bet['close_date'],
            end_date: bet['end_date'],
            result: bet['result'] == "none" ? -1 : bet['result'],
            no_ops: bet['no_ops'],
            oracle_id: List<String>.from(json.decode(bet['oracle_id'])),
            oracle_fee: List<double>.from(json.decode(bet['oracle_fee'])),
            current_total_qus: bet['current_total_qus'],
            current_num_selection:
                List<int>.from(json.decode(bet['current_bet_state'])),
            betting_odds: List<String>.from(json.decode(bet['betting_odds'])),
            isPastBet: isPastBet,
            lastUpdateTime: lastUpdateTime,
          );
        },
      ),
    );
  }
}
