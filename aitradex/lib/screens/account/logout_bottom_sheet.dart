import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kLogoutGreen = Color(0xff18C48F);

Future<void> showLogoutDialog(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (sheetContext) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(38),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xffDDDDDD),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 17),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffff4d55),
                ),
              ),
              const SizedBox(height: 25),
              const Divider(height: 1, color: Color(0xffE8E8E8)),
              const SizedBox(height: 27),
              Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff333333),
                ),
              ),
              const SizedBox(height: 27),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 57,
                      child: TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xffE8FAF5),
                          foregroundColor: kLogoutGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 57,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          // Add your real logout/auth logic here.
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kLogoutGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Yes, Logout',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
