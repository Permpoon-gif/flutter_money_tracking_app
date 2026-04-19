import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/services/transaction_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';

class MoneyIncomeScreen extends StatefulWidget {
  const MoneyIncomeScreen({super.key});

  @override
  State<MoneyIncomeScreen> createState() => _MoneyIncomeScreenState();
}

class _MoneyIncomeScreenState extends State<MoneyIncomeScreen> {
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
      type: TransactionType.income,
      date: _selectedDate,
      note: '',
    );

    await provider.addTransaction(tx);

    _titleController.clear();
    _amountController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกเงินเข้าเรียบร้อยแล้ว'),
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
    return Stack(
      children: [
        Container(
          height: 260,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 91, 117, 231),
                Color.fromARGB(255, 198, 235, 255)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),

        // user row
        const Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Permpoom Chouton', style: TextStyle(color: Colors.white)),
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/permpoon.png'),
              ),
            ],
          ),
        ),

        // card balance
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
                const Text('ยอดเงินคงเหลือ',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                Text(
                  _formatNumber(provider.totalBalance),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'ยอดเงินเข้ารวม',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.green,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatNumber(provider.totalIncome),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'ยอดเงินออกรวม',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
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
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _miniInfo(String title, double value) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          _formatNumber(value),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
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
            'เงินเข้า',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายการเงินเข้า',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            _input(_titleController, 'DETAIL'),
            const SizedBox(height: 15),
            const Text(
              'จํานวนเงิน',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            _input(_amountController, '0.00', isNumber: true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 81, 204, 186),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                onPressed: _isSaving ? null : _saveTransaction,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'บันทึกเงินเข้า',
                        style: TextStyle(
                          color: Colors.white,
                        ),
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
    if (provider.incomeList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text('ยังไม่มีรายการ'),
      );
    }

    return Column(
      children: provider.incomeList.map((tx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
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
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            // 🔵 วงกลมไอคอน
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade50,
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: Colors.green,
              ),
            ),

            // 📄 ข้อมูลรายการ
            title: Text(tx.title),
            subtitle: Text(
              _formatDateThai(tx.date),
              style: const TextStyle(fontSize: 12),
            ),

            // 💰 จำนวนเงิน
            trailing: Text(
              '+฿${_formatNumber(tx.amount)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
