import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/navigation/app_router.dart';
import 'package:trippified/presentation/screens/explore/explore_screen.dart';
import 'package:trippified/presentation/screens/profile/profile_screen.dart';
import 'package:trippified/presentation/screens/saved/saved_screen.dart';

/// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _TripsTab(),
          ExploreScreen(),
          SavedScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

/// Trips tab content with tabs
class _TripsTab extends StatefulWidget {
  const _TripsTab();

  @override
  State<_TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<_TripsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - replace with actual data from provider
  final List<_TripData> _mockTrips = [
    _TripData(
      id: '1',
      title: 'Japan Adventure',
      imageUrl:
          'https://images.unsplash.com/photo-1743515169286-7be1203c641a?w=400&q=80',
      dates: 'Mar 15 - Mar 28',
      daysUntil: 52,
      cityNames: ['Tokyo', 'Kyoto', 'Osaka'],
      status: TripStatus.upcoming,
    ),
    _TripData(
      id: '2',
      title: 'Europe Trip',
      imageUrl:
          'https://images.unsplash.com/photo-1756623586068-25f5e8fcfdfd?w=400&q=80',
      dates: 'Jun 1 - Jun 21',
      daysUntil: 98,
      cityNames: ['Paris', 'Rome'],
      status: TripStatus.upcoming,
    ),
  ];

  final List<_WishlistPlace> _mockWishlist = [
    _WishlistPlace(
      id: '1',
      name: 'Santorini, Greece',
      imageUrl:
          'https://images.unsplash.com/photo-1719607526486-96f27a995fcc?w=200&q=80',
      addedAgo: '2 weeks ago',
    ),
    _WishlistPlace(
      id: '2',
      name: 'Kyoto, Japan',
      imageUrl:
          'https://images.unsplash.com/photo-1764271835340-125ed53e197d?w=200&q=80',
      addedAgo: '1 month ago',
    ),
    _WishlistPlace(
      id: '3',
      name: 'Bali, Indonesia',
      imageUrl:
          'https://images.unsplash.com/photo-1735991088724-1a83f2739168?w=200&q=80',
      addedAgo: '1 month ago',
    ),
    _WishlistPlace(
      id: '4',
      name: 'Amalfi Coast, Italy',
      imageUrl:
          'https://images.unsplash.com/photo-1551548703-d5a3d343a264?w=200&q=80',
      addedAgo: '3 months ago',
    ),
    _WishlistPlace(
      id: '5',
      name: 'Marrakech, Morocco',
      imageUrl:
          'https://images.unsplash.com/photo-1716146755954-4f197a5b6031?w=200&q=80',
      addedAgo: '3 months ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_TripData> _getTripsForStatus(TripStatus status) {
    return _mockTrips.where((t) => t.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final showFab = _tabController.index != 3;
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: showFab
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push(AppRoutes.tripSetup),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      LucideIcons.plus,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            // Header - "My Trips" 24px w700
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'My Trips',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Tab bar with underline style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: AppColors.border,
                isScrollable: false,
                labelPadding: EdgeInsets.zero,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Drafts'),
                  Tab(text: 'Past'),
                  Tab(text: 'Wishlist'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _UpcomingTripsList(
                    trips: _getTripsForStatus(TripStatus.upcoming),
                  ),
                  _DraftsEmptyState(),
                  _PastTripsEmptyState(),
                  _WishlistTab(places: _mockWishlist),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Upcoming trips list with horizontal trip cards
class _UpcomingTripsList extends StatelessWidget {
  const _UpcomingTripsList({required this.trips});

  final List<_TripData> trips;

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return _UpcomingEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _HorizontalTripCard(trip: trips[index]),
        );
      },
    );
  }
}

/// Horizontal trip card matching design 40
class _HorizontalTripCard extends StatelessWidget {
  const _HorizontalTripCard({required this.trip});

  final _TripData trip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/trip/${trip.id}');
      },
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
            // Image on left - 120x120 with rounded corners on left
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
                    child: const Icon(
                      LucideIcons.image,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            // Content on right
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
                        Flexible(
                          child: Text(
                            trip.title,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          LucideIcons.pencil,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Dates
                    Text(
                      trip.dates,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Countdown badge
                    if (trip.daysUntil != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: trip.daysUntil! <= 60
                              ? AppColors.accent
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          'In ${trip.daysUntil} days',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: trip.daysUntil! <= 60
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: trip.daysUntil! <= 60
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    // City flow
                    if (trip.cityNames.isNotEmpty)
                      Flexible(
                        child: Row(
                          children: trip.cityNames.asMap().entries.map((entry) {
                            final isLast =
                                entry.key == trip.cityNames.length - 1;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  entry.value,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (!isLast)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      '\u2192',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
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

/// Empty state for Upcoming trips tab (design 41)
class _UpcomingEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            child: const Center(
              child: Icon(
                LucideIcons.luggage,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No trips yet',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start planning your next adventure',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => context.push(AppRoutes.tripSetup),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.plus,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Plan a Trip',
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
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

/// Empty state for Drafts tab (design 43)
class _DraftsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            child: const Center(
              child: Icon(
                LucideIcons.pencil,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No dates? No problem.',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: 260,
            child: Text(
              'Store your trip ideas here until you\'re ready to plan.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

/// Empty state for Past trips tab
class _PastTripsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            child: const Center(
              child: Icon(
                LucideIcons.history,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No past trips',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your completed trips will appear here',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

/// Wishlist tab (design 42)
class _WishlistTab extends StatelessWidget {
  const _WishlistTab({required this.places});

  final List<_WishlistPlace> places;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              // Add place input row
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.plus,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add a place to your wishlist...',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Wishlist items
              ...places.map((place) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _WishlistItem(place: place),
                  )),
            ],
          ),
        ),
        // Bottom CTA section
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: SafeArea(
            top: false,
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.tripSetup),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.sparkles,
                      size: 18,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Plan a Trip',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Wishlist place item (design 42)
class _WishlistItem extends StatelessWidget {
  const _WishlistItem({required this.place});

  final _WishlistPlace place;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.tripSetup);
      },
      child: Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Place image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CachedNetworkImage(
                imageUrl: place.imageUrl,
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
          const SizedBox(width: 12),
          // Place info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  place.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Added ${place.addedAgo}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Selection circle
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderDark,
                width: 1,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

enum TripStatus { upcoming, draft, past, wishlist }

class _TripData {
  const _TripData({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.dates,
    required this.status,
    this.daysUntil,
    this.cityNames = const [],
  });

  final String id;
  final String title;
  final String imageUrl;
  final String dates;
  final int? daysUntil;
  final List<String> cityNames;
  final TripStatus status;
}

class _WishlistPlace {
  const _WishlistPlace({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.addedAgo,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String addedAgo;
}
