import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:aitradex/screens/notification/notification_screen.dart';
import 'package:aitradex/screens/wishlist/wishlist_screen.dart';

class BalanceHeader extends StatelessWidget {
  const BalanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff25D79A),
              Color(0xff18C48F),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ==========================================================
            // BACKGROUND SHAPES
            // ==========================================================

            Positioned(
              top: -65,
              left: -55,
              child: _shape(150),
            ),

            Positioned(
              top: -20,
              right: -65,
              child: _shape(155),
            ),

            Positioned(
              bottom: -75,
              left: 100,
              child: _shape(190),
            ),

            Positioned(
              bottom: -30,
              right: -45,
              child: _shape(115),
            ),

            // ==========================================================
            // CONTENT
            // ==========================================================

            Padding(
              padding: EdgeInsets.only(
                top: top + 8,
                left: 24,
                right: 18,
              ),
              child: Column(
                children: [
                  // ======================================================
                  // TOP BAR
                  // ======================================================

                  Row(
                    children: [
                      // Logo
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_graph_rounded,
                          color: Color(0xff18C48F),
                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 9),

                      const Text(
                        "AiTradeX",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const Spacer(),

                      // Wishlist
                      IconButton(
                        onPressed: () {
                          Get.to(
                                () => const WishlistScreen(),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        icon: const Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),

                      // Notification
                      IconButton(
                        onPressed: () {
                          Get.to(
                                () => const NotificationScreen(),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ======================================================
                  // BALANCE
                  // ======================================================

                  const Text(
                    "\$229,375.25",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 46,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Balance Available",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 27),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shape(double size) {
    return Opacity(
      opacity: 0.055,
      child: Transform.rotate(
        angle: 0.8,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}