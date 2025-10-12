// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/friend.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  final List<Expense> expenses;
  final List<Friend> friends;
  final double monthlyBudget;

  const HomePage({
    super.key,
    required this.expenses,
    required this.friends,
    required this.monthlyBudget,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    
    // Calculate monthly spending
    final monthExpenses = expenses.where((e) =>
        e.date.isAfter(monthStart.subtract(const Duration(milliseconds: 1))) &&
        e.date.isBefore(monthEnd)).toList();
    
    final totalSpent = monthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final remaining = monthlyBudget - totalSpent;
    final percentSpent = monthlyBudget > 0 ? (totalSpent / monthlyBudget) : 0.0;
    
    // Category breakdown
    final Map<String, double> categoryTotals = {};
    for (final e in monthExpenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final topCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Month',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ₹${monthlyBudget.toStringAsFixed(0)} budget',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentSpent.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentSpent > 0.9
                            ? AppTheme.errorColor
                            : percentSpent > 0.7
                                ? AppTheme.warningColor
                                : AppTheme.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    remaining >= 0
                        ? '₹${remaining.toStringAsFixed(0)} remaining'
                        : '₹${(-remaining).toStringAsFixed(0)} over budget!',
                    style: TextStyle(
                      color: remaining >= 0 ? Colors.white : AppTheme.errorColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppTheme.primaryColor,
                    label: 'Expenses',
                    value: monthExpenses.length.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.group_rounded,
                    iconColor: AppTheme.secondaryColor,
                    label: 'Friends',
                    value: friends.length.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_up_rounded,
                    iconColor: AppTheme.accentColor,
                    label: 'Avg/Day',
                    value: '₹${(totalSpent / now.day).toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Top Categories
          if (topCategories.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Top Spending',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...topCategories.take(3).map((entry) {
              final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.getCategoryColor(entry.key).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppTheme.getCategoryIcon(entry.key),
                          color: AppTheme.getCategoryColor(entry.key),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${percentage.toStringAsFixed(0)}% of total',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
          
          // Recent Expenses
          if (monthExpenses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Expenses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to expenses tab - handled by parent
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...monthExpenses.take(5).map((expense) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor(expense.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      AppTheme.getCategoryIcon(expense.category),
                      color: AppTheme.getCategoryColor(expense.category),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    expense.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _formatDate(expense.date),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Text(
                    '₹${expense.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
          
          // Empty State
          if (monthExpenses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses this month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start tracking by adding your first expense',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}