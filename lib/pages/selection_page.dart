import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../utils/database_helper.dart';
import '../widgets/ad_banner.dart';
import 'quiz_page.dart';
import 'review_page.dart';

class SelectionPage extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const SelectionPage({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  late FocusNode _focusNode;
  late String _selectedVehicle; // 'motorcycle' or 'car'
  late String _selectedLang; // 'zh' or 'en'
  int _wrongQuestionCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _selectedVehicle = 'motorcycle';
    _selectedLang = widget.currentLocale.languageCode;
    _checkWrongQuestionCount();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SelectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocale.languageCode != _selectedLang) {
      setState(() {
        _selectedLang = widget.currentLocale.languageCode;
      });
    }
  }

  Future<void> _checkWrongQuestionCount() async {
    setState(() {
      _isLoading = true;
    });
    final count = await DatabaseHelper.instance.getWrongQuestionCount();
    if (mounted) {
      setState(() {
        _wrongQuestionCount = count;
        _isLoading = false;
      });
    }
  }

  void _startQuiz() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          selectedVehicle: _selectedVehicle,
          selectedLang: _selectedLang,
          currentLocale: Locale(_selectedLang),
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
    _checkWrongQuestionCount();
  }

  void _openReviewPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(
          currentLocale: Locale(_selectedLang),
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
    _checkWrongQuestionCount();
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMotorcycle = _selectedVehicle == 'motorcycle';

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): _startQuiz,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): _startQuiz,
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E40AF),
                    Color(0xFF2563EB),
                    Color(0xFF0284C7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n?.appTitle ?? 'Driver License Quiz',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AdBanner(),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEEF4FF), Color(0xFFF8FAFC), Colors.white],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    elevation: 8,
                    shadowColor: const Color(
                      0xFF1D4ED8,
                    ).withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(26.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Hero Icon Badge with dynamic gradient based on vehicle
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isMotorcycle
                                      ? const [
                                          Color(0xFFFB923C),
                                          Color(0xFFEA580C),
                                        ]
                                      : const [
                                          Color(0xFF38BDF8),
                                          Color(0xFF2563EB),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isMotorcycle
                                                ? const Color(0xFFEA580C)
                                                : const Color(0xFF2563EB))
                                            .withValues(alpha: 0.32),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isMotorcycle
                                    ? Icons.two_wheeler_rounded
                                    : Icons.directions_car_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // App Title
                          Text(
                            l10n?.appTitle ?? 'Driver License Quiz',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Subtitle Chip
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFDBEAFE),
                                ),
                              ),
                              child: Text(
                                l10n?.appSubtitle ??
                                    'Driver\'s License Written Test Question Bank',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Feature highlights row
                          Row(
                            children: [
                              _buildFeatureBadge(
                                icon: Icons.menu_book_rounded,
                                color: const Color(0xFFD97706),
                                bgColor: const Color(0xFFFEF3C7),
                                label: _selectedLang == 'zh'
                                    ? '完整題庫'
                                    : 'Official',
                              ),
                              const SizedBox(width: 8),
                              _buildFeatureBadge(
                                icon: Icons.timer_outlined,
                                color: const Color(0xFF059669),
                                bgColor: const Color(0xFFD1FAE5),
                                label: _selectedLang == 'zh'
                                    ? '模擬測驗'
                                    : 'Mock Test',
                              ),
                              const SizedBox(width: 8),
                              _buildFeatureBadge(
                                icon: Icons.verified_rounded,
                                color: const Color(0xFF7C3AED),
                                bgColor: const Color(0xFFEDE9FE),
                                label: _selectedLang == 'zh'
                                    ? '即時計分'
                                    : 'Instant Score',
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F5F9),
                          ),
                          const SizedBox(height: 18),

                          // Section Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  size: 16,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n?.selectVehicleAndLanguage ??
                                    'Select Vehicle and Language',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Vehicle Selection Card
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isMotorcycle
                                  ? const Color(0xFFFFF7ED)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isMotorcycle
                                    ? const Color(0xFFFDBA74)
                                    : const Color(0xFF93C5FD),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isMotorcycle
                                              ? const Color(0xFFF97316)
                                              : const Color(0xFF3B82F6))
                                          .withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isMotorcycle
                                        ? const Color(0xFFFFEDD5)
                                        : const Color(0xFFDBEAFE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isMotorcycle
                                        ? Icons.two_wheeler_rounded
                                        : Icons.directions_car_rounded,
                                    color: isMotorcycle
                                        ? const Color(0xFFEA580C)
                                        : const Color(0xFF2563EB),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n?.vehicleLabel ?? 'Vehicle: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          key: const Key('vehicle_dropdown'),
                                          value: _selectedVehicle,
                                          isDense: true,
                                          icon: Icon(
                                            Icons.unfold_more_rounded,
                                            color: isMotorcycle
                                                ? const Color(0xFFEA580C)
                                                : const Color(0xFF2563EB),
                                            size: 20,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          elevation: 4,
                                          items: [
                                            DropdownMenuItem(
                                              value: 'motorcycle',
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.two_wheeler_rounded,
                                                    size: 19,
                                                    color: Color(0xFFEA580C),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    l10n?.vehicleMotorcycle ??
                                                        'Motorcycle',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'car',
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .directions_car_rounded,
                                                    size: 19,
                                                    color: Color(0xFF2563EB),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    l10n?.vehicleCar ?? 'Car',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _selectedVehicle = val;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Language Selection Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFDDD6FE),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ).withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE9FE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.translate_rounded,
                                    color: Color(0xFF7C3AED),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n?.languageLabel ?? 'Language: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          key: const Key('language_dropdown'),
                                          value: _selectedLang,
                                          isDense: true,
                                          icon: const Icon(
                                            Icons.unfold_more_rounded,
                                            color: Color(0xFF7C3AED),
                                            size: 20,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          elevation: 4,
                                          items: [
                                            DropdownMenuItem(
                                              value: 'zh',
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.language_rounded,
                                                    size: 18,
                                                    color: Color(0xFF7C3AED),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    l10n?.languageChinese ??
                                                        'Traditional Chinese',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'en',
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.public_rounded,
                                                    size: 18,
                                                    color: Color(0xFF0284C7),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    l10n?.languageEnglish ??
                                                        'English',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _selectedLang = val;
                                              });
                                              widget.onLocaleChanged(
                                                Locale(val),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Keyboard Hint Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    'Enter ↵',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    l10n?.pressEnterToStart ??
                                        'Press Enter or click below to start quiz',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Start Quiz Button
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2563EB),
                                  Color(0xFF1D4ED8),
                                  Color(0xFF1E40AF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2563EB,
                                  ).withValues(alpha: 0.38),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              key: const Key('start_quiz_button'),
                              onPressed: _startQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n?.startQuiz ?? 'Start Quiz',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Review Wrong Questions Button
                          if (!_isLoading && _wrongQuestionCount > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFFECDD3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE11D48,
                                    ).withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: OutlinedButton(
                                key: const Key('review_button'),
                                onPressed: _openReviewPage,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFE11D48),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.history_rounded,
                                      color: Color(0xFFE11D48),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${l10n?.reviewWrongQuestions ?? "Review Wrong Questions"} ($_wrongQuestionCount)',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE11D48),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE11D48),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$_wrongQuestionCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
