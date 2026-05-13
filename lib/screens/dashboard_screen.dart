import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../database_helper.dart';
import 'add_task_screen.dart';
import 'task_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  final QuoteApiService _apiService = QuoteApiService();
  String _quoteText = 'Stay calm. Stay productive 💙';
  String _quoteAuthor = 'ZenDo';
  bool _isLoadingQuote = false;

  int totalTasks = 0;
  int completedTasks = 0;
  int pendingTasks = 0;
  String userName = 'User';
  int? userId;

  List<int> weeklyData = [0, 0, 0, 0, 0, 0, 0];
  bool _isLoadingData = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> refreshData() async {
    await _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoadingData = true);

    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    userName = prefs.getString('userName') ?? 'User';

    if (userId == null) {
      setState(() => _isLoadingData = false);
      return;
    }

    await Future.wait([
      _loadQuote(),
      _loadTaskStats(),
      _loadWeeklyData(),
    ]);

    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadQuote() async {
    setState(() => _isLoadingQuote = true);
    try {
      final quote = await _apiService.getRandomQuote();
      if (mounted) {
        setState(() {
          _quoteText = quote['content'];
          _quoteAuthor = quote['author'];
          _isLoadingQuote = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _quoteText = 'The secret of getting ahead is getting started.';
          _quoteAuthor = 'Mark Twain';
          _isLoadingQuote = false;
        });
      }
    }
  }

  Future<void> _loadTaskStats() async {
    if (userId == null) return;
    final stats = await DatabaseHelper.instance.getTaskStatistics(userId!);
    if (mounted) {
      setState(() {
        totalTasks = stats['total']!;
        completedTasks = stats['completed']!;
        pendingTasks = stats['pending']!;
      });
    }
  }

  Future<void> _loadWeeklyData() async {
    if (userId == null) return;
    final data = await DatabaseHelper.instance.getWeeklyProductivity(userId!);
    if (mounted) {
      setState(() {
        weeklyData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh all data',
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              Card(
                elevation: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.waving_hand, color: Color(0xFFFFB74D), size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Hello, $userName! 👋',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Here's your productivity overview",
                        style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Tasks',
                      value: totalTasks.toString(),
                      icon: Icons.task_alt,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Completed',
                      value: completedTasks.toString(),
                      icon: Icons.check_circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Pending',
                      value: pendingTasks.toString(),
                      icon: Icons.pending_actions,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Weekly Chart
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.analytics, color: Color(0xFF1976D2)),
                          SizedBox(width: 8),
                          Text(
                            'Tasks Created This Week',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total created: ${weeklyData.reduce((a, b) => a + b)} tasks',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: weeklyData.every((element) => element == 0)
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'No tasks created this week',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                            : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (weeklyData.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                            minY: 0,
                            barGroups: weeklyData.asMap().entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    width: 24,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final now = DateTime.now();
                                    final date = now.subtract(Duration(days: 6 - value.toInt()));
                                    final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        dayName,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    if (value == meta.max || value == meta.min) {
                                      return const SizedBox();
                                    }
                                    return Text(
                                      value.toInt().toString(),
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
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.shade200,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quote Card
              Card(
                elevation: 3,
                color: const Color(0xFFFFF9C4),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.format_quote, color: Color(0xFFF57F17)),
                              SizedBox(width: 8),
                              Text(
                                'Daily Motivation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF57F17),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: _isLoadingQuote
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFF57F17),
                              ),
                            )
                                : const Icon(Icons.refresh, color: Color(0xFFF57F17)),
                            onPressed: _isLoadingQuote ? null : _loadQuote,
                            tooltip: 'Get new quote',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"$_quoteText"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          color: Color(0xFF424242),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '- $_quoteAuthor',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF57F17),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                        );
                        _loadAllData();
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Task'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF1976D2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TaskScreen()),
                        );
                        _loadAllData();
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View Tasks'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1976D2),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1976D2), width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}