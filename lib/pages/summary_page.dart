
// lib/pages/summary_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/friend.dart';
import '../models/expense.dart';
import '../utils/net_settlement.dart';

class SummaryPage extends StatelessWidget {
  final List<Friend> friends;
  final List<Expense> expenses;

  const SummaryPage({
    super.key,
    required this.friends,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, double> totals = {}; // Friend IDs are now String
    for (var f in friends) {
      totals[f.id] = 0;
    }

    for (var e in expenses) {
      e.shares.forEach((id, amount) {
        totals[id] = (totals[id] ?? 0) + amount;
      });
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: totals.isEmpty
            ? const Center(child: Text("No spending data yet"))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (ctx, i) {
                        final f = friends[i];
                        final total = totals[f.id] ?? 0;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(f.name),
                            trailing: Text(
                              "₹${total.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Net Settlements'),
                            onPressed: () => _openSettlementsDialog(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Export Totals'),
                          onPressed: () {
                            // Quick copy of per-person totals
                            final sb = StringBuffer();
                            for (final f in friends) {
                              final t = totals[f.id] ?? 0;
                              sb.writeln('${f.name}: ₹${t.toStringAsFixed(2)}');
                            }
                            Clipboard.setData(ClipboardData(text: sb.toString()));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Totals copied to clipboard')));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _openSettlementsDialog(BuildContext context) {
    // prepare friend ids
    final friendIds = friends.map((f) => f.id).toList();

    // compute settlements using the utility
    final result = computeSettlements(expenses: expenses, friendIds: friendIds);

    // pretty text
    final lines = <String>[];
    if (result.settlements.isEmpty) {
      lines.add('No transfers needed — everyone is settled.');
    } else {
      for (final s in result.settlements) {
        final fromName = _nameForId(s.fromId);
        final toName = _nameForId(s.toId);
        lines.add('$fromName → $toName : ₹${s.amount.toStringAsFixed(2)}');
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Net Settlements'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...lines.map((l) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(l),
                      )),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Net balances (positive = should receive):', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ...result.netBalances.entries.map((e) {
                  final name = _nameForId(e.key);
                  return Text('$name : ₹${e.value.toStringAsFixed(2)}');
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          TextButton(
            onPressed: () {
              final clipboardText = lines.join('\n');
              Clipboard.setData(ClipboardData(text: clipboardText));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settlements copied to clipboard')));
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  String _nameForId(String id) { // Changed to String
    if (id == '0') return 'You'; // Special ID for the current user
    final f = friends.firstWhere((x) => x.id == id, orElse: () => Friend(id: id, userId: '', name: 'Unknown'));
    return f.name;
  }
}
