import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
 
class TransactionService {
  final _supabase = Supabase.instance.client;
  static const _table = 'transactions';
 
  // ดึงรายการทั้งหมด
  Future<List<Transaction>> fetchAll() async {
    final response = await _supabase
        .from(_table)
        .select()
        .order('date', ascending: false);
    return (response as List).map((e) => Transaction.fromJson(e)).toList();
  }
 
  // ดึงเฉพาะรายรับ
  Future<List<Transaction>> fetchIncome() async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('type', 'income')
        .order('date', ascending: false);
    return (response as List).map((e) => Transaction.fromJson(e)).toList();
  }
 
  // ดึงเฉพาะรายจ่าย
  Future<List<Transaction>> fetchOutcome() async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('type', 'outcome')
        .order('date', ascending: false);
    return (response as List).map((e) => Transaction.fromJson(e)).toList();
  }
 
  // เพิ่มรายการใหม่
  Future<void> addTransaction(Transaction tx) async {
    await _supabase.from(_table).insert(tx.toJson());
  }
 
  // ลบรายการ
  Future<void> deleteTransaction(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
 
  // คำนวณยอดรวม
  Future<Map<String, double>> getSummary() async {
    final all = await fetchAll();
    double totalIncome = 0;
    double totalOutcome = 0;
    for (var tx in all) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalOutcome += tx.amount;
      }
    }
    return {
      'income': totalIncome,
      'outcome': totalOutcome,
      'balance': totalIncome - totalOutcome,
    };
  }
}
 