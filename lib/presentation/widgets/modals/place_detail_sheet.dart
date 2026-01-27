import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/domain/models/place.dart';

/// Ticket status for place detail sheet
enum TicketStatus {
  /// No ticket required or not showing ticket section
  none,

  /// User has a ticket - shows "Your Ticket" with View button
  hasTicket,

  /// Reservation required but not booked - shows "Reservation Required" with Book button
  needsBooking,
}

/// Ticket information for booked tickets
class TicketInfo {
  const TicketInfo({
    required this.date,
    required this.time,
    required this.quantity,
  });

  final String date;
  final String time;
  final String quantity;

  String get displayString => '$date \u00b7 $time \u00b7 $quantity';
}

/// Bottom sheet modal for displaying place details
/// Matches designs 66-67 (Place Detail Modal variants)
class PlaceDetailSheet extends StatelessWidget {
  const PlaceDetailSheet({
    super.key,
    required this.place,
    this.hasTicket = false,
    this.ticketStatus = TicketStatus.none,
    this.ticketInfo,
    this.onSave,
    this.onViewMap,
    this.onViewTicket,
    this.onBookTicket,
  });

  final Place place;

  /// @deprecated Use [ticketStatus] instead
  final bool hasTicket;

  /// Current ticket status for this place
  final TicketStatus ticketStatus;

  /// Ticket details when ticketStatus is [TicketStatus.hasTicket]
  final TicketInfo? ticketInfo;

  final VoidCallback? onSave;
  final VoidCallback? onViewMap;

  /// Called when user taps "View" on their ticket
  final VoidCallback? onViewTicket;

  /// Called when user taps "Book" for reservation
  final VoidCallback? onBookTicket;

  /// Get effective ticket status, considering legacy hasTicket flag
  TicketStatus get _effectiveTicketStatus {
    if (ticketStatus != TicketStatus.none) {
      return ticketStatus;
    }
    // Legacy support
    if (hasTicket) {
      return TicketStatus.hasTicket;
    }
    return TicketStatus.none;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              _buildHandleBar(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroImage(context),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPlaceHeader(),
                            const SizedBox(height: AppSpacing.md),
                            _buildOpeningHours(),
                            if (_effectiveTicketStatus != TicketStatus.none) ...[
                              const SizedBox(height: AppSpacing.md),
                              _buildTicketSection(),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            _buildAboutSection(),
                            const SizedBox(height: AppSpacing.md),
                            _buildActionButtons(context),
                            if (place.tips.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              _buildTipsSection(),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: double.infinity,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderDark,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: CachedNetworkImage(
              imageUrl: place.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.shimmerBase,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.shimmerBase,
                child: const Icon(
                  LucideIcons.image,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.x,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${place.location} \u00b7 ${place.type.displayName}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    LucideIcons.star,
                    size: 14,
                    color: Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${place.rating} \u00b7 ${_formatReviewCount(place.reviewCount)} reviews',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onSave,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.bookmark,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpeningHours() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.clock3,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Opening Hours',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: place.isOpen ? AppColors.accent : AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  place.isOpen ? 'Open now' : 'Closed',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        place.isOpen ? AppColors.primary : AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            place.openingHours ?? 'Hours not available',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSection() {
    final status = _effectiveTicketStatus;

    if (status == TicketStatus.hasTicket) {
      return _buildViewTicketSection();
    }
    return _buildBookTicketSection();
  }

  /// Build "Your Ticket" section with View button (design 66)
  Widget _buildViewTicketSection() {
    const ticketGreen = Color(0xFF2E7D32);
    final ticketDetails = ticketInfo?.displayString ?? 'Booked for your trip';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Ticket icon
          const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              LucideIcons.ticket,
              size: 22,
              color: ticketGreen,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Ticket',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ticketDetails,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // View button
          GestureDetector(
            onTap: onViewTicket,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'View',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build "Reservation Required" section with Book button (design 67)
  Widget _buildBookTicketSection() {
    const reservationOrange = Color(0xFFE65100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Calendar icon
          const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              LucideIcons.calendar,
              size: 22,
              color: reservationOrange,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservation Required',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Advance booking required',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Book button (lime accent)
          GestureDetector(
            onTap: onBookTicket,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Book',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          place.description ?? 'No description available.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            height: 1.5,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onSave ?? () {},
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.bookmark,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save Place',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onViewMap ?? () {},
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              LucideIcons.mapPin,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...place.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u00b7',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
  }
}
