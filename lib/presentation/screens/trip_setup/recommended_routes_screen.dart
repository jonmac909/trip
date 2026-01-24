import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Screen showing recommended routes/itineraries for a destination
class RecommendedRoutesScreen extends StatefulWidget {
  const RecommendedRoutesScreen({
    required this.destination,
    required this.country,
    required this.startDate,
    required this.endDate,
    required this.travelers,
    super.key,
  });

  final String destination;
  final String country;
  final DateTime startDate;
  final DateTime endDate;
  final int travelers;

  @override
  State<RecommendedRoutesScreen> createState() =>
      _RecommendedRoutesScreenState();
}

class _RecommendedRoutesScreenState extends State<RecommendedRoutesScreen> {
  int? _selectedRouteIndex;

  @override
  Widget build(BuildContext context) {
    final tripDays = widget.endDate.difference(widget.startDate).inDays + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.destination} Routes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Trip summary header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$tripDays days',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: AppSpacing.lg),
                const Icon(Icons.people, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${widget.travelers} ${widget.travelers == 1 ? 'traveler' : 'travelers'}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Routes list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Text(
                  'Recommended Routes',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose a pre-built itinerary or create your own',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Route cards
                ..._getRoutesForDestination(
                  widget.destination,
                  tripDays,
                ).asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _RouteCard(
                      route: entry.value,
                      isSelected: _selectedRouteIndex == entry.key,
                      onTap: () {
                        setState(() {
                          _selectedRouteIndex = entry.key;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Custom route option
                _CustomRouteCard(
                  isSelected: _selectedRouteIndex == -1,
                  onTap: () {
                    setState(() {
                      _selectedRouteIndex = -1;
                    });
                  },
                ),
              ],
            ),
          ),

          // Bottom action buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: FilledButton(
                onPressed: _selectedRouteIndex != null ? _onContinue : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  _selectedRouteIndex == -1
                      ? 'Start from scratch'
                      : 'Use this route',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onContinue() {
    // Navigate to itinerary builder
    context.push(
      AppRoutes.itineraryBuilder,
      extra: {
        'destination': widget.destination,
        'country': widget.country,
        'startDate': widget.startDate,
        'endDate': widget.endDate,
        'travelers': widget.travelers,
        'routeIndex': _selectedRouteIndex,
      },
    );
  }

  List<_RecommendedRoute> _getRoutesForDestination(
    String destination,
    int days,
  ) {
    // Demo routes - will be replaced with API data
    final routes = <String, List<_RecommendedRoute>>{
      'Tokyo': [
        const _RecommendedRoute(
          name: 'Classic Tokyo',
          description: 'Experience the best of traditional and modern Tokyo',
          highlights: [
            'Senso-ji Temple',
            'Shibuya Crossing',
            'Harajuku',
            'Shinjuku',
          ],
          imageUrl:
              'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf',
          daysRecommended: 5,
          category: 'Cultural',
        ),
        const _RecommendedRoute(
          name: "Foodie's Paradise",
          description: 'Explore Tokyo through its incredible cuisine',
          highlights: [
            'Tsukiji Market',
            'Ramen Street',
            'Izakaya Tour',
            'Depachika',
          ],
          imageUrl: 'https://images.unsplash.com/photo-1551218808-94e220e084d2',
          daysRecommended: 4,
          category: 'Food & Drink',
        ),
        const _RecommendedRoute(
          name: 'Tokyo & Kyoto',
          description: 'Combine modern Tokyo with historic Kyoto',
          highlights: [
            'Tokyo Highlights',
            'Shinkansen',
            'Fushimi Inari',
            'Arashiyama',
          ],
          imageUrl:
              'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e',
          daysRecommended: 7,
          category: 'Multi-City',
        ),
      ],
      'Paris': [
        const _RecommendedRoute(
          name: 'Romantic Paris',
          description: 'The perfect romantic getaway in the City of Light',
          highlights: [
            'Eiffel Tower',
            'Montmartre',
            'Seine Cruise',
            'Le Marais',
          ],
          imageUrl:
              'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
          daysRecommended: 4,
          category: 'Romance',
        ),
        const _RecommendedRoute(
          name: "Art Lover's Paris",
          description: 'Discover world-class museums and galleries',
          highlights: [
            'Louvre',
            "Musée d'Orsay",
            'Centre Pompidou',
            'Rodin Museum',
          ],
          imageUrl:
              'https://images.unsplash.com/photo-1499856871958-5b9627545d1a',
          daysRecommended: 5,
          category: 'Art & Culture',
        ),
      ],
      'Bangkok': [
        const _RecommendedRoute(
          name: 'Bangkok Essentials',
          description: 'The must-see temples, markets, and street food',
          highlights: ['Grand Palace', 'Wat Pho', 'Chatuchak', 'Khao San Road'],
          imageUrl:
              'https://images.unsplash.com/photo-1508009603885-50cf7c8a1550',
          daysRecommended: 3,
          category: 'Cultural',
        ),
        const _RecommendedRoute(
          name: 'Thailand Explorer',
          description: 'Bangkok, Chiang Mai, and the islands',
          highlights: ['Bangkok', 'Chiang Mai', 'Phuket', 'Island Hopping'],
          imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a',
          daysRecommended: 10,
          category: 'Adventure',
        ),
      ],
    };

    return routes[destination] ??
        [
          _RecommendedRoute(
            name: 'Popular Highlights',
            description: 'The best attractions and experiences',
            highlights: [
              'Top Attractions',
              'Local Food',
              'Hidden Gems',
              'Photo Spots',
            ],
            imageUrl:
                'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
            daysRecommended: days,
            category: 'General',
          ),
        ];
  }
}

/// Route data model
class _RecommendedRoute {
  const _RecommendedRoute({
    required this.name,
    required this.description,
    required this.highlights,
    required this.imageUrl,
    required this.daysRecommended,
    required this.category,
  });

  final String name;
  final String description;
  final List<String> highlights;
  final String imageUrl;
  final int daysRecommended;
  final String category;
}

/// Route card widget
class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  final _RecommendedRoute route;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Text(
                        route.category,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Selection indicator
                  if (isSelected)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          route.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          '${route.daysRecommended} days',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    route.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Highlights
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: route.highlights
                        .map((h) => _HighlightChip(text: h))
                        .toList(),
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

/// Highlight chip widget
class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.primary),
      ),
    );
  }
}

/// Custom route card for starting from scratch
class _CustomRouteCard extends StatelessWidget {
  const _CustomRouteCard({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
            style: isSelected ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.add, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Custom Itinerary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Build your own trip from scratch',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.textOnPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
