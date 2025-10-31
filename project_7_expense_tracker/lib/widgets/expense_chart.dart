import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../boxes.dart';

class ExpenseChart extends StatelessWidget {
  // Helper map để gán màu cho từng danh mục
  final Map<ExpenseCategory, Color> categoryColors = {
    ExpenseCategory.Food: Colors.redAccent,
    ExpenseCategory.Transport: Colors.blueAccent,
    ExpenseCategory.Work: Colors.greenAccent,
    ExpenseCategory.Fun: Colors.purpleAccent,
  };

  @override
  Widget build(BuildContext context) {
    // 1. Dùng ValueListenableBuilder để tự động cập nhật
    //    khi dữ liệu trong 'expenseBox' thay đổi
    return ValueListenableBuilder<Box<Expense>>(
      valueListenable: expenseBox.listenable(),
      builder: (context, box, _) {
        final expenses = box.values.toList().cast<Expense>();

        // 2. Xử lý dữ liệu để tính tổng cho mỗi danh mục
        Map<ExpenseCategory, double> categoryTotals = {};
        for (var category in ExpenseCategory.values) {
          categoryTotals[category] = 0.0;
        }

        double totalExpense = 0.0;
        for (var expense in expenses) {
          categoryTotals[expense.category] =
              (categoryTotals[expense.category] ?? 0) + expense.amount;
          totalExpense += expense.amount;
        }

        // 3. Tạo các "lát cắt" (sections) cho biểu đồ tròn
        List<PieChartSectionData> sections = [];
        if (totalExpense == 0) {
          // Nếu không có dữ liệu, hiển thị biểu đồ rỗng
          sections.add(PieChartSectionData(
            value: 1,
            color: Colors.grey[300],
            title: 'No Data',
            radius: 60,
            titleStyle: TextStyle(fontSize: 14, color: Colors.black),
          ));
        } else {
          categoryTotals.forEach((category, amount) {
            if (amount > 0) {
              final percentage = (amount / totalExpense) * 100;
              sections.add(PieChartSectionData(
                value: amount,
                color: categoryColors[category],
                title: '${percentage.toStringAsFixed(1)}%',
                radius: 60,
                titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ));
            }
          });
        }

        // 4. Yêu cầu: Trả về widget fl_chart
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Expense Breakdown', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Chú thích (Legend)
                _buildLegend(),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget helper để vẽ chú thích
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categoryColors.entries.map((entry) {
        return Row(
          children: [
            Container(width: 16, height: 16, color: entry.value),
            SizedBox(width: 5),
            Text(entry.key.toString().split('.').last),
          ],
        );
      }).toList(),
    );
  }
}