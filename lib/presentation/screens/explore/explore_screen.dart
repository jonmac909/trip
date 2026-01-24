import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Explore screen for browsing destinations and itineraries
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'Asia',
    'Europe',
    'Americas',
    'Africa',
    'Oceania',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Discover amazing destinations',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search destinations...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: AppColors.primaryLight.withValues(
                        alpha: 0.3,
                      ),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Featured destinations section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Destinations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('See all')),
                  ],
                ),
              ),
            ),

            // Featured destinations grid
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  itemCount: _featuredDestinations.length,
                  itemBuilder: (context, index) {
                    final destination = _featuredDestinations[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: _FeaturedDestinationCard(
                        destination: destination,
                        onTap: () => _onDestinationTap(destination),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            // Popular itineraries section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Itineraries',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('See all')),
                  ],
                ),
              ),
            ),

            // Popular itineraries list
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final itinerary = _popularItineraries[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ItineraryCard(
                      itinerary: itinerary,
                      onTap: () => _onItineraryTap(itinerary),
                    ),
                  );
                }, childCount: _popularItineraries.length),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }

  void _onDestinationTap(_FeaturedDestination destination) {
    // Navigate to trip setup with pre-filled destination
    context.push(
      AppRoutes.tripSetup,
      extra: {'destination': destination.city, 'country': destination.country},
    );
  }

  void _onItineraryTap(_PopularItinerary itinerary) {
    // Navigate to itinerary preview
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening ${itinerary.title}')));
  }

  static const _featuredDestinations = [
    _FeaturedDestination(
      city: 'Tokyo',
      country: 'Japan',
      emoji: '🇯🇵',
      description: 'Ancient temples & modern marvels',
      imageUrl: 'tokyo.jpg',
    ),
    _FeaturedDestination(
      city: 'Paris',
      country: 'France',
      emoji: '🇫🇷',
      description: 'Art, cuisine & romance',
      imageUrl: 'paris.jpg',
    ),
    _FeaturedDestination(
      city: 'Bangkok',
      country: 'Thailand',
      emoji: '🇹🇭',
      description: 'Street food & golden temples',
      imageUrl: 'bangkok.jpg',
    ),
    _FeaturedDestination(
      city: 'Barcelona',
      country: 'Spain',
      emoji: '🇪🇸',
      description: 'Gaudí & Mediterranean vibes',
      imageUrl: 'barcelona.jpg',
    ),
    _FeaturedDestination(
      city: 'Bali',
      country: 'Indonesia',
      emoji: '🇮🇩',
      description: 'Beaches, temples & rice terraces',
      imageUrl: 'bali.jpg',
    ),
  ];

  static const _popularItineraries = [
    _PopularItinerary(
      title: '7 Days in Japan',
      route: 'Tokyo → Kyoto → Osaka',
      duration: '7 days',
      category: 'Cultural',
      saves: 2453,
    ),
    _PopularItinerary(
      title: 'Thailand Explorer',
      route: 'Bangkok → Chiang Mai → Islands',
      duration: '10 days',
      category: 'Adventure',
      saves: 1876,
    ),
    _PopularItinerary(
      title: 'Italian Classics',
      route: 'Rome → Florence → Venice',
      duration: '9 days',
      category: 'Cultural',
      saves: 1654,
    ),
    _PopularItinerary(
      title: 'Ultimate Portugal',
      route: 'Lisbon → Porto → Algarve',
      duration: '8 days',
      category: 'Food & Wine',
      saves: 1243,
    ),
  ];
}

/// Featured destination data
class _FeaturedDestination {
  const _FeaturedDestination({
    required this.city,
    required this.country,
    required this.emoji,
    required this.description,
    required this.imageUrl,
  });

  final String city;
  final String country;
  final String emoji;
  final String description;
  final String imageUrl;
}

/// Featured destination card
class _FeaturedDestinationCard extends StatelessWidget {
  const _FeaturedDestinationCard({
    required this.destination,
    required this.onTap,
  });

  final _FeaturedDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: Center(
                child: Text(
                  destination.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.city,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destination.country,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destination.description,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

/// Popular itinerary data
class _PopularItinerary {
  const _PopularItinerary({
    required this.title,
    required this.route,
    required this.duration,
    required this.category,
    required this.saves,
  });

  final String title;
  final String route;
  final String duration;
  final String category;
  final int saves;
}

/// Itinerary card
class _ItineraryCard extends StatelessWidget {
  const _ItineraryCard({required this.itinerary, required this.onTap});

  final _PopularItinerary itinerary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icon/Image placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.map_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          itinerary.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          itinerary.duration,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itinerary.route,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.bookmark_outline,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${itinerary.saves}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          itinerary.category,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
