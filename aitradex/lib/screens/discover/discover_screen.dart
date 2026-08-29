
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../stockDetails/stock_details_screen.dart';
import '../allStocks/all_stocks_screen.dart';

const Color kPrimary = Color(0xff18C48F);

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';

  final List<_SearchStock> _stocks = const [
    _SearchStock(
      company: 'Spotify',
      symbol: 'SPOT',
      price: '\$71.05',
      percent: '+2.94%',
      shares: '0.17469 shares',
      avgCost: '\$73.86',
      equity: '\$22,935.46',
      totalReturns: '\$1,946.75',
      logoType: 'spotify',
      isPositive: true,
    ),
    _SearchStock(
      company: 'Apple',
      symbol: 'AAPL',
      price: '\$230.89',
      percent: '+8.16%',
      shares: '10 shares',
      avgCost: '\$185.20',
      equity: '\$2,308.90',
      totalReturns: '\$456.90',
      logoType: 'apple',
      isPositive: true,
    ),
    _SearchStock(
      company: 'Meta Platforms',
      symbol: 'META',
      price: '\$744.85',
      percent: '+6.42%',
      shares: '5 shares',
      avgCost: '\$612.40',
      equity: '\$3,724.25',
      totalReturns: '\$662.25',
      logoType: 'meta',
      isPositive: true,
    ),
    _SearchStock(
      company: 'Tesla',
      symbol: 'TSLA',
      price: '\$341.37',
      percent: '+2.37%',
      shares: '8 shares',
      avgCost: '\$295.10',
      equity: '\$2,730.96',
      totalReturns: '\$370.16',
      logoType: 'tesla',
      isPositive: true,
    ),
    _SearchStock(
      company: 'Starbucks',
      symbol: 'SBUX',
      price: '\$93.42',
      percent: '+7.55%',
      shares: '12 shares',
      avgCost: '\$82.15',
      equity: '\$1,121.04',
      totalReturns: '\$135.24',
      logoType: 'starbucks',
      isPositive: true,
    ),
    _SearchStock(
      company: 'Alphabet',
      symbol: 'GOOGL',
      price: '\$201.12',
      percent: '+3.18%',
      shares: '6 shares',
      avgCost: '\$166.20',
      equity: '\$1,206.72',
      totalReturns: '\$209.52',
      logoType: 'google',
      isPositive: true,
    ),
    _SearchStock(
      company: 'Netflix',
      symbol: 'NFLX',
      price: '\$1,244.50',
      percent: '-1.25%',
      shares: '2 shares',
      avgCost: '\$1,100.00',
      equity: '\$2,489.00',
      totalReturns: '\$289.00',
      logoType: 'netflix',
      isPositive: false,
    ),
  ];

  List<_SearchStock> get _filteredStocks {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return const [];
    }

    return _stocks.where((stock) {
      return stock.company.toLowerCase().contains(query) ||
          stock.symbol.toLowerCase().contains(query);
    }).toList();
  }

  void _openSearch() {
    _searchFocusNode.requestFocus();
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });

    _searchFocusNode.unfocus();
  }

  void _openStock(_SearchStock stock) {
    _searchFocusNode.unfocus();

    Get.to(
          () => StockDetailsScreen(
        company: stock.company,
        symbol: stock.symbol,
        price: stock.price,
        percent: stock.percent,
        shares: stock.shares,
        avgCost: stock.avgCost,
        equity: stock.equity,
        totalReturns: stock.totalReturns,
        isPositive: stock.isPositive,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }




  static const List<_Category> categories = [
    _Category('✅', 'All Stocks'),
    _Category('🚀', 'Visionary'),
    _Category('🍔', 'Food & Drinks'),
    _Category('😎', 'Lifestyle'),
    _Category('🎇', 'Entertainment'),
    _Category('💻', 'Tech Giants'),
    _Category('📺', 'Social Media'),
    _Category('🚗', 'Car & Bikes'),
    _Category('🌞', 'Covid-19'),
    _Category('🚀', 'Recommended Buys'),
    _Category('🎮', 'Games'),
    _Category('💻', 'Electronics'),
  ];

  static const List<_Mover> movers = [
    _Mover('PINS', 'Pinterest', '+12.37%', true, Color(0xffE60023)),
    _Mover('TWTR', 'Twitter', '+9.29%', true, Color(0xff1DA1F2)),
    _Mover('AAPL', 'Apple', '+8.16%', true, Color(0xff111111)),
    _Mover('SBUX', 'Starbucks', '+7.55%', true, Color(0xff00704A)),
    _Mover('META', 'Meta', '+6.42%', true, Color(0xff0866FF)),
  ];

  static const List<_DiscoveryCard> cards = [
    _DiscoveryCard(
      '🏆',
      'Top 100 Companies',
      'International big brands you may know and love',
      'https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=1000&q=85',
      true,
    ),
    _DiscoveryCard(
      '🔥',
      '10 Most Popular',
      'Follow the crowd',
      'https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&w=700&q=85',
      false,
    ),
    _DiscoveryCard(
      '📱',
      'Social Media',
      'Know each other',
      'https://images.unsplash.com/photo-1611162617474-5b21e879e113?auto=format&fit=crop&w=700&q=85',
      false,
    ),
    _DiscoveryCard(
      '💰',
      'Financials',
      'Manage your finance',
      'https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=700&q=85',
      false,
    ),
    _DiscoveryCard(
      '🛍️',
      'E-Commerce',
      'Get your favorite item',
      'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=700&q=85',
      false,
    ),
    _DiscoveryCard(
      '💻',
      'Cryptocurrency',
      'Invest in cryptocurrency',
      'https://images.unsplash.com/photo-1640340434855-6084b1f4901c?auto=format&fit=crop&w=700&q=85',
      false,
    ),
    _DiscoveryCard(
      '🌳',
      'Green Energy',
      'Renewable energy',
      'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=700&q=85',
      false,
    ),
    _DiscoveryCard(
      '🏥',
      'Healthcare',
      'Health and mental issues',
      'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=700&q=85',
      false,
    ),
    _DiscoveryCard(
      '🏠',
      'Real Estate',
      'Your dream home is here',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=700&q=85',
      false,
    ),
    _DiscoveryCard(
      '😎',
      'Lifestyle Brands',
      'Enjoy life together',
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=700&q=85',
      false,
    ),
    _DiscoveryCard(
      '🎨',
      'Design Brands',
      'Improve creative workflow',
      'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=700&q=85',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildSearch()),
              if (_searchQuery.trim().isEmpty) ...[
                SliverToBoxAdapter(child: _buildCategories()),
                SliverToBoxAdapter(child: _buildTopMovers()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
                  sliver: SliverToBoxAdapter(child: _buildDiscoveryGrid()),
                ),
              ] else
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xffE8FBF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bubble_chart_rounded,
              color: kPrimary,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Discover',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showMoreMenu(context),
            child: Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.6),
              ),
              child: const Icon(Icons.more_horiz, size: 19),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    final results = _filteredStocks;
    final searching = _searchQuery.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 14),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 55,
            decoration: BoxDecoration(
              color: searching
                  ? const Color(0xffF0FBF7)
                  : const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: searching ? kPrimary : Colors.transparent,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onTap: _openSearch,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: kPrimary,
                  size: 24,
                ),
                suffixIcon: searching
                    ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xff777777),
                    size: 20,
                  ),
                )
                    : null,
                hintText: 'Search stock or company',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xffAAAAAA),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 17),
              ),
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: !searching
                ? const SizedBox.shrink()
                : Padding(
              key: const ValueKey('search-results'),
              padding: const EdgeInsets.only(top: 10),
              child: _buildSearchResults(results),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<_SearchStock> results) {
    if (results.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEEEEEE)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xffF4F4F4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Color(0xff999999),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No stocks found for "$_searchQuery"',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xff777777),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 330),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 7),
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 74,
          endIndent: 16,
          color: Color(0xffF0F0F0),
        ),
        itemBuilder: (_, index) {
          final stock = results[index];

          return InkWell(
            onTap: () => _openStock(stock),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 16, 11),
              child: Row(
                children: [
                  _SearchStockLogo(stock: stock),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.company,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stock.symbol,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xff777777),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        stock.price,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stock.percent,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: stock.isPositive
                              ? kPrimary
                              : const Color(0xffF04444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xffA0A0A0),
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 202,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 24, right: 0),
        child: SizedBox(
          width: 720,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map((category) => _CategoryChip(category: category))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTopMovers() {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Top Movers',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: kPrimary,
                  size: 25,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 153,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: movers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, index) => _MoverItem(mover: movers[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryGrid() {
    final first = cards.first;
    final remaining = cards.skip(1).toList();

    return Column(
      children: [
        _DiscoveryCardWidget(data: first, height: 181),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: remaining.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.90,
          ),
          itemBuilder: (_, index) {
            return _DiscoveryCardWidget(
              data: remaining[index],
              height: double.infinity,
            );
          },
        ),
      ],
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Discover',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.tune_rounded, color: kPrimary),
                title: const Text('Manage categories'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none_rounded),
                title: const Text('Market alerts'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchStock {
  final String company;
  final String symbol;
  final String price;
  final String percent;
  final String shares;
  final String avgCost;
  final String equity;
  final String totalReturns;
  final String logoType;
  final bool isPositive;

  const _SearchStock({
    required this.company,
    required this.symbol,
    required this.price,
    required this.percent,
    required this.shares,
    required this.avgCost,
    required this.equity,
    required this.totalReturns,
    required this.logoType,
    required this.isPositive,
  });
}

class _SearchStockLogo extends StatelessWidget {
  const _SearchStockLogo({required this.stock});

  final _SearchStock stock;

  @override
  Widget build(BuildContext context) {
    Color background;
    String text;

    switch (stock.logoType) {
      case 'spotify':
        background = const Color(0xff1ED760);
        text = 'S';
        break;
      case 'apple':
        background = Colors.black;
        text = 'A';
        break;
      case 'meta':
        background = const Color(0xff0866FF);
        text = '∞';
        break;
      case 'tesla':
        background = const Color(0xffD90000);
        text = 'T';
        break;
      case 'starbucks':
        background = const Color(0xff00704A);
        text = 'S';
        break;
      case 'google':
        background = Colors.white;
        text = 'G';
        break;
      case 'netflix':
        background = Colors.black;
        text = 'N';
        break;
      default:
        background = const Color(0xff18C48F);
        text = stock.symbol.substring(0, 1);
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: stock.logoType == 'google'
            ? Border.all(color: const Color(0xffEEEEEE))
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: stock.logoType == 'google'
              ? const Color(0xff4285F4)
              : Colors.white,
          fontSize: text == '∞' ? 30 : 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Category {
  final String emoji;
  final String title;

  const _Category(this.emoji, this.title);
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final _Category category;

  @override
  Widget build(BuildContext context) {
    final selected = category.title == 'All Stocks';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          if (category.title == 'All Stocks') {
            Get.to(
                  () => const AllStocksScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 220),
            );
          }
        },
        child: Container(
          height: 39,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xffDADADA)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                category.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Mover {
  final String symbol;
  final String company;
  final String percent;
  final bool positive;
  final Color logoColor;

  const _Mover(
      this.symbol,
      this.company,
      this.percent,
      this.positive,
      this.logoColor,
      );
}

class _MoverItem extends StatelessWidget {
  const _MoverItem({required this.mover});

  final _Mover mover;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: mover.logoColor,
              border: Border.all(color: kPrimary, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _logoText(mover.symbol),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: mover.symbol == 'AAPL' ? 23 : 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            mover.symbol,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            mover.percent,
            style: GoogleFonts.poppins(
              color: mover.positive ? kPrimary : Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _logoText(String symbol) {
    switch (symbol) {
      case 'PINS':
        return 'P';
      case 'TWTR':
        return '♥';
      case 'AAPL':
        return '●';
      case 'SBUX':
        return '★';
      case 'META':
        return '∞';
      default:
        return symbol.substring(0, 1);
    }
  }
}

class _DiscoveryCard {
  final String emoji;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool wide;

  const _DiscoveryCard(
      this.emoji,
      this.title,
      this.subtitle,
      this.imageUrl,
      this.wide,
      );
}

class _DiscoveryCardWidget extends StatelessWidget {
  const _DiscoveryCardWidget({
    required this.data,
    required this.height,
  });

  final _DiscoveryCard data;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () {},
        child: SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  data.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xff8D9697), Color(0xff252829)],
                      ),
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCC000000),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  right: 12,
                  bottom: 13,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data.emoji} ${data.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: data.wide ? 19 : 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: data.wide ? 11.5 : 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}