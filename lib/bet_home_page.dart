import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bet_card.dart';
import 'constants.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BetHomePage extends StatefulWidget {
  @override
  _BetHomePageState createState() => _BetHomePageState();
}

class _BetHomePageState extends State<BetHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> ongoingBets = [];

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
    final response = await http.get(Uri.parse('http://192.168.1.211:5000/get_active_bets'));
    if (response.statusCode == 200) {
      setState(() {
        ongoingBets = json.decode(response.body);
      });
    } else {
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
    double tabBarTextSize = 24;
    bool isSmallScreen = screenWidth < smallScreenThreshold;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: isSmallScreen ? Text('Quottery App') : null,
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
            icon: Icon(Icons.logout),
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
              child: Text(
                'Bet App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Ongoing'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0);
              },
            ),
            ListTile(
              title: Text('Past Bets'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              title: Text('Create Bet'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
              },
            ),
          ],
        ),
      )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          BetList(bets: ongoingBets),
          Center(child: Text('Past Bets')),
          Center(child: Text('Create Bet')),
        ],
      ),
    );
  }
}

class BetList extends StatelessWidget {
  final List<dynamic> bets;

  const BetList({super.key, required this.bets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
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
