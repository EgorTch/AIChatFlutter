import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedPeriod = 'all'; // 'week', 'month', 'all'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Собираем расходы по дням из сообщений
          final dailyExpenses = _calculateDailyExpenses(
            chatProvider.messages,
            chatProvider,
          );

          if (dailyExpenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Нет данных о расходах',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Отправьте сообщение, чтобы увидеть график',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          // Фильтруем по выбранному периоду
          final filtered = _filterByPeriod(dailyExpenses);

          // Общая сумма
          final totalCost = filtered.values.fold(
            0.0,
            (sum, value) => sum + value['cost'],
          );

          final totalTokens = filtered.values.fold(
            0,
            (sum, value) => sum + (value['tokens'] as int),
          );

          return Column(
            children: [
              // ===== Переключатель периода =====
              _buildPeriodSelector(),
              const SizedBox(height: 8),

              // ===== Карточка с итогами =====
              _buildTotalCard(totalCost, totalTokens, chatProvider),
              const SizedBox(height: 16),

              // ===== График =====
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет данных за выбранный период',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      )
                    : _buildChart(filtered, chatProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  // Подсчёт расходов по дням
  Map<String, Map<String, dynamic>> _calculateDailyExpenses(
    List messages,
    ChatProvider chatProvider,
  ) {
    final Map<String, Map<String, dynamic>> daily = {};

    for (final msg in messages) {
      if (msg.isUser || msg.cost == null) continue;

      final dateKey = DateFormat('yyyy-MM-dd').format(msg.timestamp);

      if (!daily.containsKey(dateKey)) {
        daily[dateKey] = {
          'date': msg.timestamp,
          'cost': 0.0,
          'tokens': 0,
          'messages': 0,
        };
      }

      daily[dateKey]!['cost'] += msg.cost!;
      daily[dateKey]!['tokens'] += (msg.tokens ?? 0);
      daily[dateKey]!['messages'] += 1;
    }

    return daily;
  }

  // Фильтрация по периоду
  Map<String, Map<String, dynamic>> _filterByPeriod(
    Map<String, Map<String, dynamic>> daily,
  ) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return Map.fromEntries(
          daily.entries.where((e) =>
              (e.value['date'] as DateTime).isAfter(weekAgo)),
        );
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        return Map.fromEntries(
          daily.entries.where((e) =>
              (e.value['date'] as DateTime).isAfter(monthAgo)),
        );
      default: // 'all'
        return daily;
    }
  }

  // Переключатель периода
  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPeriodButton('Неделя', 'week'),
          const SizedBox(width: 8),
          _buildPeriodButton('Месяц', 'month'),
          const SizedBox(width: 8),
          _buildPeriodButton('Всё время', 'all'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha:0.3)
              : const Color(0xFF333333),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            color: isSelected ? Colors.blue : Colors.white54,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Карточка с итогами
  Widget _buildTotalCard(double totalCost, int totalTokens, ChatProvider chatProvider) {
    final isVsegpt = chatProvider.baseUrl?.contains('vsegpt.ru') == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Общая стоимость
            Column(
              children: [
                Text(
                  isVsegpt
                      ? '${totalCost.toStringAsFixed(2)}₽'
                      : '\$${totalCost.toStringAsFixed(4)}',
                  style: GoogleFonts.roboto(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Общие расходы',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
            // Разделитель
            Container(width: 1, height: 40, color: Colors.white24),
            // Общие токены
            Column(
              children: [
                Text(
                  _formatNumber(totalTokens),
                  style: GoogleFonts.roboto(
                    color: Colors.orange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Всего токенов',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // График
  Widget _buildChart(Map<String, Map<String, dynamic>> data, ChatProvider chatProvider) {
    final entries = data.entries.toList();
    // Сортируем по дате
    entries.sort((a, b) => (a.value['date'] as DateTime)
        .compareTo(b.value['date'] as DateTime));

    final isVsegpt = chatProvider.baseUrl?.contains('vsegpt.ru') == true;

    // Находим максимальное значение для оси Y
    double maxY = 0;
    for (final entry in entries) {
      final cost = entry.value['cost'] as double;
      if (cost > maxY) maxY = cost;
    }
    // Добавляем 20% отступа
    maxY = maxY == 0 ? 1.0 : maxY * 1.3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        color: const Color(0xFF333333),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final entry = entries[group.x.toInt()];
                    final date =
                        DateFormat('dd.MM.yyyy').format(entry.value['date']);
                    final cost = entry.value['cost'] as double;
                    return BarTooltipItem(
                      '$date\n${isVsegpt ? "${cost.toStringAsFixed(4)}₽" : "\$${cost.toStringAsFixed(6)}"}',
                      GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final entry = entries[value.toInt()];
                      final date = entry.value['date'] as DateTime;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat('dd.MM').format(date),
                          style: GoogleFonts.roboto(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Text(
                        isVsegpt
                            ? '${value.toStringAsFixed(2)}₽'
                            : '\$${value.toStringAsFixed(3)}',
                        style: GoogleFonts.roboto(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white10,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: entries.asMap().entries.map((e) {
                final index = e.key;
                final cost = e.value.value['cost'] as double;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: cost,
                      color: Colors.blue,
                      width: entries.length > 15 ? 12 : 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}