import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // ================================================================
  // NOTIFICATION DATA
  // ================================================================

  static const List<AppNotification> notifications = [
    AppNotification(
      title: "Security Updates!",
      time: "Today",
      dateTime: "09:24 AM",
      message:
      "Now Otrade has a Two-Factor Authentication. Try it now to make your account more secure.",
      icon: Icons.check_rounded,
      iconColor: Color(0xff3978F6),
      iconBackground: Color(0xffEEF4FF),
      isNew: true,
    ),

    AppNotification(
      title: "Multiple Card Features!",
      time: "1 day ago",
      dateTime: "14:43 PM",
      message:
      "Now you can also connect Otrade with multiple MasterCard & Visa. Try the service now.",
      icon: Icons.local_offer_rounded,
      iconColor: Color(0xffF9A825),
      iconBackground: Color(0xfffff7e9),
      isNew: true,
    ),

    AppNotification(
      title: "New Updates Available!",
      time: "2 days ago",
      dateTime: "10:29 AM",
      message:
      "Update Otrade now to get access to the latest features for easier in buy or sell stocks.",
      icon: Icons.info_outline_rounded,
      iconColor: Color(0xffFF6678),
      iconBackground: Color(0xfffff0f2),
      isNew: false,
    ),

    AppNotification(
      title: "Bank Account Connected!",
      time: "5 days ago",
      dateTime: "16:52 PM",
      message:
      "You have linked your account with a local bank. You can withdraw whenever you want.",
      icon: Icons.business_center_outlined,
      iconColor: Color(0xff3978F6),
      iconBackground: Color(0xffEEF4FF),
      isNew: false,
    ),

    AppNotification(
      title: "Credit Card Connected!",
      time: "6 days ago",
      dateTime: "15:38 PM",
      message:
      "Your credit card has been successfully linked with Otrade. Enjoy our services.",
      icon: Icons.credit_card_rounded,
      iconColor: Color(0xff7658F5),
      iconBackground: Color(0xffF2F0FF),
      isNew: false,
    ),

    AppNotification(
      title: "Account Setup Successful!",
      time: "12 Dec, 2022",
      dateTime: "14:27 PM",
      message:
      "Your account creation is successful, you can now start investing with Otrade.",
      icon: Icons.person_outline_rounded,
      iconColor: Color(0xff28C98D),
      iconBackground: Color(0xffECF9F2),
      isNew: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,

        body: SafeArea(
          child: Column(
            children: [
              // ==========================================================
              // HEADER
              // ==========================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  18,
                  8,
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 23,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Title
                    Text(
                      "Notification",
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const Spacer(),

                    // Settings
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                      icon: const Icon(
                        Icons.settings_outlined,
                        size: 29,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================================
              // NOTIFICATION LIST
              // ==========================================================

              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    8,
                    24,
                    30,
                  ),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    return _NotificationCard(
                      notification: notification,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// NOTIFICATION MODEL
// ======================================================================

class AppNotification {
  final String title;
  final String time;
  final String dateTime;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool isNew;

  const AppNotification({
    required this.title,
    required this.time,
    required this.dateTime,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.isNew,
  });
}

// ======================================================================
// NOTIFICATION CARD
// ======================================================================

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // TOP ROW
          // ============================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ==========================================================
              // ICON
              // ==========================================================

              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: notification.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: notification.iconColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      notification.icon,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 18),

              // ==========================================================
              // TITLE + TIME
              // ==========================================================

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Text(
                          notification.time,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          "|",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          notification.dateTime,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ==========================================================
              // NEW BADGE
              // ==========================================================

              if (notification.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff12C98B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "New",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ============================================================
          // MESSAGE
          // ============================================================

          Text(
            notification.message,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}