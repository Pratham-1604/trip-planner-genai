import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'comic_components.dart';

class BookPageWidget extends StatefulWidget {
  final Widget child;
  final bool isLeftPage;
  final VoidCallback? onTap;

  const BookPageWidget({
    super.key,
    required this.child,
    this.isLeftPage = false,
    this.onTap,
  });

  @override
  State<BookPageWidget> createState() => _BookPageWidgetState();
}

class _BookPageWidgetState extends State<BookPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void flipPage() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? flipPage,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            alignment: widget.isLeftPage
                ? Alignment.centerRight
                : Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(
                widget.isLeftPage
                    ? _animation.value * math.pi
                    : -_animation.value * math.pi,
              ),
            child: Container(
              decoration: BoxDecoration(
                color: ComicComponents.comicWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ComicComponents.comicBlack, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: ComicComponents.comicBlack.withOpacity(0.3),
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class BookPage {
  final String title;
  final Widget content;
  final String? subtitle;
  final IconData? icon;

  BookPage({
    required this.title,
    required this.content,
    this.subtitle,
    this.icon,
  });
}

class BookNavigationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool canGoPrevious;
  final bool canGoNext;

  const BookNavigationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    this.canGoPrevious = true,
    this.canGoNext = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ComicComponents.comicLightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ComicComponents.comicBlack, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ComicComponents.createComicButton(
            text: '← Previous',
            onPressed: canGoPrevious ? onPrevious! : () => {},
            backgroundColor: canGoPrevious
                ? ComicComponents.comicBlue
                : ComicComponents.comicGray,
            textColor: ComicComponents.comicWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ComicComponents.comicWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ComicComponents.comicBlack, width: 2),
            ),
            child: Text(
              'Page ${currentPage + 1} of $totalPages',
              style: const TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ComicComponents.comicBlack,
              ),
            ),
          ),

          // Next button
          ComicComponents.createComicButton(
            text: 'Next →',
            onPressed: canGoNext ? onNext! : () {},
            backgroundColor: canGoNext
                ? ComicComponents.comicGreen
                : ComicComponents.comicGray,
            textColor: ComicComponents.comicWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }
}

class BookPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? backgroundColor;

  const BookPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? ComicComponents.comicBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        border: Border.all(color: ComicComponents.comicBlack, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ComicComponents.comicWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ComicComponents.comicBlack,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: ComicComponents.comicBlack,
                    size: 24,
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
                      style: const TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ComicComponents.comicWhite,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 0,
                            color: ComicComponents.comicBlack,
                          ),
                        ],
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 16,
                          color: ComicComponents.comicWhite,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 0,
                              color: ComicComponents.comicBlack,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final String? time;
  final IconData? icon;
  final Color? backgroundColor;
  final List<String>? tags;

  const ActivityCard({
    super.key,
    required this.title,
    required this.description,
    this.time,
    this.icon,
    this.backgroundColor,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? ComicComponents.comicWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ComicComponents.comicBlack, width: 2),
        boxShadow: [
          BoxShadow(
            color: ComicComponents.comicBlack.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ComicComponents.comicYellow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              border: Border.all(color: ComicComponents.comicBlack, width: 1),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: ComicComponents.comicBlack, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ComicComponents.comicBlack,
                    ),
                  ),
                ),
                if (time != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ComicComponents.comicOrange,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ComicComponents.comicBlack,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      time!,
                      style: const TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ComicComponents.comicBlack,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
                    color: ComicComponents.comicBlack,
                    height: 1.4,
                  ),
                ),
                if (tags != null && tags!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags!
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ComicComponents.comicPink,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ComicComponents.comicBlack,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ComicComponents.comicBlack,
                              ),
                            ),
                          ),
                        )
                        .toList(),
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

