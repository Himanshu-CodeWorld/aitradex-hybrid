
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:aitradex/screens/account/aitradex_coins_history.dart';
import 'package:aitradex/screens/rewards/invite_friends_screen.dart';

/// AiTradeX Coins
///
/// Coin rules:
/// - 1 AiTradeX Coin = ₹1 value for in-app pricing purposes.
/// - 1 stock intelligence unlock = 100 Coins.

/// Coin rewards:
/// - Invite an eligible friend: +250 Coins.
/// - Coin balance and history are loaded from the backend.
/// - Rewards must be credited server-side and only once.
class AiTradeXCoinsScreen extends StatefulWidget {
  const AiTradeXCoinsScreen({super.key});

  @override
  State<AiTradeXCoinsScreen> createState() => _AiTradeXCoinsScreenState();
}

class _AiTradeXCoinsScreenState extends State<AiTradeXCoinsScreen> {
  static const String _apiBaseUrl = 'https://aitradex-api.onrender.com/api';
  static const int _minimumPurchaseAmount = 10;
  static const int _maximumPurchaseAmount = 50000;

  int _coinBalance = 0;
  bool _isLoading = false;
  bool _isPurchasing = false;

  final List<CoinTransaction> _transactions = <CoinTransaction>[];
  final TextEditingController _amountController = TextEditingController();
  late final Razorpay _razorpay;

  String? _pendingOrderId;
  int _pendingCoins = 0;
  int _pendingAmountInr = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshCoins());
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  Color _primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  Color _surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  Color _text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);

  Color _border(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

  @override
  Widget build(BuildContext context) {
    final Color primary = _primary(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AiTradeX Coins',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Coin history',
            onPressed: _openCoinHistory,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCoins,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildBalanceCard(context, primary),
            const SizedBox(height: 14),
            _buildAddCoinsCard(context, primary),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Ways to earn'),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const InviteFriendsScreen(),
                ),
              ),
              child: _reward(
                context,
                Icons.person_add_alt_1_rounded,
                'Invite friends',
                'You and your friend can earn 250 AiTradeX Coins each.',
                '+250 each',
                primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Recent activity'),
            const SizedBox(height: 10),
            _buildRecentActivity(context),
            const SizedBox(height: 24),
            _buildImportantNote(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, Color primary) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primary.withValues(alpha: 0.70),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.22),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 27,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available balance',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_coinBalance Coins',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'History',
                onPressed: _openCoinHistory,
                icon: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.currency_rupee_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '1 Coin = ₹1',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '₹$_coinBalance',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCoinsCard(BuildContext context, Color primary) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.add_card_rounded, color: primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add AiTradeX Coins',
                      style: GoogleFonts.poppins(
                        color: _text(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '1 Coin = ₹1. Enter the amount and continue to secure payment.',
                      style: GoogleFonts.poppins(
                        color: _muted(context),
                        fontSize: 10.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            enabled: !_isPurchasing,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: 'Amount in INR',
              hintText: 'Enter amount e.g. 500',
              prefixText: '₹ ',
              suffixText: ' = Coins',
              prefixIcon: const Icon(Icons.currency_rupee_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final int amount in <int>[100, 250, 500, 1000])
                ActionChip(
                  label: Text('₹$amount'),
                  onPressed: _isPurchasing
                      ? null
                      : () {
                    _amountController.text = amount.toString();
                    _amountController.selection =
                        TextSelection.collapsed(
                          offset: _amountController.text.length,
                        );
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isPurchasing ? null : _startCoinPurchase,
              icon: _isPurchasing
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.lock_rounded, size: 17),
              label: Text(
                _isPurchasing ? 'Opening payment...' : 'Add Coins & Pay',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Payments are processed by Razorpay. Coins are credited only after the server verifies the payment.',
            style: GoogleFonts.poppins(
              color: _muted(context),
              fontSize: 9.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: _text(context),
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    if (_transactions.isEmpty) {
      return _buildEmptyActivity(context);
    }

    final List<CoinTransaction> recent = _transactions.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        children: [
          for (int index = 0; index < recent.length; index++) ...[
            _buildTransactionTile(context, recent[index]),
            if (index != recent.length - 1)
              Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
                color: _border(context),
              ),
          ],
          if (_transactions.length > 5)
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: _openCoinHistory,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Center(
                  child: Text(
                    'View all history',
                    style: GoogleFonts.poppins(
                      color: _primary(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: _muted(context),
            size: 34,
          ),
          const SizedBox(height: 9),
          Text(
            'No coin activity yet',
            style: GoogleFonts.poppins(
              color: _text(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your earned and spent coins will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _muted(context),
              fontSize: 9.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _openCoinHistory,
            icon: const Icon(Icons.history_rounded, size: 16),
            label: Text(
              'Open coin history',
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
      BuildContext context,
      CoinTransaction transaction,
      ) {
    final bool isCredit = transaction.amount > 0;
    final Color amountColor =
    isCredit ? _primary(context) : Theme.of(context).colorScheme.error;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: amountColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(
          isCredit
              ? Icons.south_west_rounded
              : Icons.north_east_rounded,
          color: amountColor,
          size: 20,
        ),
      ),
      title: Text(
        transaction.title,
        style: GoogleFonts.poppins(
          color: _text(context),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        transaction.subtitle,
        style: GoogleFonts.poppins(
          color: _muted(context),
          fontSize: 8,
        ),
      ),
      trailing: Text(
        '${isCredit ? '+' : ''}${transaction.amount} Coins',
        style: GoogleFonts.poppins(
          color: amountColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildImportantNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _muted(context),
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'AiTradeX Coins are an in-app balance used for eligible AiTradeX features. '
                  '1 Coin is priced at ₹1 for the in-app coin model. '
                  'One stock intelligence unlock currently requires 100 Coins. '
                  'Coins are not securities and do not guarantee investment returns.',
              style: GoogleFonts.poppins(
                color: _muted(context),
                fontSize: 8.8,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reward(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      String amount,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: _text(context),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: _muted(context),
                    fontSize: 8.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _firebaseToken() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in again to manage AiTradeX Coins.');
    }
    final String? token = await user.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw StateError('Unable to authenticate this request.');
    }
    return token;
  }

  Future<Map<String, dynamic>> _apiRequest({
    required String path,
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final String token = await _firebaseToken();
    final Uri uri = Uri.parse('$_apiBaseUrl$path');
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final http.Response response = method == 'POST'
        ? await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body ?? <String, dynamic>{}),
    ).timeout(const Duration(seconds: 25))
        : await http.get(
      uri,
      headers: headers,
    ).timeout(const Duration(seconds: 25));

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = <String, dynamic>{'success': false};
    }

    if (decoded is! Map) {
      throw StateError('Invalid server response.');
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(decoded);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        data['message']?.toString() ??
            'Request failed (${response.statusCode}).',
      );
    }

    if (data['success'] == false) {
      throw StateError(data['message']?.toString() ?? 'Request failed.');
    }

    return data;
  }

  int? _readInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  int? _extractBalance(dynamic raw) {
    if (raw is! Map) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);

    final int? direct = _readInt(map['balance']);
    if (direct != null) return direct;

    final dynamic wallet = map['wallet'];
    if (wallet is Map) {
      final int? walletBalance = _readInt(wallet['balance']);
      if (walletBalance != null) return walletBalance;
    }

    final dynamic coinWallet = map['coinWallet'];
    if (coinWallet is Map) {
      final int? walletBalance = _readInt(coinWallet['balance']);
      if (walletBalance != null) return walletBalance;
    }

    return null;
  }

  int? _extractCoinsAdded(dynamic raw) {
    if (raw is! Map) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);

    final int? direct =
        _readInt(map['coinsAdded']) ??
            _readInt(map['coins']) ??
            _readInt(map['amount']);
    if (direct != null) return direct;

    final dynamic transaction = map['transaction'];
    if (transaction is Map) {
      return _readInt(transaction['coinsAdded']) ??
          _readInt(transaction['amount']) ??
          _readInt(transaction['coins']);
    }

    return null;
  }

  Future<void> _refreshCoins() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> balanceResponse =
      await _apiRequest(path: '/coins/balance');

      // Accept both {data:{balance:...}} and {balance:...}.
      final int? serverBalance =
          _extractBalance(balanceResponse['data']) ??
              _extractBalance(balanceResponse);
      if (serverBalance != null && mounted) {
        setState(() {
          _coinBalance = serverBalance;
        });
      }

      final Map<String, dynamic> historyResponse =
      await _apiRequest(path: '/coins/history?page=1&limit=50');

      // Accept all common response shapes:
      // {data:{transactions:[...]}}
      // {data:{items:[...]}}
      // {transactions:[...]}
      // {items:[...]}
      // {data:[...]}
      final dynamic historyData = historyResponse['data'];
      dynamic items;

      if (historyData is List) {
        items = historyData;
      } else if (historyData is Map) {
        items = historyData['transactions'] ??
            historyData['items'] ??
            historyData['history'];
      }

      if (items is! List) {
        items = historyResponse['transactions'] ??
            historyResponse['items'] ??
            historyResponse['history'];
      }

      final List<CoinTransaction> loaded = <CoinTransaction>[];
      if (items is List) {
        for (final dynamic item in items) {
          if (item is! Map) continue;
          final Map<String, dynamic> map =
          Map<String, dynamic>.from(item);
          final dynamic amountRaw = map['amount'];
          final int amount = amountRaw is num
              ? amountRaw.toInt()
              : int.tryParse(amountRaw?.toString() ?? '') ?? 0;

          DateTime? createdAt;
          final dynamic dateRaw =
              map['createdAt'] ?? map['date'] ?? map['timestamp'];
          if (dateRaw != null) {
            createdAt = DateTime.tryParse(dateRaw.toString());
          }

          loaded.add(
            CoinTransaction(
              id: map['_id']?.toString() ??
                  map['id']?.toString() ??
                  '${DateTime.now().microsecondsSinceEpoch}',
              title: map['description']?.toString() ??
                  map['title']?.toString() ??
                  'Coin transaction',
              subtitle: _transactionSubtitle(map),
              amount: amount,
              createdAt: createdAt,
            ),
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _transactions
          ..clear()
          ..addAll(loaded);
      });
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Bad state: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _transactionSubtitle(Map<String, dynamic> map) {
    final String type = map['type']?.toString().trim() ?? '';
    final String symbol = map['symbol']?.toString().trim() ?? '';
    if (symbol.isNotEmpty) return '$type • $symbol';
    return type.isNotEmpty ? type : 'AiTradeX coin ledger';
  }

  Future<void> _startCoinPurchase() async {
    if (_isPurchasing) return;

    final int? amount = int.tryParse(_amountController.text.trim());
    if (amount == null ||
        amount < _minimumPurchaseAmount ||
        amount > _maximumPurchaseAmount) {
      _showMessage(
        'Enter an amount between ₹$_minimumPurchaseAmount and ₹$_maximumPurchaseAmount.',
      );
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      final Map<String, dynamic> response = await _apiRequest(
        path: '/coins/payment/create-order',
        method: 'POST',
        body: <String, dynamic>{'amountInr': amount},
      );

      final dynamic rawData = response['data'];
      if (rawData is! Map) {
        throw StateError('Payment order was not created.');
      }
      final Map<String, dynamic> data =
      Map<String, dynamic>.from(rawData);

      final String? keyId = data['keyId']?.toString();
      final String? orderId = data['orderId']?.toString();
      final int coins = data['coins'] is num
          ? (data['coins'] as num).toInt()
          : amount;

      if (keyId == null ||
          keyId.isEmpty ||
          orderId == null ||
          orderId.isEmpty) {
        throw StateError('Invalid payment order received from server.');
      }

      _pendingOrderId = orderId;
      _pendingCoins = coins;
      _pendingAmountInr = amount;

      final User? user = FirebaseAuth.instance.currentUser;
      _razorpay.open(<String, dynamic>{
        'key': keyId,
        'amount': amount * 100,
        'currency': 'INR',
        'name': 'AiTradeX',
        'description': '$coins AiTradeX Coins',
        'order_id': orderId,
        'timeout': 300,
        'prefill': <String, dynamic>{
          'email': user?.email ?? '',
          'contact': user?.phoneNumber ?? '',
        },
        'theme': <String, dynamic>{'color': '#18C48F'},
      });
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Bad state: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _handlePaymentSuccess(
      PaymentSuccessResponse response,
      ) async {
    final String? paymentId = response.paymentId;
    final String? orderId = response.orderId ?? _pendingOrderId;
    final String? signature = response.signature;

    if (paymentId == null ||
        paymentId.isEmpty ||
        orderId == null ||
        orderId.isEmpty ||
        signature == null ||
        signature.isEmpty) {
      _showMessage(
        'Payment completed, but verification details were incomplete. Please refresh your balance.',
      );
      await _refreshCoins();
      return;
    }

    if (mounted) setState(() => _isPurchasing = true);

    try {
      final Map<String, dynamic> responseBody = await _apiRequest(
        path: '/coins/payment/verify',
        method: 'POST',
        body: <String, dynamic>{
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
        },
      );

      final dynamic rawData = responseBody['data'];
      final int? verifiedBalance = _extractBalance(rawData);
      final int verifiedCoinsAdded =
          _extractCoinsAdded(rawData) ?? _pendingCoins;
      final int purchasedAmount = _pendingAmountInr;

      // Update the visible balance immediately from the verified server
      // response. Then refresh the balance/history from MongoDB so the UI
      // stays correct even when the payment response has a different shape.
      if (mounted) {
        setState(() {
          if (verifiedBalance != null) {
            _coinBalance = verifiedBalance;
          } else {
            // Fallback only when the server did not return a balance.
            _coinBalance += verifiedCoinsAdded;
          }
        });
        _amountController.clear();
        _showPaymentSuccess(
          verifiedCoinsAdded,
          purchasedAmount,
        );
      }

      // Always re-read the authoritative balance and transaction history.
      await _refreshCoins();
    } catch (error) {
      if (mounted) {
        _showMessage(
          'Payment was received, but coin verification failed. '
              'Please refresh or contact support with Payment ID $paymentId.',
        );
      }
    } finally {
      _clearPendingPayment();
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _clearPendingPayment();
    if (!mounted) return;
    setState(() => _isPurchasing = false);
    _showMessage(
      response.message?.trim().isNotEmpty == true
          ? response.message!
          : 'Payment was not completed.',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    _showMessage(
      'External wallet selected: ${response.walletName ?? 'wallet'}',
    );
  }

  void _clearPendingPayment() {
    _pendingOrderId = null;
    _pendingCoins = 0;
    _pendingAmountInr = 0;
  }

  void _showPaymentSuccess(int coins, int amountInr) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Text(
            '$coins Coins added successfully for ₹$amountInr. '
                'New balance: $_coinBalance Coins.',
          ),
        ),
      );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  void _openCoinHistory() {
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AiTradeXCoinsHistoryScreen(
          coinBalance: _coinBalance,
          // Share the live list so a pull-to-refresh on the history screen
          // reflects the latest transactions loaded by _refreshCoins.
          transactions: _transactions,
          onRefresh: _refreshCoins,
        ),
      ),
    );
  }
}
