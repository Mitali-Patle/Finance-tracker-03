// lib/utils/net_settlement.dart
import '../models/expense.dart';
import 'dart:math';

/// A settlement: person with id `fromId` pays `amount` to person `toId`.
class Settlement {
  final String fromId; // Changed to String
  final String toId; // Changed to String
  final double amount;
  Settlement({required this.fromId, required this.toId, required this.amount});
}

/// Result returned by computeSettlements
class NetSettlementResult {
  final Map<String, double> netBalances; // id (String) -> balance (positive = should receive)
  final List<Settlement> settlements;

  NetSettlementResult({required this.netBalances, required this.settlements});
}

/// Compute net balances and minimal settlements.
///
/// Assumptions:
/// - All expenses are paid by the local user ("You") with id = 0.
/// - expense.shares contains friendId -> amount (amount the friend owes).
NetSettlementResult computeSettlements({
  required List<Expense> expenses, // Changed to List<Expense>
  required List<String> friendIds, // Changed to List<String>
}) {
  // Build initial net map including You (id "0") and all friend ids.
  final Map<String, double> net = {"0": 0.0}; // Changed to String
  for (final fid in friendIds) {
    net[fid] = 0.0;
  }

  // Sum shares: friends owe (negative), You receives (positive)
  for (final e in expenses) {
    final Map<String, dynamic> shares = e.shares; // Ensure shares map is String key
    shares.forEach((key, value) {
      final String fid = key; // Friend ID is now String
      final double amt = (value as num).toDouble();
      net[fid] = (net[fid] ?? 0) - amt; // friend owes -> negative
      net["0"] = (net["0"] ?? 0) + amt; // You should receive these amounts
    });
  }

  // Round tiny floating residues to 2 decimals to avoid infinite loops
  net.updateAll((k, v) => _roundTo2(v));

  // Prepare creditors (should receive >0) and debtors (<0)
  final List<MapEntry<String, double>> creditors = // Changed to String
      net.entries.where((e) => e.value > 0.005).toList();
  final List<MapEntry<String, double>> debtors = // Changed to String
      net.entries.where((e) => e.value < -0.005).toList();

  // Sort creditors (largest first) and debtors (most negative first)
  creditors.sort((a, b) => b.value.compareTo(a.value));
  debtors.sort((a, b) => a.value.compareTo(b.value)); // more negative first

  final List<Settlement> settlements = [];

  int ci = 0, di = 0;
  while (ci < creditors.length && di < debtors.length) {
    final credId = creditors[ci].key;
    final debtId = debtors[di].key;
    double credAmt = creditors[ci].value;
    double debtAmt = -debtors[di].value; // positive magnitude

    final double transfer = _roundTo2(min(credAmt, debtAmt));
    if (transfer <= 0) break;

    // debtor pays creditor
    settlements.add(Settlement(fromId: debtId, toId: credId, amount: transfer));

    // update lists
    credAmt = _roundTo2(credAmt - transfer);
    debtAmt = _roundTo2(debtAmt - transfer);

    creditors[ci] = MapEntry(credId, credAmt);
    debtors[di] = MapEntry(debtId, -debtAmt);

    if (credAmt <= 0.005) ci++;
    if (debtAmt <= 0.005) di++;
  }

  // return final net map (rounded)
  final Map<String, double> finalNet = {}; // Changed to String
  net.forEach((k, v) => finalNet[k] = _roundTo2(v));

  return NetSettlementResult(netBalances: finalNet, settlements: settlements);
}

double _roundTo2(double v) => (v * 100).roundToDouble() / 100.0;
String fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';