import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StockAiReportQuestionsScreen
    extends StatefulWidget {
  final String company;
  final String symbol;
  final double currentPrice;

  const StockAiReportQuestionsScreen({
    super.key,
    required this.company,
    required this.symbol,
    required this.currentPrice,
  });

  @override
  State<StockAiReportQuestionsScreen>
  createState() =>
      _StockAiReportQuestionsScreenState();
}



/// Backward-compatible alias for older imports/usages.
typedef StockAiReportQuestion = StockAiReportQuestionsScreen;
class _StockAiReportQuestionsScreenState
    extends State<
        StockAiReportQuestionsScreen> {
  static const Color primary =
  Color(0xff18C48F);

  static const int reportCost = 100;

  static const String apiBaseUrl =
      'https://aitradex-api.onrender.com/api';

  final TextEditingController
  _averagePriceController =
  TextEditingController();

  final TextEditingController
  _quantityController =
  TextEditingController();

  bool _ownsStock = false;

  String? _investmentHorizon;

  bool _isSubmitting = false;
  bool _isCheckingCoins = false;

  int _currentStep = 0;

  int _coinBalance = 0;

  @override
  void dispose() {
    _averagePriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // ==========================================================
  // FIREBASE TOKEN
  // ==========================================================

  Future<String> _firebaseToken() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'Please sign in again.',
      );
    }

    final String? token =
    await user.getIdToken(true);

    if (token == null ||
        token.isEmpty) {
      throw Exception(
        'Authentication expired. Please sign in again.',
      );
    }

    return token;
  }

  // ==========================================================
  // CHECK COIN BALANCE
  // ==========================================================

  Future<int> _loadCoinBalance() async {
    final String token =
    await _firebaseToken();

    final http.Response response =
    await http.get(
      Uri.parse(
        '$apiBaseUrl/coins/balance',
      ),
      headers: <String, String>{
        'Authorization':
        'Bearer $token',
        'Content-Type':
        'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    dynamic decoded;

    try {
      decoded =
          jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode != 200) {
      throw Exception(
        decoded is Map
            ? decoded['message']?.toString() ??
            'Unable to load coin balance.'
            : 'Unable to load coin balance.',
      );
    }

    int balance = 0;

    if (decoded is Map) {
      final dynamic direct =
      decoded['balance'];

      final dynamic data =
      decoded['data'];

      if (direct is num) {
        balance =
            direct.toInt();
      } else if (data is Map &&
          data['balance'] is num) {
        balance =
            (data['balance'] as num)
                .toInt();
      }
    }

    if (mounted) {
      setState(() {
        _coinBalance = balance;
      });
    }

    return balance;
  }

  // ==========================================================
  // NEXT
  // ==========================================================

  void _next() {
    if (_currentStep == 0) {
      _currentStep = 1;

      setState(() {});

      return;
    }

    if (_currentStep == 1) {
      _currentStep = 2;

      setState(() {});

      return;
    }
  }

  // ==========================================================
  // VALIDATION
  // ==========================================================

  bool _validateStepThree() {
    if (_ownsStock) {
      final double? averagePrice =
      double.tryParse(
        _averagePriceController
            .text
            .trim(),
      );

      final double? quantity =
      double.tryParse(
        _quantityController.text
            .trim(),
      );

      if (averagePrice == null ||
          averagePrice <= 0) {
        _showMessage(
          'Please enter a valid average buying price.',
        );

        return false;
      }

      if (quantity == null ||
          quantity <= 0) {
        _showMessage(
          'Please enter a valid quantity.',
        );

        return false;
      }

      return true;
    }

    if (_investmentHorizon ==
        null) {
      _showMessage(
        'Please select your investment horizon.',
      );

      return false;
    }

    return true;
  }

  // ==========================================================
  // SUBMIT
  // ==========================================================

  Future<void> _submitReport() async {
    if (!_validateStepThree() || _isSubmitting) return;

    HapticFeedback.mediumImpact();
    setState(() => _isCheckingCoins = true);

    try {
      // 1. Fresh balance check before starting the report.
      final int balance = await _loadCoinBalance();
      if (balance < reportCost) {
        if (mounted) setState(() => _isCheckingCoins = false);
        _showInsufficientCoins(balance);
        return;
      }

      setState(() {
        _isCheckingCoins = false;
        _isSubmitting = true;
      });

      // 2. Generate the report BEFORE charging. If AI fails, the user
      // keeps all coins and can retry safely.
      final String report = await _generateReport();

      // 3. Final server-side atomic unlock/charge. The backend guarantees
      // one charge per user + stock symbol and creates the coin ledger entry.
      final String token = await _firebaseToken();
      final http.Response unlockResponse = await http.post(
        Uri.parse('$apiBaseUrl/coins/unlock-stock'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{'symbol': widget.symbol}),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception(
          'Unlock request timed out. Check your coin balance before retrying.',
        ),
      );

      dynamic unlockData;
      try {
        unlockData = jsonDecode(unlockResponse.body);
      } catch (_) {
        unlockData = null;
      }

      if (unlockResponse.statusCode == 402) {
        final int latestBalance = _extractBalance(
          unlockData,
          fallback: balance,
        );
        if (mounted) {
          setState(() {
            _coinBalance = latestBalance;
            _isSubmitting = false;
          });
        }
        _showInsufficientCoins(latestBalance);
        return;
      }

      if (unlockResponse.statusCode == 401 ||
          unlockResponse.statusCode == 403) {
        throw Exception(
          unlockData is Map
              ? unlockData['message']?.toString() ?? 'Authentication failed.'
              : 'Authentication failed.',
        );
      }

      if (unlockResponse.statusCode != 200) {
        throw Exception(
          unlockData is Map
              ? unlockData['message']?.toString() ??
              'Unable to unlock the stock report.'
              : 'Unable to unlock the stock report.',
        );
      }

      final int remainingCoins = _extractBalance(
        unlockData,
        fallback: balance,
      );

      if (mounted) {
        setState(() {
          _coinBalance = remainingCoins;
          _isSubmitting = false;
        });
      }

      // 4. Save the completed report only after the backend unlock succeeds.
      await _saveCompletedReport(
        report: report,
        remainingCoins: remainingCoins,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => StockAiReportScreen(
            company: widget.company,
            symbol: widget.symbol,
            report: report,
            remainingCoins: remainingCoins,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCheckingCoins = false;
        _isSubmitting = false;
      });
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ==========================================================
  // SAVE COMPLETED REPORT FOR MY REPORTS
  // ==========================================================

  Future<void> _saveCompletedReport({
    required String report,
    required int remainingCoins,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? uid = user?.uid;
    if (uid == null || uid.trim().isEmpty) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'aitradex_my_reports_${uid.trim()}';
    final List<String> raw = prefs.getStringList(key) ?? <String>[];
    final List<Map<String, dynamic>> reports = <Map<String, dynamic>>[];

    for (final String item in raw) {
      try {
        final dynamic decoded = jsonDecode(item);
        if (decoded is Map) {
          reports.add(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }

    reports.removeWhere(
          (item) =>
      item['symbol']?.toString().toUpperCase() ==
          widget.symbol.toUpperCase(),
    );

    final DateTime now = DateTime.now();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final String date =
        '${twoDigits(now.day)} ${_monthName(now.month)} ${now.year}, '
        '${twoDigits(now.hour)}:${twoDigits(now.minute)}';

    reports.insert(0, <String, dynamic>{
      'symbol': widget.symbol,
      'company': widget.company,
      'logo': widget.symbol.length >= 3 ? widget.symbol.substring(0, 3) : widget.symbol,
      'date': date,
      'report': report,
      'remainingCoins': remainingCoins,
    });

    if (reports.length > 30) {
      reports.removeRange(30, reports.length);
    }

    await prefs.setStringList(
      key,
      reports.map((item) => jsonEncode(item)).toList(),
    );
  }

  String _monthName(int month) {
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  // ==========================================================
  // GENERATE REPORT
  // ==========================================================

  Future<String> _generateReport() async {
    final String token =
    await _firebaseToken();

    final String ownership =
    _ownsStock
        ? 'Yes'
        : 'No';

    final String message;

    if (_ownsStock) {
      message = '''
Create a personalized AiTradeX stock report.

Stock:
${widget.company} (${widget.symbol})

Current market price:
₹${widget.currentPrice.toStringAsFixed(2)}

User owns this stock:
Yes

Average buying price:
₹${_averagePriceController.text.trim()}

Quantity:
${_quantityController.text.trim()}

Analyze the position and provide:
1. Current position overview
2. Buy / Hold / Sell consideration
3. Important risks
4. Key things to monitor
5. Suggested action
6. Short-term and medium-term outlook

Clearly state that this is AI-generated information and not guaranteed financial advice.
''';
    } else {
      message = '''
Create a personalized AiTradeX stock report.

Stock:
${widget.company} (${widget.symbol})

Current market price:
₹${widget.currentPrice.toStringAsFixed(2)}

User owns this stock:
No

Investment horizon:
$_investmentHorizon

Analyze whether this stock may fit the user's stated horizon.

Provide:
1. Stock overview
2. Buy / Wait / Avoid consideration
3. Important risks
4. Key things to monitor
5. Possible entry considerations
6. Outlook for the selected horizon

Clearly state that this is AI-generated information and not guaranteed financial advice.
''';
    }

    final http.Response response =
    await http.post(
      Uri.parse(
        '$apiBaseUrl/ai/chat',
      ),
      headers: <String, String>{
        'Authorization':
        'Bearer $token',
        'Content-Type':
        'application/json',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': message,
          'userId':
          FirebaseAuth
              .instance
              .currentUser
              ?.uid,
          'expenses': <dynamic>[],
          'income': 0,
        },
      ),
    ).timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw Exception(
        'Report generation timed out. No coins have been charged. Please retry.',
      ),
    );

    dynamic decoded;

    try {
      decoded =
          jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode !=
        200 ||
        decoded is! Map ||
        decoded['success'] !=
            true) {
      throw Exception(
        decoded is Map
            ? decoded['error']
            ?.toString() ??
            decoded['message']
                ?.toString() ??
            'Unable to generate stock report.'
            : 'Unable to generate stock report.',
      );
    }

    final String report = decoded['reply']?.toString().trim() ?? '';
    if (report.isEmpty || report == 'No report was generated.') {
      throw Exception(
        'The AI service returned an empty report. No coins have been charged. Please retry.',
      );
    }
    return report;
  }

  // ==========================================================
  // BALANCE EXTRACTION
  // ==========================================================

  int _extractBalance(
      dynamic data, {
        required int fallback,
      }) {
    if (data is! Map) {
      return fallback;
    }

    final dynamic root =
    data['balance'];

    if (root is num) {
      return root.toInt();
    }

    final dynamic nested =
    data['data'];

    if (nested is Map &&
        nested['balance'] is num) {
      return (nested['balance']
      as num)
          .toInt();
    }

    return fallback;
  }

  // ==========================================================
  // INSUFFICIENT COINS
  // ==========================================================

  void _showInsufficientCoins(
      int balance,
      ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor:
      Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        final ColorScheme colors =
            Theme.of(context)
                .colorScheme;

        return Container(
          padding:
          const EdgeInsets.fromLTRB(
            22,
            18,
            22,
            28,
          ),
          decoration:
          BoxDecoration(
            color: colors.surface,
            borderRadius:
            const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 5,
                  decoration:
                  BoxDecoration(
                    color: colors
                        .onSurface
                        .withValues(
                      alpha: 0.15,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                Container(
                  width: 58,
                  height: 58,
                  decoration:
                  BoxDecoration(
                    color: Colors.orange
                        .withValues(
                      alpha: 0.12,
                    ),
                    shape:
                    BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .account_balance_wallet_rounded,
                    color:
                    Colors.orange,
                    size: 28,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  'Not enough AiTradeX Coins',
                  textAlign:
                  TextAlign.center,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  'This stock report requires '
                      '$reportCost Coins.',
                  textAlign:
                  TextAlign.center,
                  style:
                  GoogleFonts.poppins(
                    fontSize: 12,
                    color: colors
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  'Your balance: $balance Coins',
                  style:
                  GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                    color: primary,
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  height: 50,
                  child:
                  FilledButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop();
                    },
                    child:
                    const Text(
                      'Go to AiTradeX Coins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final ThemeData theme =
    Theme.of(context);

    final ColorScheme colors =
        theme.colorScheme;

    return Scaffold(
      backgroundColor:
      colors.surface,

      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Ask AiTradeX Bot',
          style:
          GoogleFonts.poppins(
            fontSize: 18,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildProgress(),

            Expanded(
              child:
              AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds: 250,
                ),
                child:
                _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PROGRESS
  // ==========================================================

  Widget _buildProgress() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        10,
      ),
      child: Row(
        children: List<Widget>.generate(
          3,
              (int index) {
            final bool active =
                index <= _currentStep;

            return Expanded(
              child: Container(
                height: 5,
                margin:
                EdgeInsets.only(
                  right:
                  index == 2
                      ? 0
                      : 5,
                ),
                decoration:
                BoxDecoration(
                  color: active
                      ? primary
                      : primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // CURRENT STEP
  // ==========================================================

  Widget _buildCurrentStep() {
    if (_currentStep == 0) {
      return _buildStockQuestion();
    }

    if (_currentStep == 1) {
      return _buildOwnershipQuestion();
    }

    return _buildFinalQuestion();
  }

  // ==========================================================
  // QUESTION 1
  // ==========================================================

  Widget _buildStockQuestion() {
    return _QuestionLayout(
      key: const ValueKey(
        'stock-question',
      ),
      question:
      'Which stock should AiTradeX Bot help you with?',
      subtitle:
      'We will use the stock you are currently viewing.',
      child: Container(
        padding:
        const EdgeInsets.all(18),
        decoration:
        BoxDecoration(
          color: primary.withValues(
            alpha: 0.07,
          ),
          borderRadius:
          BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: primary.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration:
              const BoxDecoration(
                color: primary,
                shape:
                BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.symbol.trim().isEmpty
                      ? '?'
                      : widget.symbol.trim().substring(0, 1).toUpperCase(),
                  style:
                  GoogleFonts.poppins(
                    color:
                    Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 13,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: <Widget>[
                  Text(
                    widget.company,
                    style:
                    GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    widget.symbol,
                    style:
                    GoogleFonts.poppins(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.check_circle_rounded,
              color: primary,
            ),
          ],
        ),
      ),
      buttonText: 'Continue',
      onPressed: _next,
    );
  }

  // ==========================================================
  // QUESTION 2
  // ==========================================================

  Widget _buildOwnershipQuestion() {
    return _QuestionLayout(
      key: const ValueKey(
        'ownership-question',
      ),
      question:
      'Do you own this stock already?',
      subtitle:
      '${widget.company} (${widget.symbol})',
      child: Column(
        children: <Widget>[
          _ChoiceCard(
            title: 'Yes',
            subtitle:
            'I already own this stock.',
            icon:
            Icons.inventory_2_rounded,
            selected:
            _ownsStock,
            onTap: () {
              HapticFeedback.selectionClick();

              setState(() {
                _ownsStock = true;
              });
            },
          ),

          const SizedBox(
            height: 12,
          ),

          _ChoiceCard(
            title: 'No',
            subtitle:
            'I do not own this stock yet.',
            icon:
            Icons.add_chart_rounded,
            selected:
            !_ownsStock,
            onTap: () {
              HapticFeedback.selectionClick();

              setState(() {
                _ownsStock = false;
              });
            },
          ),
        ],
      ),
      buttonText: 'Continue',
      onPressed: _next,
    );
  }

  // ==========================================================
  // QUESTION 3
  // ==========================================================

  Widget _buildFinalQuestion() {
    if (_ownsStock) {
      return _QuestionLayout(
        key: const ValueKey(
          'owned-question',
        ),
        question:
        'Please enter your average buying price & quantity of stock',
        subtitle:
        'This helps AiTradeX Bot understand your current position.',
        child: Column(
          children: <Widget>[
            _InputField(
              controller:
              _averagePriceController,
              label:
              'Average buying price',
              hint:
              'Example: 1226.00',
              prefix:
              '₹ ',
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            _InputField(
              controller:
              _quantityController,
              label:
              'Quantity',
              hint:
              'Example: 10',
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        buttonText:
        'Generate Report • 100 Coins',
        loading:
        _isCheckingCoins ||
            _isSubmitting,
        onPressed:
        _submitReport,
      );
    }

    return _QuestionLayout(
      key: const ValueKey(
        'not-owned-question',
      ),
      question:
      'Okay, for how long do you want to invest in this stock?',
      subtitle:
      'Choose the investment horizon you want the report to consider.',
      child: Column(
        children: <Widget>[
          _HorizonCard(
            title: '0–3 months',
            subtitle:
            'Short term',
            selected:
            _investmentHorizon ==
                '0–3 months',
            onTap: () {
              setState(() {
                _investmentHorizon =
                '0–3 months';
              });
            },
          ),

          const SizedBox(
            height: 10,
          ),

          _HorizonCard(
            title: '3–12 months',
            subtitle:
            'Medium term',
            selected:
            _investmentHorizon ==
                '3–12 months',
            onTap: () {
              setState(() {
                _investmentHorizon =
                '3–12 months';
              });
            },
          ),

          const SizedBox(
            height: 10,
          ),

          _HorizonCard(
            title: '12+ months',
            subtitle:
            'Long term',
            selected:
            _investmentHorizon ==
                '12+ months',
            onTap: () {
              setState(() {
                _investmentHorizon =
                '12+ months';
              });
            },
          ),
        ],
      ),
      buttonText:
      'Generate Report • 100 Coins',
      loading:
      _isCheckingCoins ||
          _isSubmitting,
      onPressed:
      _submitReport,
    );
  }
}

// ============================================================
// QUESTION LAYOUT
// ============================================================

class _QuestionLayout
    extends StatelessWidget {
  final String question;
  final String subtitle;
  final Widget child;
  final String buttonText;
  final VoidCallback onPressed;
  final bool loading;

  const _QuestionLayout({
    super.key,
    required this.question,
    required this.subtitle,
    required this.child,
    required this.buttonText,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return SingleChildScrollView(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            question,
            style:
            GoogleFonts.poppins(
              color:
              colors.onSurface,
              fontSize: 22,
              height: 1.2,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            subtitle,
            style:
            GoogleFonts.poppins(
              color:
              colors.onSurfaceVariant,
              fontSize: 11,
              height: 1.45,
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          child,

          const SizedBox(
            height: 30,
          ),

          SizedBox(
            width:
            double.infinity,
            height: 54,
            child:
            FilledButton(
              onPressed:
              loading
                  ? null
                  : onPressed,
              child: loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth:
                  2.5,
                  color:
                  Colors.white,
                ),
              )
                  : Text(
                buttonText,
                style:
                GoogleFonts
                    .poppins(
                  fontSize:
                  12,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHOICE CARD
// ============================================================

class _ChoiceCard
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  static const Color primary =
  Color(0xff18C48F);

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        onTap: onTap,
        child: Container(
          padding:
          const EdgeInsets.all(
            16,
          ),
          decoration:
          BoxDecoration(
            color: selected
                ? primary.withValues(
              alpha: 0.08,
            )
                : colors.surface,
            borderRadius:
            BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color: selected
                  ? primary
                  : colors.outlineVariant,
              width:
              selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration:
                BoxDecoration(
                  color: selected
                      ? primary
                      .withValues(
                    alpha: 0.14,
                  )
                      : colors
                      .surfaceContainerHighest,
                  shape:
                  BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? primary
                      : colors
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                      GoogleFonts.poppins(
                        fontSize:
                        13,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle,
                      style:
                      GoogleFonts.poppins(
                        fontSize:
                        10,
                        color: colors
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                selected
                    ? Icons
                    .radio_button_checked_rounded
                    : Icons
                    .radio_button_off_rounded,
                color: selected
                    ? primary
                    : colors
                    .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HORIZON CARD
// ============================================================

class _HorizonCard
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _HorizonCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  static const Color primary =
  Color(0xff18C48F);

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 15,
          ),
          decoration:
          BoxDecoration(
            color: selected
                ? primary.withValues(
              alpha: 0.08,
            )
                : colors.surface,
            borderRadius:
            BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: selected
                  ? primary
                  : colors.outlineVariant,
              width:
              selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                      GoogleFonts.poppins(
                        fontSize:
                        13,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle,
                      style:
                      GoogleFonts.poppins(
                        fontSize:
                        9.5,
                        color: colors
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons
                    .check_circle_rounded
                    : Icons
                    .radio_button_off_rounded,
                color: selected
                    ? primary
                    : colors
                    .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INPUT FIELD
// ============================================================

class _InputField
    extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? prefix;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.keyboardType,
    this.prefix,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style:
      GoogleFonts.poppins(
        fontSize: 13,
        fontWeight:
        FontWeight.w600,
      ),
      decoration:
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor:
        colors.surface,
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          borderSide:
          BorderSide(
            color:
            colors.outlineVariant,
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          borderSide:
          BorderSide(
            color:
            colors.outlineVariant,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          borderSide:
          const BorderSide(
            color:
            Color(0xff18C48F),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REPORT SCREEN
// ============================================================

class StockAiReportScreen
    extends StatelessWidget {
  final String company;
  final String symbol;
  final String report;
  final int remainingCoins;

  const StockAiReportScreen({
    super.key,
    required this.company,
    required this.symbol,
    required this.report,
    required this.remainingCoins,
  });

  static const Color primary =
  Color(0xff18C48F);

  @override
  Widget build(
      BuildContext context,
      ) {
    final ColorScheme colors =
        Theme.of(context)
            .colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$symbol AI Report',
          style:
          GoogleFonts.poppins(
            fontSize: 17,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          30,
        ),
        children: <Widget>[
          Container(
            padding:
            const EdgeInsets.all(
              18,
            ),
            decoration:
            BoxDecoration(
              gradient:
              const LinearGradient(
                colors: <Color>[
                  Color(0xff18C48F),
                  Color(0xff0C9F72),
                ],
              ),
              borderRadius:
              BorderRadius.circular(
                22,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white
                        .withValues(
                      alpha: 0.16,
                    ),
                    shape:
                    BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .auto_awesome_rounded,
                    color:
                    Colors.white,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: <Widget>[
                      Text(
                        company,
                        style:
                        GoogleFonts
                            .poppins(
                          color:
                          Colors.white,
                          fontSize:
                          16,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        '$symbol • AiTradeX AI',
                        style:
                        GoogleFonts
                            .poppins(
                          color: Colors
                              .white
                              .withValues(
                            alpha:
                            0.78,
                          ),
                          fontSize:
                          10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Container(
            padding:
            const EdgeInsets.all(
              18,
            ),
            decoration:
            BoxDecoration(
              color:
              colors.surface,
              borderRadius:
              BorderRadius.circular(
                22,
              ),
              border:
              Border.all(
                color:
                colors.outlineVariant,
              ),
            ),
            child: Text(
              report,
              style:
              GoogleFonts.poppins(
                fontSize: 12,
                height: 1.65,
                color:
                colors.onSurface,
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Container(
            padding:
            const EdgeInsets.all(
              14,
            ),
            decoration:
            BoxDecoration(
              color: primary.withValues(
                alpha: 0.07,
              ),
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons
                      .account_balance_wallet_rounded,
                  color: primary,
                  size: 18,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '$remainingCoins AiTradeX Coins remaining',
                  style:
                  GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            'AI-generated information is for educational purposes only and does not guarantee investment returns.',
            textAlign:
            TextAlign.center,
            style:
            GoogleFonts.poppins(
              fontSize: 8.5,
              height: 1.4,
              color: colors
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
