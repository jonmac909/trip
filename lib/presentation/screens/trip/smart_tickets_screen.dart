import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';

/// Smart Tickets screen showing booking suggestions for the trip
/// Matches designs 64-65 (Smart Tickets - Tokyo/Hanoi)
class SmartTicketsScreen extends StatefulWidget {
  const SmartTicketsScreen({
    required this.tripId,
    required this.cityName,
    required this.days,
    super.key,
  });

  final String tripId;
  final String cityName;
  final int days;

  @override
  State<SmartTicketsScreen> createState() => _SmartTicketsScreenState();
}

class _SmartTicketsScreenState extends State<SmartTicketsScreen> {
  int _selectedTab = 2; // Bookings tab active
  int _selectedDay = 0;
  int _bottomNavIndex = 0;

  // Mock ticket data - would come from provider
  late List<_TicketData> _tickets;

  @override
  void initState() {
    super.initState();
    _tickets = _getMockTickets();
  }

  List<_TicketData> _getMockTickets() {
    if (widget.cityName.toLowerCase() == 'hanoi') {
      return [
        _TicketData(
          id: '1',
          name: 'Ho Chi Minh Mausoleum',
          details: 'Feb 22 \u00b7 8:00 AM \u00b7 2 tickets',
          imageUrl:
              'https://images.unsplash.com/photo-1509030450996-dd1a26dda07a?w=400&q=80',
          hasTicket: true,
        ),
        _TicketData(
          id: '2',
          name: 'Ha Long Bay Cruise',
          details: 'Feb 23 \u00b7 7:00 AM \u00b7 Day trip',
          imageUrl:
              'https://images.unsplash.com/photo-1528127269322-539801943592?w=400&q=80',
          hasTicket: true,
        ),
        _TicketData(
          id: '3',
          name: 'Water Puppet Theatre',
          details: 'Feb 24 \u00b7 8:00 PM \u00b7 2 seats',
          imageUrl:
              'https://images.unsplash.com/photo-1555921015-5532091f6026?w=400&q=80',
          hasTicket: true,
        ),
      ];
    }
    // Tokyo default
    return [
      _TicketData(
        id: '1',
        name: 'teamLab Borderless',
        details: 'Feb 11 \u00b7 10:00 AM \u00b7 2 tickets',
        imageUrl:
            'https://images.unsplash.com/photo-1705807671058-db6c317df87e?w=400&q=80',
        hasTicket: true,
      ),
      _TicketData(
        id: '2',
        name: 'Sukiyabashi Jiro',
        details: 'Feb 11 \u00b7 7:00 PM \u00b7 2 seats',
        imageUrl:
            'https://images.unsplash.com/photo-1543902896-59b85e2fb6ac?w=400&q=80',
        hasTicket: true,
      ),
      _TicketData(
        id: '3',
        name: 'Shinkansen to Kyoto',
        details: 'Feb 14 \u00b7 10:30 AM \u00b7 Nozomi 225',
        iconData: LucideIcons.train,
        iconColor: const Color(0xFF2196F3),
        hasTicket: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildMapSection(context),
          Expanded(
            child: _buildContentSection(),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // Map background image
          Container(
            width: double.infinity,
            height: 280,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1548345680-f5475ea5df84?w=800&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Collapse bar at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTabsRow(),
          Expanded(
            child: _buildTicketsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${widget.days} Days in ${widget.cityName}',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    LucideIcons.chevronDown,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              // Edit badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.pencil,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Edit',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day tabs
          _buildDayTabs(),
        ],
      ),
    );
  }

  Widget _buildDayTabs() {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.days, (index) {
          final isSelected = _selectedDay == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              child: Text(
                'Day ${index + 1}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabsRow() {
    final tabs = ['Overview', 'Itinerary', 'Bookings'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTicketsList() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ..._tickets.map(
          (ticket) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.listItemSpacing),
            child: _TicketCard(
              ticket: ticket,
              onView: () => _showTicketDetails(ticket),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _buildAddTicketButton(),
      ],
    );
  }

  Widget _buildAddTicketButton() {
    return GestureDetector(
      onTap: () {
        // Add ticket action
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.plus,
              size: 18,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Ticket',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDetails(_TicketData ticket) {
    // Navigate to ticket details or show modal
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.onView,
  });

  final _TicketData ticket;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image or Icon
          _buildLeading(),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.details,
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
            onTap: onView,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'View',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeading() {
    if (ticket.iconData != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          ticket.iconData,
          size: 24,
          color: ticket.iconColor ?? AppColors.info,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: CachedNetworkImage(
          imageUrl: ticket.imageUrl ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(color: AppColors.shimmerBase),
          errorWidget: (context, url, error) => Container(
            color: AppColors.shimmerBase,
            child: const Icon(
              LucideIcons.ticket,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketData {
  const _TicketData({
    required this.id,
    required this.name,
    required this.details,
    this.imageUrl,
    this.iconData,
    this.iconColor,
    this.hasTicket = false,
  });

  final String id;
  final String name;
  final String details;
  final String? imageUrl;
  final IconData? iconData;
  final Color? iconColor;
  final bool hasTicket;
}
