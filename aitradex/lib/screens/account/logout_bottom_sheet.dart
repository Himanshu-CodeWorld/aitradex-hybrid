import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aitradex/screens/auth/signin/signin_screen.dart';
import 'package:aitradex/services/shared_preferences_service.dart';

const Color kLogoutDanger = Color(0xFFFF4D55);

Future<void> showLogoutDialog(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark
          ? 0.72
          : 0.55,
    ),
    builder: (sheetContext) {
      final ThemeData theme = Theme.of(sheetContext);
      final ColorScheme scheme = theme.colorScheme;

      final bool isDark =
          theme.brightness == Brightness.dark;

      final Color primary = scheme.primary;
      final Color surface = scheme.surface;
      final Color textPrimary = scheme.onSurface;
      final Color textSecondary = scheme.onSurfaceVariant;

      final Color dividerColor = scheme.outline.withValues(
        alpha: isDark ? 0.30 : 0.18,
      );

      final Color handleColor =
      scheme.onSurfaceVariant.withValues(
        alpha: isDark ? 0.55 : 0.30,
      );

      final Color cancelBackground = primary.withValues(
        alpha: isDark ? 0.14 : 0.08,
      );

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          24,
          12,
          24,
          36,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(38),
          ),
          border: Border(
            top: BorderSide(
              color: dividerColor,
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.35 : 0.12,
              ),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==================================================
              // HANDLE
              // ==================================================

              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 17),

              // ==================================================
              // TITLE
              // ==================================================

              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                  color: kLogoutDanger,
                ),
              ),

              const SizedBox(height: 25),

              Divider(
                height: 1,
                thickness: 1,
                color: dividerColor,
              ),

              const SizedBox(height: 27),

              // ==================================================
              // MESSAGE
              // ==================================================

              Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 27),

              // ==================================================
              // BUTTONS
              // ==================================================

              Row(
                children: [
                  // ==============================================
                  // CANCEL
                  // ==============================================

                  Expanded(
                    child: SizedBox(
                      height: 57,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(
                            sheetContext,
                          ).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: cancelBackground,
                          foregroundColor: primary,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30),
                            side: BorderSide(
                              color: primary.withValues(
                                alpha: isDark ? 0.18 : 0.10,
                              ),
                              width: 0.8,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ==============================================
                  // YES LOGOUT
                  // ==============================================

                  Expanded(
                    child: SizedBox(
                      height: 57,
                      child: ElevatedButton(
                        onPressed: () async {
                          // ----------------------------------------
                          // Close bottom sheet first
                          // ----------------------------------------

                          Navigator.of(
                            sheetContext,
                          ).pop();

                          // ----------------------------------------
                          // Clear login state
                          // ----------------------------------------

                          await SharedPreferencesService
                              .setLoggedIn(false);

                          // ----------------------------------------
                          // Navigate to Login
                          // ----------------------------------------

                          Get.offAll(
                                () => const SignInScreen(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor:
                          scheme.onPrimary,
                          elevation: 0,
                          shadowColor:
                          Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Yes, Logout',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
            ],
          ),
        ),
      );
    },
  );
}