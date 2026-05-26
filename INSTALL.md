# Инструкция по установке AI Chat Flutter

## Системные требования

### Общие требования
- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.6.0
- Git
- VS Code или Android Studio (рекомендуется)

### Windows
- Windows 10 или выше
- Visual Studio 2019 или выше с Desktop development with C++ workload
- Windows 10 SDK

### Android
- Android Studio
- Android SDK
- Java Development Kit (JDK)

### iOS (для сборки под iOS)
- macOS с Xcode
- CocoaPods

---

## Быстрая установка

```bash
# 1. Клонируйте репозиторий
git clone https://github.com/neuro-fill/AIChatFlutter.git
cd AIChatFlutter

# 2. Установите зависимости
flutter pub get

# 3. Настройте переменные окружения
cp .env.example .env
# Отредактируйте .env и добавьте ваш API ключ

# 4. Запустите приложение
flutter run

Подробная установка
1. Установка Flutter SDK
Скачайте Flutter SDK с официального сайта, добавьте Flutter в PATH и выполните:
flutter doctor

Следуйте инструкциям для установки недостающих компонентов.

2. Клонирование репозитория

git clone https://github.com/neuro-fill/AIChatFlutter.git
cd AIChatFlutter

3. Настройка переменных окружения

Создайте файл .env на основе .env.example:
cp .env.example .env

Отредактируйте .env и добавьте ваши API ключи:

# ===== OpenRouter (обязательно) =====
OPENROUTER_API_KEY=ваш_openrouter_ключ_здесь
BASE_URL=https://openrouter.ai/api/v1

# ===== VSEGPT (опционально) =====
VSEGPT_API_KEY=ваш_vsegpt_ключ_здесь
VSEGPT_BASE_URL=https://api.vsegpt.ru/v1

# ===== Общие настройки =====
DEBUG=False
LOG_LEVEL=INFO
MAX_TOKENS=1000
TEMPERATURE=0.7

Переменная	Обязательно	Где получить
OPENROUTER_API_KEY	✅ Да	openrouter.ai/keys
BASE_URL	✅ Да	Оставить по умолчанию
VSEGPT_API_KEY	❌ Нет	vsegpt.ru
VSEGPT_BASE_URL	❌ Нет	Оставить по умолчанию
MAX_TOKENS	❌ Нет	Максимум токенов в ответе
TEMPERATURE	❌ Нет	Креативность ответов (0-1)

⚠️ Важно: Файл .env добавлен в .gitignore и никогда не загружается в репозиторий.

4. Установка зависимостей

flutter pub get

5. Настройка VSCode (опционально)
Установите расширения Flutter и Dart

Настройте форматирование кода (рекомендуется dart format)

Настройка окружения для сборки
Windows
Установите Visual Studio с компонентами:

Desktop development with C++

Windows 10 SDK

Visual C++ tools for CMake

Включите режим разработчика:

Настройки → Обновление и безопасность → Для разработчиков

Включите «Режим разработчика»

Включите поддержку Windows desktop:

flutter config --enable-windows-desktop
flutter doctor -v

Android
Установите Android Studio

В SDK Manager установите:

Android SDK Build-Tools

Android SDK Command-line Tools

Android SDK Platform-Tools

Установите Flutter и Dart плагины

Создайте эмулятор через Device Manager

Linux
Установите зависимости:

sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev

Включите поддержку Linux desktop:
flutter config --enable-linux-desktop

Сборка приложения
Android

# Debug версия
flutter build apk --debug

# Release версия
flutter build apk --release

# Split APKs (оптимизированный размер)
flutter build apk --split-per-abi

iOS

# Debug версия
flutter build ios --debug

# Release версия
flutter build ios --release

# IPA файл
flutter build ipa

Windows

flutter build windows

Linux

flutter build linux

Расположение собранных файлов
Платформа	Путь
Android Debug	build/app/outputs/flutter-apk/app-debug.apk
Android Release	build/app/outputs/flutter-apk/app-release.apk
iOS IPA	build/ios/ipa/Runner.ipa
Windows	build/windows/runner/Release/
Linux	build/linux/x64/release/bundle/

Запуск в эмуляторе Android
Создайте эмулятор в Android Studio:

Tools → Device Manager → Create Device

Выберите устройство (например, Pixel 6)

Выберите образ системы (API 33+)

Нажмите Finish

Запустите эмулятор и выполните:

flutter run

Горячие клавиши во время отладки:

r — Hot reload (быстрая перезагрузка)

R — Полная перезагрузка

q — Выход

Проверка установки

# Проверка Flutter
flutter doctor

# Проверка анализа кода
flutter analyze

# Тестовый запуск
flutter run

Если всё установлено правильно, приложение запустится с 4 вкладками:

💬 Чат — общение с AI

🔌 Провайдеры — настройки подключения

📊 Статистика — использование токенов

📈 Расходы — график затрат

Устранение неполадок
Ошибка	Решение
API key not found	Проверьте, что .env создан и содержит OPENROUTER_API_KEY
flutter: command not found	Добавьте Flutter в PATH
No connected devices	Запустите эмулятор или подключите устройство
Build failed	Выполните flutter clean && flutter pub get
402 Insufficient credits	Пополните баланс на openrouter.ai/settings/credits