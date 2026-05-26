import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Собираем статистику из сообщений
          final stats = _calculateStats(chatProvider.messages);

          if (stats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Нет данных для статистики',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Отправьте сообщение, чтобы увидеть статистику',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Общие показатели =====
                _buildSummaryCards(stats),
                const SizedBox(height: 24),

                // ===== Статистика по моделям =====
                const Text(
                  'Использование по моделям',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...stats['models']!.map<Widget>((model) => _buildModelCard(
                      model,
                      chatProvider,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  // Сбор статистики из списка сообщений
  Map<String, dynamic> _calculateStats(List messages) {
    if (messages.isEmpty) return {};

    int totalMessages = 0;
    int totalTokens = 0;
    double totalCost = 0;
    final Map<String, Map<String, dynamic>> modelStats = {};

    for (final msg in messages) {
      if (msg.modelId == null) continue;

      totalMessages++;
      if (msg.tokens != null) totalTokens += (msg.tokens! as int);
      if (msg.cost != null) totalCost += msg.cost!;

      if (!modelStats.containsKey(msg.modelId)) {
        modelStats[msg.modelId!] = {
          'modelId': msg.modelId,
          'count': 0,
          'tokens': 0,
          'cost': 0.0,
        };
      }
      modelStats[msg.modelId!]!['count']++;
      if (msg.tokens != null) {
        modelStats[msg.modelId!]!['tokens'] += msg.tokens!;
      }
      if (msg.cost != null) {
        modelStats[msg.modelId!]!['cost'] += msg.cost!;
      }
    }

    // Сортируем по количеству токенов (по убыванию)
    final sortedModels = modelStats.values.toList()
      ..sort((a, b) => (b['tokens'] as int).compareTo(a['tokens'] as int));

    return {
      'totalMessages': totalMessages,
      'totalTokens': totalTokens,
      'totalCost': totalCost,
      'models': sortedModels,
    };
  }

  // Карточки с общими показателями
  Widget _buildSummaryCards(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Сообщений',
            value: stats['totalMessages'].toString(),
            icon: Icons.message,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Токенов',
            value: _formatNumber(stats['totalTokens']),
            icon: Icons.token,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Стоимость',
            value: '\$${stats['totalCost'].toStringAsFixed(4)}',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.roboto(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // Карточка статистики по одной модели
  Widget _buildModelCard(Map<String, dynamic> model, ChatProvider chatProvider) {
    final percentOfTotal = chatProvider.messages.isNotEmpty
        ? ((model['count'] as int) / chatProvider.messages.length * 100)
        : 0.0;

    return Card(
      color: const Color(0xFF333333),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с названием модели
            Row(
              children: [
                Expanded(
                  child: Text(
                    model['modelId'] ?? 'Unknown',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Процент от общего числа сообщений
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${percentOfTotal.toStringAsFixed(1)}%',
                    style: GoogleFonts.roboto(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Показатели в строку
            Row(
              children: [
                _buildMetricChip(
                  icon: Icons.message,
                  label: '${model['count']}',
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                _buildMetricChip(
                  icon: Icons.token,
                  label: _formatNumber(model['tokens']),
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                _buildMetricChip(
                  icon: Icons.attach_money,
                  label: model['cost'] < 0.001
                      ? '<\$0.001'
                      : '\$${model['cost'].toStringAsFixed(4)}',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Форматирование больших чисел
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}