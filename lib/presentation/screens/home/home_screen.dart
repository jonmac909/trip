import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/navigation/app_router.dart';
import 'package:trippified/presentation/providers/trips_provider.dart';
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
class _TripsTab extends ConsumerStatefulWidget {
  const _TripsTab();

  @override
  ConsumerState<_TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends ConsumerState<_TripsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_WishlistPlace> _wishlist = [];

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

  @override
  Widget build(BuildContext context) {
    // Watch the provider to rebuild when trips change
    final trips = ref.watch(tripsProvider);
    final upcomingTrips =
        trips.where((t) => t.status == TripStatus.upcoming).toList();
    final draftTrips =
        trips.where((t) => t.status == TripStatus.draft).toList();
    final pastTrips = trips.where((t) => t.status == TripStatus.past).toList();
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
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
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
                  _UpcomingTripsList(trips: upcomingTrips),
                  draftTrips.isEmpty
                      ? _DraftsEmptyState()
                      : _UpcomingTripsList(trips: draftTrips),
                  pastTrips.isEmpty
                      ? _PastTripsEmptyState()
                      : _UpcomingTripsList(trips: pastTrips),
                  _WishlistTab(places: _wishlist),
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
class _UpcomingTripsList extends ConsumerStatefulWidget {
  const _UpcomingTripsList({required this.trips});

  final List<SavedTrip> trips;

  @override
  ConsumerState<_UpcomingTripsList> createState() => _UpcomingTripsListState();
}

class _UpcomingTripsListState extends ConsumerState<_UpcomingTripsList> {
  Timer? _snackBarTimer;

  @override
  void dispose() {
    _snackBarTimer?.cancel();
    super.dispose();
  }

  void _deleteTrip(SavedTrip trip, int index) {
    final notifier = ref.read(tripsProvider.notifier);
    notifier.removeTrip(trip.id);

    // Cancel any existing timer
    _snackBarTimer?.cancel();

    // Clear any existing snackbars first
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text('${trip.title} deleted'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10),
        dismissDirection: DismissDirection.horizontal,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.accent,
          onPressed: () {
            _snackBarTimer?.cancel();
            notifier.insertTrip(index, trip);
          },
        ),
      ),
    );

    // Manually hide after 2 seconds
    _snackBarTimer = Timer(const Duration(seconds: 2), () {
      messenger.hideCurrentSnackBar();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to rebuild when trips change
    final allTrips = ref.watch(tripsProvider);
    final trips = widget.trips;

    if (trips.isEmpty) {
      return _UpcomingEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _SwipeToDeleteCard(
            key: ValueKey(trip.id),
            onDelete: () => _deleteTrip(trip, index),
            child: _HorizontalTripCard(trip: trip),
          ),
        );
      },
    );
  }
}

/// Horizontal trip card matching design 40
class _HorizontalTripCard extends StatelessWidget {
  const _HorizontalTripCard({required this.trip});

  final SavedTrip trip;

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
                  placeholder: (context, url) =>
                      Container(color: AppColors.shimmerBase),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
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
                    if (trip.daysUntil > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: trip.daysUntil <= 60
                              ? AppColors.accent
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          'In ${trip.daysUntil} days',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: trip.daysUntil <= 60
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: trip.daysUntil <= 60
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
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
              ...places.map(
                (place) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WishlistItem(place: place),
                ),
              ),
            ],
          ),
        ),
        // Bottom CTA section
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Semantics(
              button: true,
              label: 'Plan a Trip',
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => context.push(AppRoutes.tripSetup),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    alignment: Alignment.center,
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
                  placeholder: (context, url) =>
                      Container(color: AppColors.shimmerBase),
                  errorWidget: (context, url, error) =>
                      Container(color: AppColors.shimmerBase),
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
                border: Border.all(color: AppColors.borderDark, width: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Swipe to reveal delete button card
class _SwipeToDeleteCard extends StatefulWidget {
  const _SwipeToDeleteCard({
    super.key,
    required this.child,
    required this.onDelete,
  });

  final Widget child;
  final VoidCallback onDelete;

  @override
  State<_SwipeToDeleteCard> createState() => _SwipeToDeleteCardState();
}

class _SwipeToDeleteCardState extends State<_SwipeToDeleteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isOpen = false;

  static const double _deleteButtonWidth = 80.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0), // Slide 20% to reveal button
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta == null) return;

    // Dragging left (negative delta) opens, right (positive) closes
    final delta = -details.primaryDelta! / context.size!.width;
    _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    // If more than 30% open, snap open; otherwise snap closed
    if (_controller.value > 0.3) {
      _controller.forward();
      _isOpen = true;
    } else {
      _controller.reverse();
      _isOpen = false;
    }
  }

  void _close() {
    _controller.reverse();
    _isOpen = false;
  }

  void _handleDelete() {
    _close();
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTap: _isOpen ? _close : null,
      child: Stack(
        children: [
          // Delete button (behind the card)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _handleDelete,
                  child: Container(
                    width: _deleteButtonWidth,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.trash2,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // The actual card that slides
          SlideTransition(position: _slideAnimation, child: widget.child),
        ],
      ),
    );
  }
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
