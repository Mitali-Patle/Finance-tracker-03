// lib/pages/analytics_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../models/friend.dart';
import '../theme/app_theme.dart';

class AnalyticsPage extends StatelessWidget {
  final List<Expense> expenses;
  final List<Friend> friends;
  const AnalyticsPage({super.key, required this.expenses, required this.friends});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    final monthExpenses = expenses
        .where((e) => e.date.isAfter(monthStart.subtract(const Duration(milliseconds: 1))) && e.date.isBefore(monthEnd))
        .toList();

    // Category totals for pie
    final Map<String, double> byCategory = {};
    for (final e in monthExpenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }

    // Daily totals for bar chart
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final List<double> byDay = List.filled(daysInMonth, 0);
    for (final e in monthExpenses) {
      final day = e.date.day;
      byDay[day - 1] += e.amount;
    }

    return monthExpenses.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No data for this month',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add expenses to see analytics',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Split Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.pie_chart_rounded,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Category Split',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AspectRatio(
                          aspectRatio: 1.3,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 50,
                              sections: byCategory.entries.map((e) {
                                final total = byCategory.values.fold<double>(0, (p, v) => p + v);
                                final pc = total == 0 ? 0 : (e.value / total) * 100;
                                final color = AppTheme.getCategoryColor(e.key);
                                
                                return PieChartSectionData(
                                  value: e.value,
                                  title: '${pc.toStringAsFixed(0)}%',
                                  radius: 80,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  color: color,
                                  badgeWidget: _buildBadge(e.key, color),
                                  badgePositionPercentageOffset: 1.4,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Legend
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: byCategory.entries.map((e) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppTheme.getCategoryColor(e.key),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${e.key} (₹${e.value.toStringAsFixed(0)})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Spending Trend Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                color: AppTheme.secondaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Daily Spending Trend',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: BarChart(
                            BarChartData(
                              barGroups: [
                                for (int i = 0; i < byDay.length; i++)
                                  BarChartGroupData(
                                    x: i + 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: byDay[i],
                                        color: AppTheme.primaryColor,
                                        width: 12,
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                      )
                                    ],
                                  ),
                              ],
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 45,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '₹${value.toInt()}',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 5,
                                    getTitlesWidget: (v, meta) {
                                      final d = v.toInt();
                                      if (d < 1 || d > daysInMonth) return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          d.toString(),
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1000,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.2),
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
                
                const SizedBox(height: 20),
                
                // Who Owes What Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.people_rounded,
                                color: AppTheme.accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Who Owes What',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildWhoOwesWhat(monthExpenses, friends),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildBadge(String category, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        AppTheme.getCategoryIcon(category),
        color: color,
        size: 16,
      ),
    );
  }

  Widget _buildWhoOwesWhat(List<Expense> exps, List<Friend> friends) {
    final Map<String, double> owed = {};
    for (final e in exps) {
      e.shares.forEach((fid, amount) {
        owed[fid] = (owed[fid] ?? 0) + amount;
      });
    }
    
    if (owed.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No splits this month',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      children: owed.entries.map((entry) {
        final friend = friends.firstWhere(
          (f) => f.id == entry.key,
          orElse: () => Friend(id: '-1', userId: '', name: 'Unknown'),
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  friend.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '₹${entry.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}