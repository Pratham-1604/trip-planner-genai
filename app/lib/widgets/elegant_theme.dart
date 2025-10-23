import 'package:flutter/material.dart';

class ElegantTheme {
  // Elegant color palette
  static const Color primaryBlue = Color(0xFF2C3E50);
  static const Color lightBlue = Color(0xFF3498DB);
  static const Color softGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFF6C757D);
  static const Color darkGray = Color(0xFF343A40);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightAccent = Color(0xFFE8F4FD);
  static const Color subtleBorder = Color(0xFFE9ECEF);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color accentGold = Color(0xFFF39C12);
  static const Color accentGreen = Color(0xFF27AE60);
  static const Color accentOrange = Color(0xFFE67E22);

  // Typography
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 16,
    color: textSecondary,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    color: textSecondary,
    fontWeight: FontWeight.w500,
  );

  // Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: subtleBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration pageDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: subtleBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration headerDecoration = BoxDecoration(
    color: primaryBlue,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
  );

  static BoxDecoration timeBadgeDecoration = BoxDecoration(
    color: lightAccent,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: lightBlue.withOpacity(0.3), width: 1),
  );

  static BoxDecoration categoryBadgeDecoration = BoxDecoration(
    color: accentGold.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: accentGold.withOpacity(0.3), width: 1),
  );

  // Button styles
  static Widget createElegantButton({
    required String text,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsets? padding,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? primaryBlue,
        foregroundColor: textColor ?? white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Navigation widget
  static Widget createNavigationBar({
    required int currentPage,
    required int totalPages,
    required VoidCallback? onPrevious,
    required VoidCallback? onNext,
    required bool canGoPrevious,
    required bool canGoNext,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subtleBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          createElegantButton(
            text: '← Previous',
            onPressed: canGoPrevious ? onPrevious! : () {},
            backgroundColor: canGoPrevious ? primaryBlue : mediumGray,
          ),
          
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: lightAccent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lightBlue.withOpacity(0.3), width: 1),
            ),
            child: Text(
              'Page ${currentPage + 1} of $totalPages',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ),
          
          // Next button
          createElegantButton(
            text: 'Next →',
            onPressed: canGoNext ? onNext! : () {},
            backgroundColor: canGoNext ? accentGreen : mediumGray,
          ),
        ],
      ),
    );
  }
}

