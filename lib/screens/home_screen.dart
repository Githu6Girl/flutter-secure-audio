import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _userData = {};
  int _monthlyGoalHours = 20;
  int _totalListeningMinutes = 0;
  int _todayListeningMinutes = 0;
  late List<int> _dailyMinutes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dailyMinutes = List.generate(31, (index) => 0);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService = context.read<AuthService>();
      final userData = await authService.getUserData();
      
      final prefs = await SharedPreferences.getInstance();
      final monthlyGoal = prefs.getInt('monthlyGoalHours') ?? 20;
      final totalMinutes = prefs.getInt('totalListeningMinutes') ?? 0;
      
      setState(() {
        _userData = userData;
        _monthlyGoalHours = monthlyGoal;
        _totalListeningMinutes = totalMinutes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMonthlyGoal(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('monthlyGoalHours', hours);
    setState(() => _monthlyGoalHours = hours);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final firstName = _userData['firstName'] ?? 'Utilisateur';
    final totalHours = _totalListeningMinutes ~/ 60;
    final remainingMinutes = _totalListeningMinutes % 60;
    final progressPercentage =
        (_totalListeningMinutes / (_monthlyGoalHours * 60)) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              RichText(
                text: TextSpan(
                  text: 'Bienvenue, ',
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    TextSpan(
                      text: firstName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Listening stats card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Votre écoute',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '$totalHours',
                                style:
                                    Theme.of(context).textTheme.displaySmall,
                              ),
                              Text(
                                'Heures',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '$remainingMinutes',
                                style:
                                    Theme.of(context).textTheme.displaySmall,
                              ),
                              Text(
                                'Minutes',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${_dailyMinutes.where((m) => m > 0).length}',
                                style:
                                    Theme.of(context).textTheme.displaySmall,
                              ),
                              Text(
                                'Jours',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Monthly goal progress
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Objectif mensuel',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          PopupMenuButton<int>(
                            initialValue: _monthlyGoalHours,
                            onSelected: _updateMonthlyGoal,
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(value: 10, child: Text('10 heures')),
                              const PopupMenuItem(value: 20, child: Text('20 heures')),
                              const PopupMenuItem(value: 30, child: Text('30 heures')),
                              const PopupMenuItem(value: 50, child: Text('50 heures')),
                            ],
                            child: Icon(
                              Icons.more_vert,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$_monthlyGoalHours heures',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (progressPercentage / 100)
                              .clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressPercentage >= 100
                                ? const Color(0xFF34D399)
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${progressPercentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Daily minutes histogram
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Écoute par jour',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY:
                                _dailyMinutes.isEmpty
                                ? 60
                                : _dailyMinutes.reduce((a, b) => a > b ? a : b)
                                    .toDouble() +
                                10,
                            barGroups: List.generate(
                              _dailyMinutes.length,
                              (index) {
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _dailyMinutes[index].toDouble(),
                                      color:
                                          Theme.of(context).primaryColor,
                                      width: 8,
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt() + 1}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}m',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Most played tracks
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pistes les plus écoutées',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Commencez à écouter pour voir vos pistes les plus écoutées',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
