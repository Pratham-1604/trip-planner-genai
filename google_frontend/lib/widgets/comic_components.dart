import 'package:flutter/material.dart';
import 'dart:ui';

class ComicComponents {
  // Comic-style colors
  static const Color comicBlue = Color(0xFF0066CC);
  static const Color comicRed = Color(0xFFCC0000);
  static const Color comicYellow = Color(0xFFFFCC00);
  static const Color comicOrange = Color(0xFFFF6600);
  static const Color comicGreen = Color(0xFF00CC66);
  static const Color comicPurple = Color(0xFF6600CC);
  static const Color comicPink = Color(0xFFFF0066);
  static const Color comicBlack = Color(0xFF000000);
  static const Color comicWhite = Color(0xFFFFFFFF);
  static const Color comicGray = Color(0xFF666666);
  static const Color comicLightGray = Color(0xFFCCCCCC);

  // Comic-style text styles
  static const TextStyle comicTitle = TextStyle(
    fontFamily: 'Comic Sans MS',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: comicBlack,
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 0,
        color: comicWhite,
      ),
    ],
  );

  static const TextStyle comicSubtitle = TextStyle(
    fontFamily: 'Comic Sans MS',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: comicBlack,
    shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 0,
        color: comicWhite,
      ),
    ],
  );

  static const TextStyle comicBody = TextStyle(
    fontFamily: 'Comic Sans MS',
    fontSize: 14,
    color: comicBlack,
    height: 1.4,
  );

  static const TextStyle comicCaption = TextStyle(
    fontFamily: 'Comic Sans MS',
    fontSize: 12,
    color: comicGray,
    fontStyle: FontStyle.italic,
  );

  // Comic-style decorations
  static BoxDecoration comicPanelDecoration({
    Color? backgroundColor,
    Color borderColor = comicBlack,
    double borderWidth = 3.0,
    double borderRadius = 12.0,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? comicWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: comicBlack.withOpacity(0.3),
          offset: const Offset(4, 4),
          blurRadius: 0,
        ),
      ],
    );
  }

  static BoxDecoration comicBubbleDecoration({
    Color? backgroundColor,
    Color borderColor = comicBlack,
    double borderWidth = 2.0,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? comicWhite,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: comicBlack.withOpacity(0.2),
          offset: const Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    );
  }

  // Create a speech bubble widget
  static Widget createSpeechBubble({
    required String text,
    required TextStyle textStyle,
    Color? backgroundColor,
    Color? borderColor,
    EdgeInsets? padding,
    Widget? child,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: comicBubbleDecoration(
        backgroundColor: backgroundColor,
        borderColor: borderColor!,
      ),
      child: child ?? Text(text, style: textStyle),
    );
  }

  // Create a comic panel widget
  static Widget createComicPanel({
    required Widget child,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: comicPanelDecoration(
        backgroundColor: backgroundColor,
        borderColor: borderColor!,
        borderWidth: borderWidth ?? 3.0,
        borderRadius: borderRadius ?? 12.0,
      ),
      child: child,
    );
  }

  // Create a comic-style button
  static Widget createComicButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? borderWidth,
    EdgeInsets? padding,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: comicPanelDecoration(
          backgroundColor: backgroundColor ?? comicBlue,
          borderColor: borderColor ?? comicBlack,
          borderWidth: borderWidth ?? 2.0,
          borderRadius: 20.0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor ?? comicWhite,
            shadows: const [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 0,
                color: comicBlack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Create a comic-style progress indicator
  static Widget createComicProgressIndicator({
    required int current,
    required int total,
    Color? activeColor,
    Color? inactiveColor,
    double? size,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: size ?? 12,
          height: size ?? 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < current ? (activeColor ?? comicBlue) : (inactiveColor ?? comicLightGray),
            border: Border.all(
              color: comicBlack,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // Create a comic-style day header
  static Widget createComicDayHeader({
    required int dayNumber,
    required String title,
    required String summary,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: comicPanelDecoration(
        backgroundColor: backgroundColor ?? comicBlue,
        borderWidth: 4.0,
        borderRadius: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Day number in a circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: comicWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: comicBlack, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: comicBlack.withOpacity(0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: const TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: comicBlack,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day $dayNumber',
                      style: const TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 16,
                        color: comicWhite,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 0,
                            color: comicBlack,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 20,
                        color: comicWhite,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 0,
                            color: comicBlack,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary,
            style: const TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 16,
              color: comicWhite,
              height: 1.4,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 0,
                  color: comicBlack,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Create a comic-style place card
  static Widget createComicPlaceCard({
    required String name,
    required String description,
    required String imageUrl,
    required String category,
    required double rating,
    required String address,
    required List<String> tags,
    required int placeNumber,
    required int totalPlaces,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: comicPanelDecoration(
          backgroundColor: comicWhite,
          borderWidth: 3.0,
          borderRadius: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with comic-style overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: comicLightGray,
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                // Comic-style overlay with speech bubble
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: comicBubbleDecoration(
                      backgroundColor: comicWhite.withOpacity(0.95),
                      borderWidth: 2.0,
                    ),
                    child: Text(
                      name,
                      style: comicSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Place number badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: comicYellow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: comicBlack, width: 2),
                    ),
                    child: Text(
                      '$placeNumber/$totalPlaces',
                      style: const TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: comicBlack,
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: comicOrange,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: comicBlack, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: comicBlack, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: comicBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: comicGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: comicBlack, width: 2),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: comicBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Address
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: comicGray, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: comicCaption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    description,
                    style: comicBody,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Tags
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: comicPink,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: comicBlack, width: 1),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: comicBlack,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create a comic-style story introduction
  static Widget createComicStoryIntro({
    required String story,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: comicPanelDecoration(
        backgroundColor: backgroundColor ?? comicYellow,
        borderWidth: 4.0,
        borderRadius: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: comicWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: comicBlack, width: 3),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: comicBlack,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Adventure Story',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: comicBlack,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 0,
                      color: comicWhite,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            story,
            style: comicBody.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

