import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ProviderScreen extends StatefulWidget {
  const ProviderScreen({super.key});

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  final _openRouterKeyController = TextEditingController();
  final _vsegptKeyController = TextEditingController();
  final _openRouterUrlController = TextEditingController();
  final _vsegptUrlController = TextEditingController();
  bool _showOpenRouterKey = false;
  bool _showVsegptKey = false;

  @override
  void initState() {
    super.initState();
    // Загружаем текущие значения из .env (только для отображения)
    _openRouterKeyController.text = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    _vsegptKeyController.text = dotenv.env['VSEGPT_API_KEY'] ?? '';
    _openRouterUrlController.text =
        dotenv.env['BASE_URL'] ?? 'https://openrouter.ai/api/v1';
    _vsegptUrlController.text =
        dotenv.env['VSEGPT_BASE_URL'] ?? 'https://api.vsegpt.ru/v1';
  }

  @override
  void dispose() {
    _openRouterKeyController.dispose();
    _vsegptKeyController.dispose();
    _openRouterUrlController.dispose();
    _vsegptUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Информация о приложении =====
            _buildInfoCard(),
            const SizedBox(height: 24),

            // ===== OpenRouter =====
            _buildProviderCard(
              title: 'OpenRouter',
              icon: Icons.router,
              color: Colors.blue,
              description: 'Доступ к 200+ моделям через единый API',
              urlController: _openRouterUrlController,
              keyController: _openRouterKeyController,
              showKey: _showOpenRouterKey,
              onToggleKey: () => setState(() => _showOpenRouterKey = !_showOpenRouterKey),
            ),
            const SizedBox(height: 16),

            // ===== VSEGPT =====
            _buildProviderCard(
              title: 'VSEGPT',
              icon: Icons.api,
              color: Colors.purple,
              description: 'Российский агрегатор AI-моделей',
              urlController: _vsegptUrlController,
              keyController: _vsegptKeyController,
              showKey: _showVsegptKey,
              onToggleKey: () => setState(() => _showVsegptKey = !_showVsegptKey),
            ),
            const SizedBox(height: 24),

            // ===== Текущий статус =====
            _buildStatusCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: const Color(0xFF333333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Настройка провайдеров',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'API ключи хранятся в файле .env.\nДля смены провайдера измените BASE_URL.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required TextEditingController urlController,
    required TextEditingController keyController,
    required bool showKey,
    required VoidCallback onToggleKey,
  }) {
    return Card(
      color: const Color(0xFF333333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок провайдера
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Индикатор активности
                Consumer<ChatProvider>(
                  builder: (context, provider, _) {
                    final isActive = (title == 'OpenRouter' &&
                            provider.baseUrl?.contains('openrouter') == true) ||
                        (title == 'VSEGPT' &&
                            provider.baseUrl?.contains('vsegpt') == true);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'Активен' : 'Неактивен',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // URL
            const Text(
              'URL:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: urlController,
              readOnly: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF424242),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white54),
                  onPressed: () {
                    // Копирование URL
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // API ключ
            const Text(
              'API ключ:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: keyController,
              readOnly: true,
              obscureText: !showKey,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF424242),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: IconButton(
                  icon: Icon(
                    showKey ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: Colors.white54,
                  ),
                  onPressed: onToggleKey,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ключ загружается из .env файла',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return Card(
          color: const Color(0xFF333333),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Текущее подключение',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusRow('Провайдер', chatProvider.baseUrl ?? 'Не указан'),
                _buildStatusRow('Баланс', chatProvider.balance),
                _buildStatusRow('Модель', chatProvider.currentModel ?? 'Не выбрана'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}