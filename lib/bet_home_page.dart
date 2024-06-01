import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'bet_card.dart';
import 'constants.dart';

class BetHomePage extends StatefulWidget {
  @override
  _BetHomePageState createState() => _BetHomePageState();
}

class _BetHomePageState extends State<BetHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    double tabBarHeight = screenHeight * 0.10;
    double tabBarTextSize = screenHeight * 0.08;
    bool isSmallScreen = screenWidth < smallScreenThreshold;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: isSmallScreen ? Text('Quottery App') : null,
        bottom: isSmallScreen
            ? null
            : TabBar(
          controller: _tabController,
          tabs: [
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
          OngoingBets(isSmallScreen: isSmallScreen),
          PastBets(isSmallScreen: isSmallScreen),
          CreateBet(),
        ],
      ),
    );
  }
}

class OngoingBets extends StatelessWidget {
  final bool isSmallScreen;

  OngoingBets({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double gridColumnWidth = isSmallScreen ? constraints.maxWidth : maxGridColumnWidth;
          double gridRowHeight = maxGridRowHeight;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: gridColumnWidth,
              childAspectRatio: gridColumnWidth / gridRowHeight,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: 4, // Number of cards to display
            itemBuilder: (context, index) {
              return BetCard(
                question: 'Sample Question $index',
                options: ['Option 1', 'Option 2'],
                betId: 'BET${index + 1}',
                numberOfOptions: 2,
                creatorId: 'Creator${index + 1}',
                maxBetAmount: 100.0,
                openDate: '2023-01-01',
                closeDate: '2023-01-31',
                endDate: '2023-02-01',
                oracleProviderIds: ['Oracle1', 'Oracle2'],
              );
            },
          );
        },
      ),
    );
  }
}

class PastBets extends StatelessWidget {
  final bool isSmallScreen;

  PastBets({required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double gridColumnWidth = isSmallScreen ? constraints.maxWidth : maxGridColumnWidth;
          double gridRowHeight = maxGridRowHeight;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: gridColumnWidth,
              childAspectRatio: gridColumnWidth / gridRowHeight,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: 4, // Number of cards to display
            itemBuilder: (context, index) {
              return BetCard(
                question: 'Sample Question $index',
                options: ['Option 1', 'Option 2'],
                betId: 'BET${index + 1}',
                numberOfOptions: 2,
                creatorId: 'Creator${index + 1}',
                maxBetAmount: 100.0,
                openDate: '2023-01-01',
                closeDate: '2023-01-31',
                endDate: '2023-02-01',
                oracleProviderIds: ['Oracle1', 'Oracle2'],
              );
            },
          );
        },
      ),
    );
  }
}

class CreateBet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Create Bet Page'),
    );
  }
}
