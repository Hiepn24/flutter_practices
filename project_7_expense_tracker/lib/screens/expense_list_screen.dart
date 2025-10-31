import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../boxes.dart';
import 'add_expense_screen.dart';
import '../widgets/expense_chart.dart'; // Import biểu đồ

class ExpenseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: Column(
        children: [
          // 1. Hiển thị Biểu đồ
          ExpenseChart(),

          // 2. Hiển thị Danh sách (tự động cập nhật)
          Expanded(
            child: ValueListenableBuilder<Box<Expense>>(
              valueListenable: expenseBox.listenable(),
              builder: (context, box, _) {
                // Lấy dữ liệu từ box và sắp xếp theo ngày mới nhất
                final expenses = box.values.toList().cast<Expense>();
                expenses.sort((a, b) => b.date.compareTo(a.date));

                if (expenses.isEmpty) {
                  return Center(child: Text('No expenses yet. Add one!'));
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (ctx, index) {
                    final expense = expenses[index];

                    // Dùng Dismissible để cho phép vuốt xóa
                    return Dismissible(
                      key: Key(expense.id), // Key phải là duy nhất
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        // Xóa khỏi Hive box
                        expenseBox.delete(expense.id);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Expense deleted')),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(expense.category.toString()[0]), // Chữ cái đầu
                          ),
                          title: Text(expense.name),
                          subtitle: Text(DateFormat.yMd().format(expense.date)),
                          trailing: Text(
                            '\$${expense.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => AddExpenseScreen()),
          );
        },
      ),
    );
  }
}