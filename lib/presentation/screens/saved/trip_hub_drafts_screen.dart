import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Screen showing draft trips in the Trip Hub
class TripHubDraftsScreen extends StatefulWidget {
  const TripHubDraftsScreen({super.key});

  @override
  State<TripHubDraftsScreen> createState() => _TripHubDraftsScreenState();
}

class _TripHubDraftsScreenState extends State<TripHubDraftsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Draft trips - populated from provider
  final List<_DraftTrip> _draftTrips = const [];

  @override
  void initState() {
    super.initState();
    // Initialize with Drafts tab (index 2) selected
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Trips',
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Tabs
                _buildTabs(),
                const SizedBox(height: AppSpacing.lg),

                // Trips list
                Expanded(
                  child: _buildTripsList(),
                ),
              ],
            ),

            // FAB
            Positioned(
              right: AppSpacing.lg,
              bottom: 100,
              child: _buildAddButton(),
            ),

            // Bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNav(
                currentIndex: 0,
                onTap: (index) {
                  if (index != 0) {
                    context.go(AppRoutes.home);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        isScrollable: false,
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(text: 'Upcoming', height: 44),
          Tab(text: 'Past', height: 44),
          Tab(text: 'Drafts', height: 44),
          Tab(text: 'Wishlist', height: 44),
        ],
      ),
    );
  }

  Widget _buildTripsList() {
    if (_draftTrips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          children: [
            const Spacer(flex: 3),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.fileEdit,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No drafts yet',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start planning a trip to see your drafts here',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 4),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: _draftTrips
          .map((trip) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _DraftTripCard(
                  trip: trip,
                  onTap: () {
                    context.push('/trip/${trip.id}');
                  },
                ),
              ))
          .toList(),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.tripSetup);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(8),
        child: const Icon(
          LucideIcons.plus,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _DraftTripCard extends StatelessWidget {
  const _DraftTripCard({required this.trip, this.onTap});

  final _DraftTrip trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 120,
              height: double.infinity,
              child: CachedNetworkImage(
                imageUrl: trip.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.shimmerBase,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.shimmerBase,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title row with edit icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trip.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        LucideIcons.pencil,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Duration and places
                  Text(
                    '${trip.days} days \u00b7 ${trip.placeCount} places',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Draft badge
                  Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        'Draft',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Cities
                  Flexible(
                    child: Row(
                      children: trip.cities
                          .map((city) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  city,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _DraftTrip {
  const _DraftTrip({
    required this.id,
    required this.name,
    required this.days,
    required this.placeCount,
    required this.cities,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final int days;
  final int placeCount;
  final List<String> cities;
  final String imageUrl;
}
