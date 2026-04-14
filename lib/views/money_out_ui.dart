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
 
  @override
  void initState() {
    super.initState();
    _loadData();
  }
 
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
 
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final txs = await _service.fetchOutcome();
      setState(() {
        _transactions = txs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('โหลดข้อมูลล้มเหลว: $e');
    }
  }
 
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE53935)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
 
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
 
    setState(() => _isSaving = true);
    try {
      final tx = Transaction(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        type: TransactionType.outcome,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      await _service.addTransaction(tx);
 
      _titleController.clear();
      _amountController.clear();
      _noteController.clear();
      setState(() => _selectedDate = DateTime.now());
 
      await _loadData();
 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ บันทึกรายจ่ายสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('บันทึกล้มเหลว: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }
 
  Future<void> _deleteTransaction(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('ต้องการลบรายการนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.deleteTransaction(id);
      await _loadData();
    }
  }
 
  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }
 
  String _formatNumber(double value) => NumberFormat('#,##0.00', 'en_US').format(value);
  String _formatDate(DateTime date) => DateFormat('d MMM yyyy').format(date);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildForm(),
                    const SizedBox(height: 20),
                    _buildList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFE53935),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Text(
            'รายจ่าย',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${_transactions.length} รายการ',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
 
  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เพิ่มรายจ่ายใหม่',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('ชื่อรายการ', Icons.edit_note),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณาระบุชื่อรายการ' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('จำนวนเงิน (บาท)', Icons.attach_money),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'กรุณาระบุจำนวนเงิน';
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                  return 'กรุณาระบุจำนวนเงินที่ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: _inputDecoration('วันที่', Icons.calendar_today),
                child: Text(_formatDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: _inputDecoration('หมายเหตุ (ถ้ามี)', Icons.note),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('บันทึกรายจ่าย',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFE53935)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
      ),
    );
  }
 
  Widget _buildList() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFE53935)));
    }
    if (_transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('ยังไม่มีรายจ่าย', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }
    return Column(
      children: _transactions.map((tx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
            ],
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.arrow_upward, color: Color(0xFFE53935)),
            ),
            title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_formatDate(tx.date)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '-฿${_formatNumber(tx.amount)}',
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _deleteTransaction(tx.id!),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}