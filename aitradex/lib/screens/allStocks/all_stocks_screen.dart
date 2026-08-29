
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../stockDetails/stock_details_screen.dart';

const Color kPrimary = Color(0xff18C48F);

class AllStocksScreen extends StatefulWidget {
  const AllStocksScreen({super.key});

  @override
  State<AllStocksScreen> createState() => _AllStocksScreenState();
}

class _AllStocksScreenState extends State<AllStocksScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  bool _ascending = true;

  final List<_StockItem> _stocks = const [
    _StockItem(
      company: 'Adobe',
      symbol: 'ADBE',
      price: '\$285.75',
      change: '-4.58%',
      positive: false,
      logo: 'adobe',
    ),
    _StockItem(
      company: 'Advanced Micro Devices',
      symbol: 'AMD',
      price: '\$68.26',
      change: '+3.62%',
      positive: true,
      logo: 'amd',
    ),
    _StockItem(
      company: 'Airbnb',
      symbol: 'ABNB',
      price: '\$96.08',
      change: '-4.23%',
      positive: false,
      logo: 'airbnb',
    ),
    _StockItem(
      company: 'Alibaba',
      symbol: 'BABA',
      price: '\$89.24',
      change: '+2.81%',
      positive: true,
      logo: 'alibaba',
    ),
    _StockItem(
      company: 'Amazon',
      symbol: 'AMZN',
      price: '\$90.96',
      change: '+1.89%',
      positive: true,
      logo: 'amazon',
    ),
    _StockItem(
      company: 'Apple',
      symbol: 'AAPL',
      price: '\$260.45',
      change: '+1.94%',
      positive: true,
      logo: 'apple',
    ),
    _StockItem(
      company: 'Citibank',
      symbol: 'C',
      price: '\$58.98',
      change: '-3.86%',
      positive: false,
      logo: 'citi',
    ),
    _StockItem(
      company: 'CocaCola',
      symbol: 'KO',
      price: '\$64.56',
      change: '+1.64%',
      positive: true,
      logo: 'coca',
    ),
  ];

  List<_StockItem> get _filteredStocks {
    final q = _query.trim().toLowerCase();

    final result = q.isEmpty
        ? List<_StockItem>.from(_stocks)
        : _stocks.where((stock) {
      return stock.company.toLowerCase().contains(q) ||
          stock.symbol.toLowerCase().contains(q);
    }).toList();

    result.sort(
          (a, b) => _ascending
          ? a.company.compareTo(b.company)
          : b.company.compareTo(a.company),
    );

    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStock(_StockItem stock) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return StockDetailsScreen(
            company: stock.company,
            symbol: stock.symbol,
            price: stock.price,
            percent: stock.change,
            shares: '0 shares',
            avgCost: stock.price,
            equity: stock.price,
            totalReturns: '\$0.00',
            isPositive: stock.positive,
          );
        },
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          final slide = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return SlideTransition(
            position: slide,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildListHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              sliver: SliverList.separated(
                itemCount: _filteredStocks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  return _StockRow(
                    stock: _filteredStocks[index],
                    onTap: () => _openStock(_filteredStocks[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 32,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 27,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Text(
            'All Stocks',
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() => _query = value);
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xffA0A0A0),
              size: 24,
            ),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              icon: const Icon(
                Icons.close_rounded,
                color: Color(0xff777777),
                size: 20,
              ),
            ),
            hintText: 'Search stock or company',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xffAAAAAA),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 27, 24, 0),
      child: Row(
        children: [
          Text(
            '${_filteredStocks.length == _stocks.length ? '500' : _filteredStocks.length} Companies',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() => _ascending = !_ascending);
            },
            child: Row(
              children: [
                Text(
                  'A to Z',
                  style: GoogleFonts.poppins(
                    color: kPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _ascending
                      ? Icons.swap_vert_rounded
                      : Icons.swap_vert_rounded,
                  color: kPrimary,
                  size: 23,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StockItem {
  final String company;
  final String symbol;
  final String price;
  final String change;
  final bool positive;
  final String logo;

  const _StockItem({
    required this.company,
    required this.symbol,
    required this.price,
    required this.change,
    required this.positive,
    required this.logo,
  });
}

class _StockRow extends StatelessWidget {
  const _StockRow({
    required this.stock,
    required this.onTap,
  });

  final _StockItem stock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              _StockLogo(stock: stock),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      stock.symbol,
                      style: GoogleFonts.poppins(
                        color: const Color(0xff666666),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: _MiniChart(positive: stock.positive),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 78,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stock.price,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stock.change,
                      style: GoogleFonts.poppins(
                        color: stock.positive
                            ? kPrimary
                            : const Color(0xffff2020),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockLogo extends StatelessWidget {
  const _StockLogo({required this.stock});

  final _StockItem stock;

  @override
  Widget build(BuildContext context) {
    Color bg;
    String text;
    Color textColor = Colors.white;

    switch (stock.logo) {
      case 'adobe':
        bg = const Color(0xffFA0018);
        text = 'A';
        break;
      case 'amd':
        bg = const Color(0xff222222);
        text = 'AMD';
        break;
      case 'airbnb':
        bg = const Color(0xffff5a60);
        text = '⌂';
        break;
      case 'alibaba':
        bg = const Color(0xffff6d24);
        text = 'Alibaba';
        break;
      case 'amazon':
        bg = const Color(0xff202020);
        text = 'a';
        break;
      case 'apple':
        bg = const Color(0xff111111);
        text = '●';
        break;
      case 'citi':
        bg = const Color(0xff123B8F);
        text = 'citi';
        break;
      case 'coca':
        bg = const Color(0xffF40009);
        text = 'Coca-Cola';
        break;
      default:
        bg = kPrimary;
        text = stock.symbol.substring(0, 1);
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.clip,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: stock.logo == 'coca' ? 9 : stock.logo == 'alibaba' ? 9 : 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  const _MiniChart({required this.positive});

  final bool positive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: CustomPaint(
        painter: _MiniChartPainter(positive: positive),
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  const _MiniChartPainter({required this.positive});

  final bool positive;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = positive ? const Color(0xff18C48F) : const Color(0xffff4b4b)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = (positive ? const Color(0xff18C48F) : const Color(0xffff4b4b))
          .withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    final points = positive
        ? <double>[19, 13, 16, 11, 15, 10, 17, 14, 12, 16, 13, 17, 11, 15, 8]
        : <double>[10, 16, 12, 19, 14, 22, 13, 18, 16, 23, 15, 20, 17, 22, 14];

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = i * (size.width / (points.length - 1));
      final y = points[i];

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) {
    return oldDelegate.positive != positive;
  }
}