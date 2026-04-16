import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/services/transaction_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class MoneyOutcomeScreen extends StatefulWidget {
  const MoneyOutcomeScreen({super.key});

  @override
  State<MoneyOutcomeScreen> createState() => _MoneyOutcomeScreenState();
}

class _MoneyOutcomeScreenState extends State<MoneyOutcomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  String _formatDateThai(DateTime date) {
    final thaiYear = date.year + 543;
    return DateFormat('d MMMM', 'th_TH').format(date) + ' $thaiYear';
  }

  String _formatNumber(double value) =>
      NumberFormat('#,##0.00', 'en_US').format(value);

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = Provider.of<TransactionProvider>(context, listen: false);

    final tx = Transaction(
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      type: TransactionType.outcome,
      date: _selectedDate,
      note: '',
    );

    await provider.addTransaction(tx);

    _titleController.clear();
    _amountController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกเงินออกเรียบร้อยแล้ว'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          _header(provider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _date(),
                  const SizedBox(height: 20),
                  _form(),
                  const SizedBox(height: 20),
                  _transactionList(provider),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(TransactionProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3E9E90), Color(0xFF2F8075)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
        const Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Firstname Lastname', style: TextStyle(color: Colors.white)),
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=3'),
              )
            ],
          ),
        ),
          const SizedBox(height: 20),
          Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'ยอดเงินคงเหลือ',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatNumber(provider.totalBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text('ยอดเงินเข้ารวม',
                            style: TextStyle(color: Colors.white70)),
                        Text(
                          _formatNumber(provider.totalIncome),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('ยอดเงินออกรวม',
                            style: TextStyle(color: Colors.white70)),
                        Text(
                          _formatNumber(provider.totalExpense),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );

    
  }

  // ================= DATE =================
  Widget _date() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'วันที่ ${_formatDateThai(DateTime.now())}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'เงินออก',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF3E9E90),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FORM =================
  Widget _form() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _input(_titleController, 'DETAIL'),
            const SizedBox(height: 15),
            _input(_amountController, '0.00', isNumber: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E9E90),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                onPressed: _isSaving ? null : _saveTransaction,
                child: const Text(
                  'บันทึกเงินออก',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= INPUT =================
  Widget _input(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3E9E90)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3E9E90), width: 2),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'กรอกข้อมูล';
        if (isNumber && double.tryParse(v) == null) {
          return 'ตัวเลขไม่ถูกต้อง';
        }
        return null;
      },
    );
  }

  // ================= LIST =================
  Widget _transactionList(TransactionProvider provider) {
    return Column(
      children: provider.outcomeList.map((tx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tx.title),
              Text(
                '-฿${_formatNumber(tx.amount)}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
