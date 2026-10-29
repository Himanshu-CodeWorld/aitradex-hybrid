import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// AiTradeX subscriptions screen.
///
/// Shows available subscription plans and the user's current subscription.
/// Payment/backend subscription verification can be connected later.
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  int _selectedPlan = 1;
  bool _isProcessing = false;

  final List<_SubscriptionPlan> _plans = const [
    _SubscriptionPlan(
      name: 'Free',
      price: '₹0',
      period: 'Forever',
      description: 'Essential market tools',
      features: [
        'Market overview',
        'Basic watchlist',
        'Limited AI insights',
        'Stock alerts',
      ],
    ),
    _SubscriptionPlan(
      name: 'Pro',
      price: '₹299',
      period: '/ month',
      description: 'Advanced AI investing tools',
      features: [
        'Unlimited AI insights',
        'Advanced stock alerts',
        'Portfolio analysis',
        'Premium market insights',
      ],
    ),
    _SubscriptionPlan(
      name: 'Elite',
      price: '₹799',
      period: '/ month',
      description: 'Full AiTradeX experience',
      features: [
        'Everything in Pro',
        'Priority AI analysis',
        'Advanced portfolio signals',
        'Premium research tools',
      ],
    ),
  ];

  Color _primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  Color _text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _secondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);

  Color _surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  Color _border(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final primary = _primary(context);
    final selected = _plans[_selectedPlan];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Subscriptions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          _buildCurrentPlan(context),
          const SizedBox(height: 20),
          Text(
            'Choose a plan',
            style: GoogleFonts.poppins(
              color: _text(context),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(
            _plans.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPlanCard(context, index, _plans[index]),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Subscriptions and payments will be connected to the AiTradeX billing service.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _secondary(context),
              fontSize: 8.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _continue,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: _isDark(context) ? Colors.black : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      selected.name == 'Free'
                          ? 'Continue with Free'
                          : 'Continue with ${selected.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlan(BuildContext context) {
    final primary = _primary(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: _isDark(context) ? 0.18 : 0.10),
            _surface(context),
          ],
        ),
        border: Border.all(
          color: primary.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current subscription',
                  style: GoogleFonts.poppins(
                    color: _secondary(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Free Plan',
                  style: GoogleFonts.poppins(
                    color: _text(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              'ACTIVE',
              style: GoogleFonts.poppins(
                color: primary,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    int index,
    _SubscriptionPlan plan,
  ) {
    final primary = _primary(context);
    final selected = index == _selectedPlan;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedPlan = index);
        },
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? primary.withValues(alpha: 0.55)
                  : _border(context),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              if (selected && !_isDark(context))
                BoxShadow(
                  color: primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: GoogleFonts.poppins(
                        color: _text(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: primary,
                      size: 21,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                plan.description,
                style: GoogleFonts.poppins(
                  color: _secondary(context),
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.price,
                    style: GoogleFonts.poppins(
                      color: _text(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      plan.period,
                      style: GoogleFonts.poppins(
                        color: _secondary(context),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              ...plan.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: primary,
                        size: 16,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.poppins(
                            color: _secondary(context),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    final selected = _plans[_selectedPlan];

    if (selected.name == 'Free') {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selected.name} billing integration is ready to connect.',
          style: GoogleFonts.poppins(fontSize: 10.5),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _SubscriptionPlan {
  const _SubscriptionPlan({
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
  });

  final String name;
  final String price;
  final String period;
  final String description;
  final List<String> features;
}
