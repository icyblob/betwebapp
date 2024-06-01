import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bet_card.dart';
import 'constants.dart';
import 'login_page.dart';
import 'create_bet_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BetHomePage extends StatefulWidget {
  final String hashedSeed;

  BetHomePage({this.hashedSeed=''});

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
          .get(Uri.parse('http://192.168.1.211:5000/get_active_bets'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          ongoingBets = data.where((bet) => bet['status'] == 1).toList();
          pastBets = data.where((bet) => bet['status'] == 0).toList();
        });
      } else {
        print(
            'Failed to load bets: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to load bets');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load bets');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ss_ecrpt');
    await prefs.remove('password');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double tabBarTextSize = TAB_BAR_TEXT_SIZE;
    bool isSmallScreen = screenWidth < smallScreenThreshold;

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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('User ID: ${widget.hashedSeed}',
                style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                BetList(bets: ongoingBets, isSmallScreen: isSmallScreen),
                BetList(bets: pastBets, isSmallScreen: isSmallScreen),
                CreateBetForm(creatorId: widget.hashedSeed),
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
              isSmallScreen ? double.infinity : maxGridColumnWidth,
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
          );
        },
      ),
    );
  }
}
