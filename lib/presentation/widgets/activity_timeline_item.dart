import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Enum for timeline item types
enum TimelineItemType {
  activity,
  meal,
  flight,
  hotel,
}

/// Booking status for activities
enum BookingStatus {
  none,
  booked,
  needsBooking,
}

/// Data class for activity timeline items
class ActivityTimelineData {
  const ActivityTimelineData({
    required this.id,
    required this.name,
    required this.time,
    required this.location,
    required this.type,
    this.description,
    this.duration,
    this.imageUrl,
    this.bookingStatus = BookingStatus.none,
  });

  final String id;
  final String name;
  final String time;
  final String location;
  final TimelineItemType type;
  final String? description;
  final String? duration;
  final String? imageUrl;
  final BookingStatus bookingStatus;
}

/// Data class for flight ticket items
class FlightTicketData {
  const FlightTicketData({
    required this.departureTime,
    required this.departureCode,
    required this.arrivalTime,
    required this.arrivalCode,
    required this.duration,
    required this.flightNumber,
  });

  final String departureTime;
  final String departureCode;
  final String arrivalTime;
  final String arrivalCode;
  final String duration;
  final String flightNumber;
}

/// Data class for hotel ticket items
class HotelTicketData {
  const HotelTicketData({
    required this.name,
    required this.dates,
    required this.nights,
    required this.location,
    this.imageUrl,
  });

  final String name;
  final String dates;
  final int nights;
  final String location;
  final String? imageUrl;
}

/// Data class for travel time between activities
class TravelTimeData {
  const TravelTimeData({
    required this.duration,
    required this.mode,
  });

  final String duration;
  final TravelMode mode;
}

/// Travel mode enum
enum TravelMode {
  walk,
  taxi,
  train,
  bus,
}

/// Activity timeline item widget
class ActivityTimelineItem extends StatelessWidget {
  const ActivityTimelineItem({
    required this.activity,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final ActivityTimelineData activity;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Thumbnail
            if (activity.imageUrl != null)
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  color: AppColors.shimmerBase,
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: activity.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.shimmerBase,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.shimmerBase,
                    child: Icon(
                      _getIconForType(activity.type),
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          activity.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (activity.bookingStatus != BookingStatus.none) ...[
                        const SizedBox(width: 8),
                        _buildBookingBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Description row
                  Text(
                    '${activity.time} \u00b7 ${activity.location}${activity.description != null ? ' \u00b7 ${activity.description}' : ''}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration
            if (activity.duration != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    activity.duration!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingBadge() {
    final isBooked = activity.bookingStatus == BookingStatus.booked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        isBooked ? 'Booked' : 'Need to book',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isBooked ? AppColors.primary : const Color(0xFFE65100),
        ),
      ),
    );
  }

  IconData _getIconForType(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.activity:
        return LucideIcons.mapPin;
      case TimelineItemType.meal:
        return LucideIcons.utensils;
      case TimelineItemType.flight:
        return LucideIcons.plane;
      case TimelineItemType.hotel:
        return LucideIcons.bedDouble;
    }
  }
}

/// Flight ticket card in timeline
class FlightTicketCard extends StatelessWidget {
  const FlightTicketCard({
    required this.flight,
    this.onViewReservation,
    super.key,
  });

  final FlightTicketData flight;
  final VoidCallback? onViewReservation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.plane,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Flight',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewReservation,
                child: Row(
                  children: [
                    Text(
                      'View Reservation',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Flight info row
          Row(
            children: [
              // Departure
              Column(
                children: [
                  Text(
                    flight.departureTime,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    flight.departureCode,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Flight line
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppColors.border,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${flight.duration} \u00b7 ${flight.flightNumber}',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrival
              Column(
                children: [
                  Text(
                    flight.arrivalTime,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    flight.arrivalCode,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hotel ticket card in timeline
class HotelTicketCard extends StatelessWidget {
  const HotelTicketCard({
    required this.hotel,
    this.onViewReservation,
    super.key,
  });

  final HotelTicketData hotel;
  final VoidCallback? onViewReservation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.bedDouble,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hotel',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewReservation,
                child: Row(
                  children: [
                    Text(
                      'View Reservation',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Hotel info row
          Row(
            children: [
              // Thumbnail
              if (hotel.imageUrl != null)
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    color: AppColors.shimmerBase,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: hotel.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.shimmerBase,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.shimmerBase,
                      child: const Icon(
                        LucideIcons.bedDouble,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hotel.dates} \u00b7 ${hotel.nights} nights \u00b7 ${hotel.location}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

/// Travel time connector between activities
class TravelTimeConnector extends StatelessWidget {
  const TravelTimeConnector({
    required this.travelTime,
    super.key,
  });

  final TravelTimeData travelTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Container(
            width: 1,
            height: 16,
            color: AppColors.border,
          ),
          const SizedBox(width: 8),
          Icon(
            _getIconForMode(travelTime.mode),
            size: 14,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            travelTime.duration,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMode(TravelMode mode) {
    switch (mode) {
      case TravelMode.walk:
        return LucideIcons.footprints;
      case TravelMode.taxi:
        return LucideIcons.car;
      case TravelMode.train:
        return LucideIcons.train;
      case TravelMode.bus:
        return LucideIcons.bus;
    }
  }
}

/// Time period label (Morning, Midday, Afternoon, Evening)
class TimePeriodLabel extends StatelessWidget {
  const TimePeriodLabel({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
