import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final _service = TransactionService();

  double totalIncome = 0;
  double totalExpense = 0;
  double totalBalance = 0;

  List<Transaction> incomeList = [];
  List<Transaction> outcomeList = [];

  bool isLoading = false;

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();

    final summary = await _service.getSummary();
    incomeList = await _service.fetchIncome();
    outcomeList = await _service.fetchOutcome();

    totalIncome = summary['income'] ?? 0;
    totalExpense = summary['outcome'] ?? 0;
    totalBalance = summary['balance'] ?? 0;

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction tx) async {
    await _service.addTransaction(tx);

    if (tx.type == TransactionType.income) {
      totalIncome += tx.amount;
      totalBalance += tx.amount;
      incomeList.insert(0, tx);
    } else {
      totalExpense += tx.amount;
      totalBalance -= tx.amount;
      outcomeList.insert(0, tx);
    }

    notifyListeners(); // 🔥 สำคัญมาก
  }
}
