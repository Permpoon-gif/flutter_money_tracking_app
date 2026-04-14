enum TransactionType { income, outcome }
 
class Transaction {
  final String? id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? note;
 
  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });
 
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.outcome,
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }
 
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'outcome',
      'date': date.toIso8601String().split('T')[0],
      'note': note,
    };
  }
}