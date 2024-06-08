import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBets() async {
    try {
      final response = await http
          .get(Uri.parse('$DATABASE_SERVER/get_active_bets'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          ongoingBets = data.where((bet) => bet['status'] == 1).toList();
          pastBets = data.where((bet) => bet['status'] == 0).toList();
        });
      } else {
        print('Failed to load bets: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to load bets');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load bets');
    }
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
      endDrawer: isSmallScreen
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                    ),
                    child: const Text(
                      'Bet App',
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
                BetList(bets: ongoingBets, isSmallScreen: isSmallScreen),
                BetList(bets: pastBets, isSmallScreen: isSmallScreen),
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

  BetList({super.key, required this.bets, required this.isSmallScreen});

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
          return BetCard(
            bet_id: bet['bet_id'],
            no_options: bet['no_options'],
            creator: bet['creator'],
            bet_desc: bet['bet_desc'],
            option_desc: bet['option_desc'].split(','),
            max_slot_per_option: bet['max_slot_per_option'],
            amount_per_bet_slot: bet['amount_per_bet_slot'],
            open_date: bet['open_date'],
            close_date: bet['close_date'],
            end_date: bet['end_date'],
            result: bet['result'] ?? -1,
            no_ops: bet['no_ops'],
            oracle_id: bet['oracle_id'].split(','),
            oracle_fee: bet['oracle_fee'].split(','),
            current_total_qus: bet['current_total_qus'],
            current_num_selection: bet['current_num_selection'],
          );
        },
      ),
    );
  }
}
