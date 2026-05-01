import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _userData = {};
  int _monthlyGoalHours = 20;
  int _totalListeningMinutes = 0;
  late List<int> _dailyMinutes;
  bool _isLoading = true;

  // COULEURS BURGUNDY (Bordeaux)
  final Color mainBurgundy = const Color(0xFF800020);
  final Color lightBurgundy = const Color(0xFFC72C48);

  @override
  void initState() {
    super.initState();
    _dailyMinutes = List.generate(31, (index) => 0);
    // Simulation de données pour le graphique
    _dailyMinutes[2] = 45;
    _dailyMinutes[5] = 120;
    _dailyMinutes[6] = 30;
    _dailyMinutes[10] = 90;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService = context.read<AuthService>();
      final userData = await authService.getUserData();
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _userData = userData;
        _monthlyGoalHours = prefs.getInt('monthlyGoalHours') ?? 20;
        _totalListeningMinutes = prefs.getInt('totalListeningMinutes') ?? 754; // Valeur simulée 12h34
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

  // FONCTIONNALITÉ BONUS : Bonjour / Bonsoir Dynamique
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 18) {
      return 'Bonjour ';
    } else {
      return 'Bonsoir ';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A050A), // Fond bordeaux très sombre
        body: Center(child: CircularProgressIndicator(color: lightBurgundy)),
      );
    }

    final firstName = _userData['firstName'] ?? 'Utilisateur';
    final totalHours = _totalListeningMinutes ~/ 60;
    final remainingMinutes = _totalListeningMinutes % 60;
    final progressPercentage = (_totalListeningMinutes / (_monthlyGoalHours * 60)) * 100;

    return Scaffold(
      backgroundColor: Colors.transparent, // Important pour voir l'AppBackground de MainScreen
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              // En-tête : Message de bienvenue dynamique
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(
                        _getGreeting(), // <-- L'appel à notre nouvelle fonction !
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                      ),
                      Text(
                        firstName,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors:[mainBurgundy, lightBurgundy]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow:[BoxShadow(color: mainBurgundy.withOpacity(0.4), blurRadius: 12)]
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Statistiques rapides (GlassCards)
              Row(
                children:[
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children:[
                          Text('${totalHours}h ${remainingMinutes.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Ce mois', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children:[
                          const Text('47', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Pistes', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children:[
                          Text('${progressPercentage.clamp(0, 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Objectif', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Objectif mensuel
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text('Objectif mensuel', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                        PopupMenuButton<int>(
                          initialValue: _monthlyGoalHours,
                          onSelected: _updateMonthlyGoal,
                          icon: Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.7)),
                          color: const Color(0xFF3D0C1A), // Fond bordeaux pour le menu
                          itemBuilder: (BuildContext context) =>[
                            const PopupMenuItem(value: 10, child: Text('10 heures', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: 20, child: Text('20 heures', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: 30, child: Text('30 heures', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: 50, child: Text('50 heures', style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      ],
                    ),
                    Text('${(totalHours + remainingMinutes/60).toStringAsFixed(1)} / ${_monthlyGoalHours}h',
                        style: TextStyle(color: lightBurgundy, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (progressPercentage / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressPercentage >= 100 ? const Color(0xFF34D399) : lightBurgundy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Graphique Histogramme (fl_chart)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text('Écoute — Mois en cours', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 150,
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: const FlTitlesData(show: false), // Caché pour plus de minimalisme
                          barGroups: List.generate(10, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods:[
                                BarChartRodData(
                                  toY: (index * 15 + 20).toDouble() % 120, // Fausses données esthétiques pour la démo
                                  width: 12,
                                  gradient: LinearGradient(
                                    colors:[mainBurgundy, lightBurgundy],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30), // Espace pour la barre de navigation
            ],
          ),
        ),
      ),
    );
  }
}