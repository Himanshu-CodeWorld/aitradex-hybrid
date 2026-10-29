import 'dart:convert';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// AiTradeX AI home + chat assistant.
///
/// UI is inspired by the supplied LiMo reference:
/// - compact profile/coin header
/// - AI hero section
/// - stock/market quick actions
/// - Stock reports / Portfolio reports tabs
/// - My reports list
/// - Most asked reports
/// - Potential stocks section
/// - bottom navigation with AiTradeX in the center
///
/// Chat flow:
/// Flutter -> Firebase ID token -> AiTradeX backend -> Groq -> Flutter.
///
/// IMPORTANT: GROQ_API_KEY must stay on the backend.
class AiTradeXBot extends StatefulWidget {
  const AiTradeXBot({super.key});

  @override
  State<AiTradeXBot> createState() => _AiTradeXBotState();
}

class _AiTradeXBotState extends State<AiTradeXBot> {
  static const String _apiBaseUrl =
      'https://aitradex-api.onrender.com/api';

  static const Color _green = Color(0xFF18C48F);
  static const Color _pink = Color(0xFFFF159B);
  static const Color _orange = Color(0xFFFFB52E);
  static const Color _dark = Color(0xFF050505);
  static const Color _card = Color(0xFF171717);
  static const Color _card2 = Color(0xFF202020);

  final TextEditingController _messageController =
  TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = <_ChatMessage>[
    const _ChatMessage(
      text:
      'Hi! I’m AiTradeX AI. Ask me about stocks, markets, ETFs, mutual funds, commodities, portfolio concepts, or investing terms.',
      isUser: false,
    ),
  ];

  //noinspection SpellCheckingInspection
  final List<_ReportItem> _reports = const <_ReportItem>[
    _ReportItem('TATASTEEL', '25 Sep 2026, 06:28 PM', 'TATA'),
    _ReportItem('BEL', '20 Sep 2026, 03:52 PM', 'BEL'),
    _ReportItem('MSUMI', '19 Sep 2026, 05:07 PM', 'MS'),
    _ReportItem('NHPC', '18 Sep 2026, 11:47 AM', 'NH'),
    _ReportItem('BLUEDART', '13 Sep 2026, 10:36 AM', 'BD'),
  ];

  //noinspection SpellCheckingInspection
  final List<_AskedReport> _mostAsked = const <_AskedReport>[
    _AskedReport('POLICYBZR', '767 requests', 'today', 'PB'),
    _AskedReport('BEL', '706 requests', 'today', 'BEL'),
    _AskedReport('SHRIRAM', '677 requests', 'today', 'S'),
  ];

  //noinspection SpellCheckingInspection
  final List<_PotentialStock> _potentialStocks = const <_PotentialStock>[
    _PotentialStock('RELIANCE', '9%', 'Potential upside'),
    _PotentialStock('HDFCBANK', '5%', 'Potential upside'),
  ];

  bool _isLoading = false;
  int _bottomIndex = 2;
  final ValueNotifier<int> _chatVersion = ValueNotifier<int>(0);
  bool _showPortfolioReports = false;
  bool _chatScreenOpen = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatVersion.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? predefinedMessage]) async {
    final String text =
    (predefinedMessage ?? _messageController.text).trim();

    if (text.isEmpty || _isLoading) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final List<Map<String, String>> history = _buildHistory();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _isLoading = true;
    });
    _chatVersion.value++;

    _openChatScreen();
    await _scrollToBottom();

    try {
      final String reply = await _requestAiResponse(
        message: text,
        history: history,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
      });
      _chatVersion.value++;
      await _scrollToBottom();
    } catch (error, stackTrace) {
      debugPrint('AiTradeX AI error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: _friendlyErrorMessage(error),
            isUser: false,
            isError: true,
          ),
        );
      });
      _chatVersion.value++;
      await _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _chatVersion.value++;
      }
    }
  }

  List<Map<String, String>> _buildHistory() {
    return _messages
        .where((item) => !item.isError && item.text.trim().isNotEmpty)
        .map(
          (item) => <String, String>{
        'role': item.isUser ? 'user' : 'assistant',
        'content': item.text.trim(),
      },
    )
        .toList();
  }

  Future<String> _requestAiResponse({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      throw const _AiException(
        'Please sign in again before using AiTradeX AI.',
      );
    }

    final String? idToken = await firebaseUser.getIdToken(true);

    if (idToken == null || idToken.trim().isEmpty) {
      throw const _AiException(
        'Your Firebase authentication token is unavailable. Please sign in again.',
      );
    }

    final Uri uri = Uri.parse('$_apiBaseUrl/ai/chat');
    late final http.Response response;

    try {
      response = await http
          .post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${idToken.trim()}',
        },
        body: jsonEncode(<String, dynamic>{
          'message': message.trim(),
          'history': history,
        }),
      )
          .timeout(const Duration(seconds: 45));
    } on http.ClientException catch (error) {
      throw _AiException(
        'Unable to connect to the AiTradeX server. ${error.message}',
      );
    } on Exception catch (error) {
      if (error.toString().toLowerCase().contains('timeout')) {
        throw const _AiException(
          'The AI service took too long to respond. Please try again.',
        );
      }
      rethrow;
    }

    final Map<String, dynamic> data = _decodeResponse(response.body);

    if (response.statusCode == 401) {
      throw const _AiException(
        'Your session has expired. Please sign in again.',
      );
    }

    if (response.statusCode == 429) {
      throw _AiException(
        _serverMessage(
          data,
          fallback:
          'AiTradeX AI is temporarily rate limited. Please try again shortly.',
        ),
      );
    }

    if (response.statusCode >= 500) {
      throw _AiException(
        _serverMessage(
          data,
          fallback:
          'AiTradeX AI is temporarily unavailable. Please try again shortly.',
        ),
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _AiException(
        _serverMessage(
          data,
          fallback: 'AiTradeX AI request failed (${response.statusCode}).',
        ),
      );
    }

    if (data['success'] != true) {
      throw _AiException(
        _serverMessage(
          data,
          fallback: 'AiTradeX AI could not generate a response.',
        ),
      );
    }

    final String? reply = _extractReply(data);

    if (reply == null || reply.trim().isEmpty) {
      throw const _AiException(
        'AiTradeX AI returned an empty response.',
      );
    }

    return reply.trim();
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.trim().isEmpty) {
      throw const _AiException(
        'The AiTradeX server returned an empty response.',
      );
    }

    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const _AiException(
        'The AiTradeX server returned an invalid response.',
      );
    } on _AiException {
      rethrow;
    } on FormatException {
      throw const _AiException(
        'The AiTradeX server returned invalid JSON.',
      );
    }
  }

  String? _extractReply(Map<String, dynamic> data) {
    // Prefer explicit answer fields over a generic `message` status field.
    String? readText(dynamic value) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map) {
        for (final String key in <String>['reply', 'response', 'answer', 'content', 'text', 'message']) {
          final String? found = readText(value[key]);
          if (found != null) return found;
        }
      }
      return null;
    }

    for (final String key in <String>['reply', 'response', 'answer', 'content', 'output']) {
      final String? found = readText(data[key]);
      if (found != null) return found;
    }

    final dynamic nestedData = data['data'] ?? data['result'];
    final String? nested = readText(nestedData);
    if (nested != null) return nested;

    final dynamic choices = data['choices'];
    if (choices is List && choices.isNotEmpty && choices.first is Map) {
      final dynamic choiceMessage = (choices.first as Map)['message'];
      final String? content = readText(choiceMessage);
      if (content != null) return content;
    }

    // Use `message` last because some APIs use it for status text.
    return readText(data['message']);
  }

  String _serverMessage(
      Map<String, dynamic> data, {
        required String fallback,
      }) {
    final dynamic message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    return fallback;
  }

  String _friendlyErrorMessage(Object error) {
    if (error is _AiException) return error.message;

    final String raw = error.toString().toLowerCase();
    if (raw.contains('network')) {
      return 'Network connection failed. Please check your internet connection and try again.';
    }
    if (raw.contains('timeout')) {
      return 'The AI service took too long to respond. Please try again.';
    }
    return 'Something went wrong while contacting AiTradeX AI. Please try again.';
  }

  void _openChatScreen() {
    if (!mounted || _chatScreenOpen) return;
    _chatScreenOpen = true;
    Navigator.of(context)
        .push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _AiChatScreen(
          messages: _messages,
          controller: _messageController,
          scrollController: _scrollController,
          isLoading: () => _isLoading,
          version: _chatVersion,
          onSend: _sendMessage,
          onClear: _clearConversation,
        ),
      ),
    )
        .whenComplete(() {
      _chatScreenOpen = false;
    });
  }

  Future<void> _clearConversation() async {
    if (_isLoading) return;

    setState(() {
      _messages
        ..clear()
        ..add(
          const _ChatMessage(
            text: 'Conversation cleared. What would you like to explore?',
            isUser: false,
          ),
        );
    });
    _chatVersion.value++;

    await _scrollToBottom();
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted || !_scrollController.hasClients) return;

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _askStock(String symbol) {
    final String prompt =
        'Give me a detailed report on $symbol. Explain the business, recent market trend, key risks, what I should check before investing, and possible scenarios. Do not guarantee returns.';
    _sendMessage(prompt);
  }

  void _onBottomTap(int index) {
    setState(() => _bottomIndex = index);
    if (index != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            index == 0
                ? 'Home'
                : index == 1
                ? 'Invest'
                : index == 3
                ? 'Markets'
                : 'Portfolio',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(child: _buildTopBar()),
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildReportTabs()),
            SliverToBoxAdapter(child: _buildMyReports()),
            SliverToBoxAdapter(child: _buildMostAsked()),
            SliverToBoxAdapter(child: _buildPotentialStocks()),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white70),
          ),
          const Spacer(),
          Text(
            'AiTradeX',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _orange.withValues(alpha: .65)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.monetization_on_rounded,
                    color: _orange, size: 14),
                const SizedBox(width: 5),
                Text(
                  '0',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      height: 205,
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF250016),
            Color(0xFF100D16),
            Color(0xFF002D24),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: -35,
            top: -65,
            child: _glowOrb(150, _pink.withValues(alpha: .24)),
          ),
          Positioned(
            right: -50,
            bottom: -70,
            child: _glowOrb(190, _green.withValues(alpha: .18)),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _HeroGridPainter()),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: <Color>[_pink, _green],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: _pink.withValues(alpha: .25),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Hi, I'm AiTradeX!",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'How can I help you today?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: GestureDetector(
        onTap: _openChatScreen,
        child: Container(
          height: 48,
          padding: const EdgeInsets.only(left: 15, right: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF090909),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _pink.withValues(alpha: .65)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Ask about investments',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 10.5,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.black,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final List<_ActionCard> actions = <_ActionCard>[
      _ActionCard(
        icon: Icons.pie_chart_rounded,
        title: 'Get a report on\nany NSE stock',
        action: 'Ask AiTradeX',
        onTap: () => _askStock('RELIANCE'),
      ),
      _ActionCard(
        icon: Icons.chat_bubble_rounded,
        title: 'Ask about\nMarket',
        action: 'Chat now',
        onTap: () => _sendMessage('What is happening in the Indian market today?'),
      ),
      _ActionCard(
        icon: Icons.search_rounded,
        title: 'Get insights on\nany stock',
        action: 'Explore',
        onTap: _openChatScreen,
      ),
    ];

    return SizedBox(
      height: 145,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, int index) => actions[index],
      ),
    );
  }

  Widget _buildReportTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _gradientTab(
              title: 'Stock reports',
              selected: !_showPortfolioReports,
              onTap: () => setState(() => _showPortfolioReports = false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _gradientTab(
              title: 'Portfolio reports',
              selected: _showPortfolioReports,
              onTap: () => setState(() => _showPortfolioReports = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientTab({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: <Color>[_pink, _orange])
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildMyReports() {
    if (_showPortfolioReports) {
      return _section(
        title: 'Portfolio reports',
        child: _emptyReportState('No portfolio reports yet.'),
      );
    }

    return _section(
      title: 'My reports',
      trailing: 'View all',
      child: Column(
        children: _reports.map(_reportTile).toList(),
      ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
    String? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: GoogleFonts.poppins(
                    color: _orange,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _reportTile(_ReportItem item) {
    return Container(
      height: 62,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.logo,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.symbol,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.date,
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFF262626),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: _orange,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyReportState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 10),
      ),
    );
  }

  Widget _buildMostAsked() {
    return _section(
      title: 'Most asked reports',
      child: SizedBox(
        height: 125,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _mostAsked.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, int index) {
            final _AskedReport item = _mostAsked[index];
            return Container(
              width: 112,
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
              decoration: BoxDecoration(
                color: _card2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: .06)),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.logo,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.symbol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item.requests,
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 8,
                    ),
                  ),
                  Text(
                    item.period,
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 7.5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPotentialStocks() {
    return _section(
      title: 'Potentially buy rated stocks by AiTradeX',
      child: SizedBox(
        height: 184,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _potentialStocks.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, int index) {
            final _PotentialStock stock = _potentialStocks[index];
            return Container(
              width: 145,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF123C2C), Color(0xFF0B1C15)],
                ),
                border: Border.all(color: _green.withValues(alpha: .13)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: _orange,
                      size: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tap to reveal',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stock.upside,
                    style: GoogleFonts.poppins(
                      color: _green,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    stock.label,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 7.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => _askStock(stock.symbol),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Get report',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: .08))),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: <Widget>[
              _navItem(0, Icons.home_outlined, 'Home'),
              _navItem(1, Icons.trending_up_rounded, 'Invest'),
              _navAiItem(),
              _navItem(3, Icons.show_chart_rounded, 'Markets'),
              _navItem(4, Icons.account_balance_wallet_outlined, 'Portfolio'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final bool selected = _bottomIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onBottomTap(index),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 19,
              color: selected ? _green : Colors.white30,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: selected ? Colors.white : Colors.white30,
                fontSize: 7.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navAiItem() {
    final bool selected = _bottomIndex == 2;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onBottomTap(2),
        child: Transform.translate(
          offset: const Offset(0, -13),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[_pink, _green],
                  ),
                  border: Border.all(color: const Color(0xFF111111), width: 5),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _pink.withValues(alpha: .20),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                selected ? 'AiTradeX' : 'AI',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.fromLTRB(10, 10, 9, 9),
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF303030),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFFFFB52E), size: 17),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$action  ›',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFB52E),
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiChatScreen extends StatefulWidget {
  const _AiChatScreen({
    required this.messages,
    required this.controller,
    required this.scrollController,
    required this.isLoading,
    required this.version,
    required this.onSend,
    required this.onClear,
  });

  final List<_ChatMessage> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final bool Function() isLoading;
  final ValueNotifier<int> version;
  final Future<void> Function([String? predefinedMessage]) onSend;
  final Future<void> Function() onClear;

  @override
  State<_AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<_AiChatScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechReady = false;
  bool _isListening = false;
  String? _speechLocaleId;

  @override
  void initState() {
    super.initState();
    _initializeVoice();
  }

  Future<void> _initializeVoice() async {
    try {
      _speechReady = await _speech.initialize(
        onStatus: (String status) {
          if (!mounted) return;
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (dynamic error) {
          if (!mounted) return;
          setState(() => _isListening = false);
          _showVoiceMessage('Voice recognition error. Check microphone permission and try again.');
        },
      );
      if (_speechReady) {
        final List<stt.LocaleName> locales = await _speech.locales();
        for (final stt.LocaleName locale in locales) {
          final String normalized = locale.localeId.toLowerCase().replaceAll('-', '_');
          if (normalized == 'en_in') {
            _speechLocaleId = locale.localeId;
            break;
          }
        }
        if (_speechLocaleId == null) {
          for (final stt.LocaleName locale in locales) {
            final String normalized =
            locale.localeId.toLowerCase().replaceAll('-', '_');
            if (normalized == 'en_us') {
              _speechLocaleId = locale.localeId;
              break;
            }
          }
        }
      }
      try {
        await _tts.setLanguage('en-IN');
      } catch (_) {
        await _tts.setLanguage('en-US');
      }
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      if (mounted) setState(() {});
    } catch (error) {
      debugPrint('AiTradeX voice initialization error: $error');
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    try {
      if (!_speechReady) await _initializeVoice();
      if (!_speechReady) {
        _showVoiceMessage('Speech recognition is unavailable on this device.');
        return;
      }
      await _tts.stop();
      if (!mounted) return;
      setState(() => _isListening = true);
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          localeId: _speechLocaleId,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 4),
          partialResults: true,
        ),
        onResult: (result) {
          final String recognized = result.recognizedWords.trim();
          if (recognized.isEmpty || !mounted) return;
          widget.controller.value = TextEditingValue(
            text: recognized,
            selection: TextSelection.collapsed(offset: recognized.length),
          );
          if (result.finalResult) setState(() => _isListening = false);
        },
      );
    } catch (error) {
      if (mounted) setState(() => _isListening = false);
      _showVoiceMessage('Could not start voice input. Please check microphone permission.');
    }
  }

  Future<void> _speak(String text) async {
    final String spokenText = text.trim();
    if (spokenText.isEmpty) return;
    try {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      await _tts.stop();
      await _tts.speak(spokenText.replaceAll(RegExp(r'[#*_`>~-]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim());
    } catch (error) {
      _showVoiceMessage('Text-to-speech is unavailable on this device.');
    }
  }

  void _showVoiceMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050505),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: <Color>[
                  _AiTradeXBotState._pink,
                  _AiTradeXBotState._green,
                ]),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 19),
            ),
            const SizedBox(width: 10),
            Text(
              'AiTradeX AI',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: widget.isLoading() ? null : widget.onClear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: widget.version,
        builder: (BuildContext context, int _, Widget? child) {
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  itemCount: widget.messages.length + (widget.isLoading() ? 1 : 0),
                  itemBuilder: (_, int index) {
                    if (widget.isLoading() && index == widget.messages.length) {
                      return const _TypingBubble();
                    }
                    return _MessageBubble(
                      message: widget.messages[index],
                      primary: _AiTradeXBotState._green,
                      onSpeak: _speak,
                    );
                  },
                ),
              ),
              _ChatComposer(
                controller: widget.controller,
                isLoading: widget.isLoading(),
                onSend: widget.onSend,
                isListening: _isListening,
                onVoice: _toggleListening,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.isListening,
    required this.onVoice,
  });

  final TextEditingController controller;
  final bool isLoading;
  final bool isListening;
  final VoidCallback onVoice;
  final Future<void> Function([String? predefinedMessage]) onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
        decoration: const BoxDecoration(color: Color(0xFF111111)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            IconButton(
              tooltip: isListening ? 'Stop voice input' : 'Speak your question',
              onPressed: isLoading ? null : onVoice,
              icon: Icon(
                isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: isListening
                    ? Colors.redAccent
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 110),
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (!isLoading) onSend();
                  },
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about stocks, markets...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isLoading ? null : () => onSend(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isLoading
                      ? _AiTradeXBotState._green.withValues(alpha: .45)
                      : _AiTradeXBotState._green,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
                    : const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.primary,
    this.onSpeak,
  });

  final _ChatMessage message;
  final Color primary;
  final ValueChanged<String>? onSpeak;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 330),
          margin: const EdgeInsets.only(left: 45, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: const BoxDecoration(
            color: _AiTradeXBotState._green,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Text(
            message.text,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        margin: const EdgeInsets.only(right: 25, bottom: 12),
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 13),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                message.isError
                    ? Icons.error_outline_rounded
                    : Icons.auto_awesome_rounded,
                size: 15,
                color: message.isError ? Colors.redAccent : primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: message.isError
                  ? Text(
                message.text,
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              )
                  : MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                  h1: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                  h2: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                  h3: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  listBullet: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                  code: GoogleFonts.robotoMono(fontSize: 11, color: Colors.white),
                ),
              ),
            ),
            if (!message.isError && onSpeak != null)
              IconButton(
                tooltip: 'Read response aloud',
                visualDensity: VisualDensity.compact,
                onPressed: () => onSpeak!(message.text),
                icon: Icon(Icons.volume_up_rounded, size: 18, color: primary),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 46,
      margin: const EdgeInsets.only(right: 30, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List<Widget>.generate(3, (int index) {
              final double value = (_controller.value + index / 3) % 1.0;
              final double scale =
                  0.65 + (math.sin(value * 2 * math.pi) + 1) * 0.18;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _AiTradeXBotState._green.withValues(
                      alpha: .45 + (scale - .65) * 1.2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _HeroGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: .035)
      ..strokeWidth = 1;

    const double gap = 42;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  final String text;
  final bool isUser;
  final bool isError;
}

class _AiException implements Exception {
  const _AiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _ReportItem {
  const _ReportItem(this.symbol, this.date, this.logo);

  final String symbol;
  final String date;
  final String logo;
}

class _AskedReport {
  const _AskedReport(this.symbol, this.requests, this.period, this.logo);

  final String symbol;
  final String requests;
  final String period;
  final String logo;
}

class _PotentialStock {
  const _PotentialStock(this.symbol, this.upside, this.label);

  final String symbol;
  final String upside;
  final String label;
}