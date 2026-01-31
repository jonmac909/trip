import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/domain/models/place.dart';
import 'package:trippified/presentation/navigation/app_router.dart';
import 'package:trippified/presentation/widgets/modals/place_detail_sheet.dart';

/// City detail screen with tabs for Overview, Things to Do, and Itineraries
class CityDetailScreen extends StatefulWidget {
  const CityDetailScreen({
    super.key,
    required this.cityId,
    this.cityName,
    this.region,
    this.imageUrl,
  });

  final String cityId;
  final String? cityName;
  final String? region;
  final String? imageUrl;

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  // Mock data - replace with actual data source
  String get _cityName => widget.cityName ?? 'Chiang Mai';
  String get _region => widget.region ?? 'Northern Thailand';
  String get _imageUrl =>
      widget.imageUrl ??
      'https://images.unsplash.com/photo-1512553353614-82a7370096dc?w=800&q=80';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildHeroSection(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(cityName: _cityName),
                      _ThingsToDoTab(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: (filter) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        onPlaceTap: _showPlaceDetailSheet,
                      ),
                      _ItinerariesTab(
                        cityName: _cityName,
                        onItineraryTap: (itineraryId) {
                          context.push('/explore/itinerary/$itineraryId');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppBottomNav(
            currentIndex: 1,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go(AppRoutes.home);
                case 1:
                  context.pop();
                case 2:
                  context.go(AppRoutes.saved);
                case 3:
                  context.go(AppRoutes.profile);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: _imageUrl,
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
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
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
          // City name overlay
          Positioned(
            left: 24,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cityName,
                  style: GoogleFonts.dmSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _region,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Overview',
            isSelected: _selectedTabIndex == 0,
            onTap: () => _tabController.animateTo(0),
          ),
          _TabButton(
            label: 'Things to Do',
            isSelected: _selectedTabIndex == 1,
            onTap: () => _tabController.animateTo(1),
          ),
          _TabButton(
            label: 'Itineraries',
            isSelected: _selectedTabIndex == 2,
            onTap: () => _tabController.animateTo(2),
          ),
        ],
      ),
    );
  }

  void _showPlaceDetailSheet(Place place) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailSheet(place: place),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
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
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// Overview Tab
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The cultural capital of Northern Thailand, $cityName is a haven for '
            'temple lovers, foodies, and nature enthusiasts. Surrounded by misty '
            'mountains and home to over 300 temples.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickGlance(),
          const SizedBox(height: AppSpacing.lg),
          _buildAlerts(),
        ],
      ),
    );
  }

  Widget _buildQuickGlance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick glance',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: const [
            _QuickGlanceTag(emoji: '\u{1F6D5}', label: 'Temples'),
            _QuickGlanceTag(emoji: '\u{1F418}', label: 'Elephants'),
            _QuickGlanceTag(emoji: '\u{1F35C}', label: 'Khao Soi'),
            _QuickGlanceTag(emoji: '\u{26F0}\u{FE0F}', label: 'Mountains'),
            _QuickGlanceTag(emoji: '\u{1F3A8}', label: 'Crafts'),
          ],
        ),
      ],
    );
  }

  Widget _buildAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alerts',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _AlertItem(
          icon: LucideIcons.sun,
          text: 'Best time: Nov - Feb (cool season)',
          color: Color(0xFF5B21B6),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _AlertItem(
          icon: LucideIcons.wind,
          text: 'Burning season: Feb - Apr (hazy)',
          color: Color(0xFF6B21A8),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _AlertItem(
          icon: LucideIcons.mapPin,
          text: '1hr flight from Bangkok',
          color: Color(0xFF5B21B6),
        ),
      ],
    );
  }
}

class _QuickGlanceTag extends StatelessWidget {
  const _QuickGlanceTag({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$emoji $label',
      style: GoogleFonts.dmSans(
        fontSize: 13,
        color: AppColors.secondary,
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Things to Do Tab
class _ThingsToDoTab extends StatelessWidget {
  const _ThingsToDoTab({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onPlaceTap,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<Place> onPlaceTap;

  static final _filters = ['All', 'Temples', 'Nature', 'Food'];

  // Places loaded from API - empty until fetched
  static final List<Place> _mockPlaces = [];

  String _getTagColor(PlaceType type) {
    switch (type) {
      case PlaceType.attraction:
        return '#7C3AED'; // Purple for temples/attractions
      case PlaceType.restaurant:
        return '#D97706'; // Amber for food
      case PlaceType.shopping:
        return '#2563EB'; // Blue for markets
      case PlaceType.hotel:
        return '#059669'; // Green
      case PlaceType.cafe:
        return '#8B5CF6'; // Violet
      case PlaceType.bar:
        return '#DC2626'; // Red
    }
  }

  String _getTagLabel(Place place) {
    // Simplified tag logic
    if (place.name.toLowerCase().contains('temple')) return 'Temple';
    if (place.name.toLowerCase().contains('elephant') ||
        place.name.toLowerCase().contains('nature')) return 'Nature';
    if (place.type == PlaceType.restaurant) return 'Food';
    if (place.type == PlaceType.shopping) return 'Market';
    return place.type.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _filters.map((filter) {
              final isSelected = filter == selectedFilter;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => onFilterChanged(filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      filter,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Places list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _mockPlaces.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final place = _mockPlaces[index];
              return _PlaceListItem(
                place: place,
                tagLabel: _getTagLabel(place),
                tagColor: Color(
                  int.parse(_getTagColor(place.type).replaceFirst('#', '0xFF')),
                ),
                onTap: () => onPlaceTap(place),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlaceListItem extends StatelessWidget {
  const _PlaceListItem({
    required this.place,
    required this.tagLabel,
    required this.tagColor,
    required this.onTap,
  });

  final Place place;
  final String tagLabel;
  final Color tagColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: place.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.shimmerBase,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.shimmerBase,
                  child: const Icon(LucideIcons.image),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.description?.split('.').first ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tagLabel,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: tagColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\u{2B50} ${place.rating}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// Itineraries Tab
class _ItinerariesTab extends StatelessWidget {
  const _ItinerariesTab({
    required this.cityName,
    required this.onItineraryTap,
  });

  final String cityName;
  final ValueChanged<String> onItineraryTap;

  // Itineraries data - populated from API
  static const List<_ItineraryPreviewData> _mockItineraries = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _mockItineraries.length,
      itemBuilder: (context, index) {
        final itinerary = _mockItineraries[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < _mockItineraries.length - 1 ? AppSpacing.md : 0,
          ),
          child: _ItineraryPreviewCard(
            itinerary: itinerary,
            onTap: () => onItineraryTap(itinerary.id),
          ),
        );
      },
    );
  }
}

class _ItineraryPreviewCard extends StatelessWidget {
  const _ItineraryPreviewCard({
    required this.itinerary,
    required this.onTap,
  });

  final _ItineraryPreviewData itinerary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itinerary.title,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${itinerary.days} days',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  ' \u00b7 ',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  '${itinerary.placeCount} places',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  ' \u00b7 ',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  itinerary.city,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              itinerary.description,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                height: 1.5,
                color: AppColors.secondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  LucideIcons.arrowRight,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  'View itinerary',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Data classes
class _ItineraryPreviewData {
  const _ItineraryPreviewData({
    required this.id,
    required this.title,
    required this.days,
    required this.placeCount,
    required this.city,
    required this.description,
    required this.dayOverviews,
  });

  final String id;
  final String title;
  final int days;
  final int placeCount;
  final String city;
  final String description;
  final List<_DayOverview> dayOverviews;
}

class _DayOverview {
  const _DayOverview({
    required this.day,
    required this.title,
    required this.description,
  });

  final int day;
  final String title;
  final String description;
}
