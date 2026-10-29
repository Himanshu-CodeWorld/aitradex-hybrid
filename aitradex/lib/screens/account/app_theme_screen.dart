import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../core/theme/theme_controller.dart';

class AppThemeScreen extends StatelessWidget {
  const AppThemeScreen({super.key});

  static const List<_ThemeColor> _colors = [
    _ThemeColor(
      name: 'Emerald',
      color: Color(0xFF18C48F),
    ),
    _ThemeColor(
      name: 'Blue',
      color: Color(0xFF4C8DFF),
    ),
    _ThemeColor(
      name: 'Purple',
      color: Color(0xFF8B5CF6),
    ),
    _ThemeColor(
      name: 'Pink',
      color: Color(0xFFEC4899),
    ),
    _ThemeColor(
      name: 'Orange',
      color: Color(0xFFFF8A3D),
    ),
    _ThemeColor(
      name: 'Red',
      color: Color(0xFFEF4444),
    ),
    _ThemeColor(
      name: 'Cyan',
      color: Color(0xFF06B6D4),
    ),
    _ThemeColor(
      name: 'Indigo',
      color: Color(0xFF6366F1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();

    return Obx(
          () {
        final isDark = controller.isDarkMode.value;
        final selectedColor = controller.primaryColor.value;

        final background = isDark
            ? const Color(0xFF080810)
            : const Color(0xFFF7F8FA);

        final surface = isDark
            ? const Color(0xFF151520)
            : Colors.white;

        final textPrimary = isDark
            ? Colors.white
            : const Color(0xFF17191C);

        final textSecondary = isDark
            ? Colors.white.withValues(alpha: 0.60)
            : const Color(0xFF73777D);

        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'App Theme',
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                40,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selectedColor.withValues(
                        alpha: 0.20,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: selectedColor.withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.palette_outlined,
                          color: selectedColor,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personalize AiTradeX',
                              style: GoogleFonts.poppins(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose an accent color for the entire application.',
                              style: GoogleFonts.poppins(
                                color: textSecondary,
                                fontSize: 9.5,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Choose Theme Color',
                  style: GoogleFonts.poppins(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'This color will be used throughout AiTradeX.',
                  style: GoogleFonts.poppins(
                    color: textSecondary,
                    fontSize: 9.5,
                  ),
                ),

                const SizedBox(height: 18),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _colors.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                  ),
                  itemBuilder: (context, index) {
                    final themeColor = _colors[index];

                    final selected =
                        selectedColor.toARGB32() ==
                            themeColor.color.toARGB32();

                    return GestureDetector(
                      onTap: () {
                        controller.setPrimaryColor(
                          themeColor.color,
                        );
                      },
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? themeColor.color
                                : isDark
                                ? Colors.white.withValues(
                              alpha: 0.08,
                            )
                                : const Color(0xFFE5E7EB),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: themeColor.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColor.color
                                        .withValues(alpha: 0.25),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: selected
                                  ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 22,
                              )
                                  : null,
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                themeColor.name,
                                style: GoogleFonts.poppins(
                                  color: textPrimary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeColor {
  final String name;
  final Color color;

  const _ThemeColor({
    required this.name,
    required this.color,
  });
}