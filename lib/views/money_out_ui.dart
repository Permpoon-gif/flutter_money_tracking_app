// lib/screens/money_outcome_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class MoneyOutcomeScreen extends StatefulWidget {
  const MoneyOutcomeScreen({super.key});

  @override
  State<MoneyOutcomeScreen> createState() => _MoneyOutcomeScreenState();
}

class _MoneyOutcomeScreenState extends State<MoneyOutcomeScreen> {
  final _service = TransactionService();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  List<Transaction> _transactions = [];
  bool _isLoading = true;
  bool _isSaving = false;

  DateTime _selectedDate = DateTime.now();

  double totalIncome = 0;
  double totalExpense = 0;
  double totalBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatNumber(double value) =>
      NumberFormat('#,##0.00', 'en_US').format(value);

  String _formatDateThai(DateTime date) {
    final thaiYear = date.year + 543;
    return DateFormat('d MMMM', 'th_TH').format(date) + ' $thaiYear';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final summary = await _service.getSummary();
      final txs = await _service.fetchOutcome();

      setState(() {
        totalIncome = summary['income'] ?? 0;
        totalExpense = summary['outcome'] ?? 0;
        totalBalance = summary['balance'] ?? 0;

        _transactions = txs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // ✅ เพิ่ม SnackBar ตรงนี้
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final tx = Transaction(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        type: TransactionType.outcome,
        date: _selectedDate,
        note: _noteController.text,
      );

      await _service.addTransaction(tx);

// ✅ อัปเดตค่าแบบทันที
      setState(() {
        totalExpense += tx.amount;
        totalBalance -= tx.amount;

        _transactions.insert(0, tx); // เพิ่มรายการด้านบน
      });

// ล้างค่า
      _titleController.clear();
      _amountController.clear();
      _noteController.clear();

// ค่อย sync ใหม่ (กันข้อมูลเพี้ยน)
      await _loadData();

      // ✅ แจ้งเตือนสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกเงินออกเรียบร้อยแล้ว'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // ❌ แจ้งเตือน error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _form(),
                        const SizedBox(height: 20),
                        _transactionList(),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _header() {
    return Stack(
      children: [
        Container(
          height: 260,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2DB89D), Color(0xFF1FAF8B)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2DB89D),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'ยอดคงเหลือ',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 5),
                Text(
                  '฿${_formatNumber(totalBalance)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _miniInfo('รายรับ', totalIncome, Colors.green),
                    _miniInfo('รายจ่าย', totalExpense, Colors.red),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _miniInfo(String title, double value, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.white24,
          child: Icon(Icons.circle, size: 10, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(
              '฿${_formatNumber(value)}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }

  Widget _form() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text(
          'วันที่ ${_formatDateThai(_selectedDate)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          'เงินออก',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _input(_titleController, 'รายละเอียด'),
                const SizedBox(height: 10),
                _input(_amountController, 'จำนวนเงิน', isNumber: true),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DB89D),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'บันทึกเงินออก',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _input(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _decoration(label),
      validator: (v) {
        if (v == null || v.isEmpty) return 'กรอกข้อมูล';
        if (isNumber && double.tryParse(v) == null) {
          return 'ตัวเลขไม่ถูกต้อง';
        }
        return null;
      },
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _transactionList() {
    if (_transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text('ยังไม่มีรายการ'),
      );
    }

    return Column(
      children: _transactions.map((tx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.red),
            title: Text(tx.title),
            subtitle: Text(_formatDateThai(tx.date)),
            trailing: Text(
              '-฿${_formatNumber(tx.amount)}',
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}
