import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Explore screen for browsing destinations and itineraries
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content with padding
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                children: [
                  // Search bar
                  _buildSearchBar(),
                  const SizedBox(height: AppSpacing.lg),
                  // Tab bar
                  _buildTabBar(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DestinationsTab(),
                  _ItinerariesTab(
                    onSeeAllHistory: () {
                      context.push(AppRoutes.exploreHistory);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // Open search
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.search,
              size: 20,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Search destinations...',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        Expanded(
          child: _TabItem(
            label: 'Destinations',
            isSelected: _selectedTabIndex == 0,
            onTap: () {
              _tabController.animateTo(0);
            },
          ),
        ),
        Expanded(
          child: _TabItem(
            label: 'Itineraries',
            isSelected: _selectedTabIndex == 1,
            onTap: () {
              _tabController.animateTo(1);
            },
          ),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

// Destinations Tab
class _DestinationsTab extends StatelessWidget {
  final _asiaDestinations = const [
    _DestinationData(
      name: 'Thailand',
      region: 'Southeast Asia',
      imageUrl:
          'https://images.unsplash.com/photo-1668781742496-ab54d0d6f4bb?w=400&q=80',
    ),
    _DestinationData(
      name: 'Japan',
      region: 'East Asia',
      imageUrl:
          'https://images.unsplash.com/photo-1713374563263-a7f8d0f86024?w=400&q=80',
    ),
    _DestinationData(
      name: 'Vietnam',
      region: 'Southeast Asia',
      imageUrl:
          'https://images.unsplash.com/photo-1692872031707-4214d2f62adc?w=400&q=80',
    ),
  ];

  final _europeDestinations = const [
    _DestinationData(
      name: 'Italy',
      region: 'Southern Europe',
      imageUrl:
          'https://images.unsplash.com/photo-1682823439973-d9e1ee24d3df?w=400&q=80',
    ),
    _DestinationData(
      name: 'France',
      region: 'Western Europe',
      imageUrl:
          'https://images.unsplash.com/photo-1512075828532-5cf99ad60544?w=400&q=80',
    ),
    _DestinationData(
      name: 'Spain',
      region: 'Southern Europe',
      imageUrl:
          'https://images.unsplash.com/photo-1681385748362-697bd35d363f?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _DestinationSection(
            title: 'Asia',
            destinations: _asiaDestinations,
            onSeeAll: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          _DestinationSection(
            title: 'Europe',
            destinations: _europeDestinations,
            onSeeAll: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _DestinationSection extends StatelessWidget {
  const _DestinationSection({
    required this.title,
    required this.destinations,
    required this.onSeeAll,
  });

  final String title;
  final List<_DestinationData> destinations;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Horizontal scroll of cards
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: destinations.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return _DestinationCard(destination: destinations[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.destination});

  final _DestinationData destination;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.tripSetup);
      },
      child: Container(
        width: 160,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: destination.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ColoredBox(
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
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      destination.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      destination.region,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Itineraries Tab
class _ItinerariesTab extends StatelessWidget {
  const _ItinerariesTab({this.onSeeAllHistory});

  final VoidCallback? onSeeAllHistory;

  static const _popularItineraries = [
    _ItineraryData(
      title: 'Bali Adventure',
      subtitle: 'Indonesia \u00b7 10 days',
      imageUrl:
          'https://images.unsplash.com/photo-1559628272-826045d47dbb?w=400&q=80',
    ),
    _ItineraryData(
      title: 'Paris Weekend',
      subtitle: 'France \u00b7 3 days',
      imageUrl:
          'https://images.unsplash.com/photo-1686087127927-6ec735ddcb1a?w=400&q=80',
    ),
    _ItineraryData(
      title: 'Tokyo Explorer',
      subtitle: 'Japan \u00b7 7 days',
      imageUrl:
          'https://images.unsplash.com/photo-1668392296971-dfa40ea9253e?w=400&q=80',
    ),
  ];

  static const _historyItineraries = [
    _ItineraryData(
      title: 'Ancient Rome',
      subtitle: 'Italy \u00b7 7 days',
      imageUrl:
          'https://images.unsplash.com/photo-1678714873473-fb21921be332?w=400&q=80',
    ),
    _ItineraryData(
      title: 'Egyptian Wonders',
      subtitle: 'Egypt \u00b7 10 days',
      imageUrl:
          'https://images.unsplash.com/photo-1636609586443-e0183b5b549b?w=400&q=80',
    ),
    _ItineraryData(
      title: 'Greek Odyssey',
      subtitle: 'Greece \u00b7 8 days',
      imageUrl:
          'https://images.unsplash.com/photo-1536198899635-446f211a8485?w=400&q=80',
    ),
  ];

  static const _beachItineraries = [
    _ItineraryData(
      title: 'Maldives Escape',
      subtitle: 'Maldives \u00b7 5 days',
      imageUrl:
          'https://images.unsplash.com/photo-1691849233457-837d8e2f9da3?w=400&q=80',
    ),
    _ItineraryData(
      title: 'Phuket Paradise',
      subtitle: 'Thailand \u00b7 7 days',
      imageUrl:
          'https://images.unsplash.com/photo-1737515908826-32c70f8f39cd?w=400&q=80',
    ),
    _ItineraryData(
      title: 'Caribbean Cruise',
      subtitle: 'Multi-country \u00b7 10 days',
      imageUrl:
          'https://images.unsplash.com/photo-1747336755438-e822d83e9383?w=400&q=80',
    ),
  ];

  static const _seasonalItineraries = [
    _ItineraryData(
      title: 'Cherry Blossom',
      subtitle: 'Japan \u00b7 10 days',
      imageUrl:
          'https://images.unsplash.com/photo-1669181173760-73f42d67bc9a?w=400&q=80',
    ),
    _ItineraryData(
      title: 'Northern Lights',
      subtitle: 'Iceland \u00b7 7 days',
      imageUrl:
          'https://images.unsplash.com/photo-1610483527491-b8fe09413a8b?w=400&q=80',
    ),
    _ItineraryData(
      title: 'Fall Foliage',
      subtitle: 'USA \u00b7 5 days',
      imageUrl:
          'https://images.unsplash.com/photo-1736066330739-13796f8c1316?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ItinerarySection(
            title: 'Popular Itineraries',
            itineraries: _popularItineraries,
            onSeeAll: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          _ItinerarySection(
            title: 'History & Culture',
            itineraries: _historyItineraries,
            onSeeAll: onSeeAllHistory,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ItinerarySection(
            title: 'Beach Getaways',
            itineraries: _beachItineraries,
            onSeeAll: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          _ItinerarySection(
            title: 'Seasonal Escapes',
            itineraries: _seasonalItineraries,
            onSeeAll: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ItinerarySection extends StatelessWidget {
  const _ItinerarySection({
    required this.title,
    required this.itineraries,
    this.onSeeAll,
  });

  final String title;
  final List<_ItineraryData> itineraries;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Horizontal scroll of cards
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: itineraries.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return _ItineraryCard(itinerary: itineraries[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _ItineraryCard extends StatelessWidget {
  const _ItineraryCard({required this.itinerary});

  final _ItineraryData itinerary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to itinerary detail
      },
      child: Container(
        width: 160,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: itinerary.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ColoredBox(
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
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      itinerary.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      itinerary.subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data classes
class _DestinationData {
  const _DestinationData({
    required this.name,
    required this.region,
    required this.imageUrl,
  });

  final String name;
  final String region;
  final String imageUrl;
}

class _ItineraryData {
  const _ItineraryData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
}
