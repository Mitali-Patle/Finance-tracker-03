// lib/pages/expenses_page.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/friend.dart';
import '../theme/app_theme.dart';

class ExpensesPage extends StatelessWidget {
  final String userId;
  final List<Expense> expenses;
  final List<Friend> friends;
  final void Function(Expense) onCreate;
  final void Function(Expense) onUpdate;
  final void Function(Expense) onDelete;
  final double usdInr;

  const ExpensesPage({
    super.key,
    required this.userId,
    required this.expenses,
    required this.friends,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
    required this.usdInr,
  });

  @override
  Widget build(BuildContext context) {
    // Group expenses by date
    final Map<String, List<Expense>> groupedExpenses = {};
    for (final e in expenses) {
      final dateKey = _formatDateHeader(e.date);
      if (!groupedExpenses.containsKey(dateKey)) {
        groupedExpenses[dateKey] = [];
      }
      groupedExpenses[dateKey]!.add(e);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: expenses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first expense',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: const ClampingScrollPhysics(),
                key: ValueKey('expenses_list_${expenses.length}'),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: groupedExpenses.length,
                itemBuilder: (ctx, i) {
                  final dateKey = groupedExpenses.keys.elementAt(i);
                  final dayExpenses = groupedExpenses[dateKey]!;
                  final dayTotal = dayExpenses.fold<double>(0, (sum, e) => sum + e.amount);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8, top: i == 0 ? 0 : 16),
                        child: Row(
                          children: [
                            Text(
                              dateKey,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Divider(color: Colors.grey[300])),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '₹${dayTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Expenses for this date
                      ...dayExpenses.map((e) => _buildExpenseCard(context, e)),
                    ],
                  );
                },
              ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1.0),
          curve: Curves.easeOut,
        ),
        child: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
          onPressed: () => _openAddDialog(context),
          elevation: 4,
          heroTag: 'add_expense_fab',
        ),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense e) {
    final categoryColor = AppTheme.getCategoryColor(e.category);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: ValueKey(e.id),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 20),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
        ),
        confirmDismiss: (_) => _showDeleteConfirmation(context, e),
        onDismissed: (_) => onDelete(e),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Leading Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppTheme.getCategoryIcon(e.category),
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              e.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ),
                          if (e.shares.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.people_alt_rounded, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${e.shares.length}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Trailing Section
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${e.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _openAddDialog(context, existing: e),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        InkWell(
                          onTap: () async {
                            final confirmed = await _showDeleteConfirmation(context, e);
                            if (confirmed == true) {
                              onDelete(e);
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 15,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
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
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Expense e) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Expense',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${e.title}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${e.title} deleted'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ---------- Add / Edit dialog ----------
  void _openAddDialog(BuildContext context, {Expense? existing}) {
    final titleC = TextEditingController(text: existing?.title ?? '');
    final amountC = TextEditingController(text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    final categories = ['Food', 'Travel', 'Shopping', 'Bills', 'Entertainment', 'Other'];
    String category = existing?.category ?? categories.first;

    final selectedFriendIds = existing?.shares.keys.toSet() ?? <String>{};
    final Map<String, double> customShares = Map<String, double>.from(existing?.shares ?? {});

    double totalForSplit = existing?.amount ?? 0.0;
    bool equalSplit = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          void _recalcEqual() {
            if (equalSplit && selectedFriendIds.isNotEmpty && totalForSplit > 0) {
              final per = totalForSplit / selectedFriendIds.length;
              for (final id in selectedFriendIds) {
                customShares[id] = double.parse(per.toStringAsFixed(2));
              }
            }
            setLocal(() {});
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              existing == null ? Icons.add_rounded : Icons.edit_rounded,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            existing == null ? 'Add Expense' : 'Edit Expense',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: titleC,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g., Pizza, Uber',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: amountC,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: '₹ ',
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          totalForSplit = double.tryParse(v) ?? 0;
                          _recalcEqual();
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: category,
                        items: categories.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Icon(AppTheme.getCategoryIcon(c), size: 20, color: AppTheme.getCategoryColor(c)),
                                const SizedBox(width: 12),
                                Text(c),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setLocal(() => category = v ?? category),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Split with:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      friends.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, color: Colors.orange[700], size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'No friends yet. Add friends from the Friends tab.',
                                      style: TextStyle(fontSize: 13, color: Colors.orange[900]),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: friends.map((f) {
                                final isSelected = selectedFriendIds.contains(f.id);
                                return FilterChip(
                                  label: Text(f.name),
                                  selected: isSelected,
                                  onSelected: (sel) {
                                    setLocal(() {
                                      if (sel) {
                                        selectedFriendIds.add(f.id);
                                      } else {
                                        selectedFriendIds.remove(f.id);
                                        customShares.remove(f.id);
                                      }
                                      _recalcEqual();
                                    });
                                  },
                                  selectedColor: AppTheme.accentColor.withOpacity(0.2),
                                  checkmarkColor: AppTheme.accentColor,
                                );
                              }).toList(),
                            ),
                      if (selectedFriendIds.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'Equal split',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Switch(
                              value: equalSplit,
                              onChanged: (v) {
                                setLocal(() {
                                  equalSplit = v;
                                  _recalcEqual();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                      if (!equalSplit && selectedFriendIds.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text(
                          'Custom split',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        ...selectedFriendIds.map((id) {
                          final f = friends.firstWhere((x) => x.id == id);
                          final current = customShares[id] ?? 0.0;
                          final maxValue = totalForSplit > 0 ? totalForSplit : 1000.0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        f.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Text(
                                      '₹${current.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  min: 0,
                                  max: maxValue,
                                  value: current.clamp(0, maxValue),
                                  activeColor: AppTheme.accentColor,
                                  onChanged: (val) {
                                    setLocal(() {
                                      customShares[id] = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (_) {
                            final sum = customShares.values.fold<double>(0, (p, e) => p + e);
                            final diff = (totalForSplit - sum);
                            final isBalanced = diff.abs() < 0.5;
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isBalanced
                                    ? AppTheme.accentColor.withOpacity(0.1)
                                    : AppTheme.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isBalanced ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                                    color: isBalanced ? AppTheme.accentColor : AppTheme.errorColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isBalanced
                                        ? 'Split balanced!'
                                        : 'Remaining: ₹${diff.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: isBalanced ? AppTheme.accentColor : AppTheme.errorColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                final title = titleC.text.trim();
                                final amount = double.tryParse(amountC.text.trim()) ?? 0;
                                if (title.isEmpty || amount <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter valid title and amount')),
                                  );
                                  return;
                                }

                                final shares = <String, double>{};
                                if (selectedFriendIds.isNotEmpty) {
                                  if (equalSplit) {
                                    final per = double.parse((amount / selectedFriendIds.length).toStringAsFixed(2));
                                    for (final id in selectedFriendIds) {
                                      shares[id] = per;
                                    }
                                  } else {
                                    final sum = customShares.values.fold<double>(0, (p, e) => p + e);
                                    if (sum > 0) {
                                      final factor = amount / sum;
                                      for (final id in selectedFriendIds) {
                                        final v = (customShares[id] ?? 0) * factor;
                                        shares[id] = double.parse(v.toStringAsFixed(2));
                                      }
                                    }
                                  }
                                }

                                final createdOrUpdatedExpense = Expense(
                                  id: existing?.id ?? '',
                                  userId: userId,
                                  title: title,
                                  amount: amount,
                                  category: category,
                                  date: DateTime.now(),
                                  shares: shares,
                                );

                                if (existing != null) {
                                  onUpdate(createdOrUpdatedExpense);
                                } else {
                                  onCreate(createdOrUpdatedExpense);
                                }
                                Navigator.of(ctx).pop();
                              },
                              child: Text(existing == null ? 'Add' : 'Update'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}