import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'elegant_theme.dart';

class ElegantActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final String? time;
  final String? imageUrl;
  final IconData? icon;
  final Color? timeColor;
  final List<String>? tags;
  final VoidCallback? onTap;

  const ElegantActivityCard({
    super.key,
    required this.title,
    required this.description,
    this.time,
    this.imageUrl,
    this.icon,
    this.timeColor,
    this.tags,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: ElegantTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: ElegantTheme.softGray,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: ElegantTheme.lightBlue,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: ElegantTheme.softGray,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: ElegantTheme.mediumGray,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not available',
                          style: ElegantTheme.captionText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Content section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ElegantTheme.lightAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: ElegantTheme.lightBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: ElegantTheme.cardTitle,
                            ),
                            if (time != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: ElegantTheme.timeBadgeDecoration,
                                child: Text(
                                  time!,
                                  style: ElegantTheme.captionText.copyWith(
                                    color: ElegantTheme.lightBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    description,
                    style: ElegantTheme.bodyText,
                  ),

                  // Tags
                  if (tags != null && tags!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags!.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: ElegantTheme.categoryBadgeDecoration,
                        child: Text(
                          tag,
                          style: ElegantTheme.captionText.copyWith(
                            color: ElegantTheme.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElegantPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const ElegantPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ElegantTheme.headerDecoration,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ElegantTheme.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: ElegantTheme.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ElegantTheme.pageTitle.copyWith(
                    color: ElegantTheme.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: ElegantTheme.pageSubtitle.copyWith(
                      color: ElegantTheme.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ElegantPlaceOverview extends StatelessWidget {
  final String name;
  final String category;
  final String? imageUrl;
  final double? rating;
  final VoidCallback? onTap;

  const ElegantPlaceOverview({
    super.key,
    required this.name,
    required this.category,
    this.imageUrl,
    this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: ElegantTheme.cardDecoration,
        child: Row(
          children: [
            // Image or placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ElegantTheme.softGray,
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: ElegantTheme.lightBlue,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.location_on,
                          color: ElegantTheme.mediumGray,
                          size: 24,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.location_on,
                      color: ElegantTheme.mediumGray,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: ElegantTheme.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: ElegantTheme.categoryBadgeDecoration,
                        child: Text(
                          category,
                          style: ElegantTheme.captionText.copyWith(
                            color: ElegantTheme.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (rating != null) ...[
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: ElegantTheme.accentGold,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating!.toStringAsFixed(1),
                              style: ElegantTheme.captionText.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

