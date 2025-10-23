import 'package:flutter/material.dart';
import '../../models/flight_models.dart';
import '../../widgets/elegant_theme.dart';

class RoundTripHighlightsScreen extends StatefulWidget {
  final List<RoundTripHighlight> highlights;

  const RoundTripHighlightsScreen({
    super.key,
    required this.highlights,
  });

  @override
  State<RoundTripHighlightsScreen> createState() => _RoundTripHighlightsScreenState();
}

class _RoundTripHighlightsScreenState extends State<RoundTripHighlightsScreen> {
  String _sortBy = 'price'; // 'price', 'duration', 'savings'

  @override
  Widget build(BuildContext context) {
    final sortedHighlights = _getSortedHighlights();

    return Scaffold(
      backgroundColor: ElegantTheme.softGray,
      appBar: AppBar(
        title: const Text(
          'Round Trip Highlights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ElegantTheme.white,
          ),
        ),
        backgroundColor: ElegantTheme.primaryBlue,
        foregroundColor: ElegantTheme.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'price',
                child: Text('Sort by Price'),
              ),
              const PopupMenuItem(
                value: 'duration',
                child: Text('Sort by Duration'),
              ),
              const PopupMenuItem(
                value: 'savings',
                child: Text('Sort by Savings'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: ElegantTheme.white,
              border: Border(
                bottom: BorderSide(color: ElegantTheme.subtleBorder, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.flight_land,
                  color: ElegantTheme.lightBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Best Round Trip Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ElegantTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${widget.highlights.length} combinations found',
                        style: ElegantTheme.captionText,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ElegantTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ElegantTheme.accentGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Save up to ${_getMaxSavings()}',
                    style: ElegantTheme.captionText.copyWith(
                      color: ElegantTheme.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Highlights list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedHighlights.length,
              itemBuilder: (context, index) {
                final highlight = sortedHighlights[index];
                return _buildHighlightCard(highlight, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(RoundTripHighlight highlight, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: ElegantTheme.cardDecoration.copyWith(
        border: rank <= 3 
            ? Border.all(color: ElegantTheme.accentGold, width: 2)
            : null,
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to booking or details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected option #$rank'),
              backgroundColor: ElegantTheme.lightBlue,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header with rank and price
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: rank <= 3 
                          ? ElegantTheme.accentGold 
                          : ElegantTheme.lightAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: rank <= 3 
                              ? ElegantTheme.white 
                              : ElegantTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${highlight.outboundFlight.airline} + ${highlight.returnFlight.airline}',
                          style: ElegantTheme.cardTitle,
                        ),
                        Text(
                          '${highlight.formattedTotalDuration} total journey',
                          style: ElegantTheme.captionText,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        highlight.formattedTotalPrice,
                        style: ElegantTheme.cardTitle.copyWith(
                          fontSize: 20,
                          color: ElegantTheme.accentGreen,
                        ),
                      ),
                      if (highlight.savings > 0)
                        Text(
                          'Save ${highlight.formattedSavings}',
                          style: ElegantTheme.captionText.copyWith(
                            color: ElegantTheme.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Outbound flight
              _buildFlightRow(
                flight: highlight.outboundFlight,
                label: 'Outbound',
                icon: Icons.flight_takeoff,
                color: ElegantTheme.lightBlue,
              ),

              const SizedBox(height: 12),

              // Return flight
              _buildFlightRow(
                flight: highlight.returnFlight,
                label: 'Return',
                icon: Icons.flight_land,
                color: ElegantTheme.accentOrange,
              ),

              const SizedBox(height: 16),

              // Features
              Row(
                children: [
                  if (highlight.outboundFlight.isRefundable || 
                      highlight.returnFlight.isRefundable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ElegantTheme.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ElegantTheme.accentGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Refundable',
                        style: ElegantTheme.captionText.copyWith(
                          color: ElegantTheme.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (highlight.outboundFlight.isChangeable || 
                      highlight.returnFlight.isChangeable) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ElegantTheme.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ElegantTheme.accentOrange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Changeable',
                        style: ElegantTheme.captionText.copyWith(
                          color: ElegantTheme.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ElegantTheme.accentGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ElegantTheme.accentGold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Round Trip',
                      style: ElegantTheme.captionText.copyWith(
                        color: ElegantTheme.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightRow({
    required Flight flight,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: ElegantTheme.captionText.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${flight.airline} ${flight.flightNumber}',
              style: ElegantTheme.bodyText.copyWith(fontSize: 12),
            ),
          ),
          Text(
            '${_formatTime(flight.departureTime)} - ${_formatTime(flight.arrivalTime)}',
            style: ElegantTheme.captionText,
          ),
          const SizedBox(width: 8),
          Text(
            flight.formattedDuration,
            style: ElegantTheme.captionText.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<RoundTripHighlight> _getSortedHighlights() {
    final highlights = List<RoundTripHighlight>.from(widget.highlights);
    
    switch (_sortBy) {
      case 'price':
        highlights.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
        break;
      case 'duration':
        highlights.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
        break;
      case 'savings':
        highlights.sort((a, b) => b.savings.compareTo(a.savings));
        break;
    }
    
    return highlights;
  }

  String _getMaxSavings() {
    if (widget.highlights.isEmpty) return '₹0';
    final maxSavings = widget.highlights
        .map((h) => h.savings)
        .reduce((a, b) => a > b ? a : b);
    return '₹${maxSavings.toStringAsFixed(0)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

