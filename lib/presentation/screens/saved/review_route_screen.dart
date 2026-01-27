import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Screen for reviewing and reordering the route before creating itinerary
class ReviewRouteScreen extends StatefulWidget {
  const ReviewRouteScreen({
    super.key,
    this.name,
    this.cityName,
    this.country,
    this.days,
    this.places,
  });

  final String? name;
  final String? cityName;
  final String? country;
  final int? days;
  final List<Map<String, dynamic>>? places;

  @override
  State<ReviewRouteScreen> createState() => _ReviewRouteScreenState();
}

class _ReviewRouteScreenState extends State<ReviewRouteScreen> {
  late List<_RoutePlace> _places;
  late int _totalDays;

  @override
  void initState() {
    super.initState();
    _totalDays = widget.days ?? 2;

    // Initialize places from widget or mock data
    _places = widget.places?.asMap().entries.map((entry) {
          final data = entry.value;
          return _RoutePlace(
            name: data['name'] as String? ?? 'Place ${entry.key + 1}',
            category: data['category'] as String? ?? 'Attraction',
            area: data['area'] as String? ?? 'Area',
            day: _assignDay(entry.key),
            travelTime: _getMockTravelTime(entry.key),
            travelMode: _getMockTravelMode(entry.key),
          );
        }).toList() ??
        [
          const _RoutePlace(
            name: 'Ichiran Ramen',
            category: 'Restaurant',
            area: 'Shibuya',
            day: 1,
            travelTime: '12 min walk',
            travelMode: TravelMode.walk,
          ),
          const _RoutePlace(
            name: 'Senso-ji Temple',
            category: 'Attraction',
            area: 'Asakusa',
            day: 1,
            travelTime: null,
            travelMode: null,
          ),
          const _RoutePlace(
            name: 'Shibuya Crossing',
            category: 'Attraction',
            area: 'Shibuya',
            day: 2,
            travelTime: '8 min walk',
            travelMode: TravelMode.walk,
          ),
          const _RoutePlace(
            name: 'Tsukiji Outer Market',
            category: 'Food Market',
            area: 'Tsukiji',
            day: 2,
            travelTime: '15 min transit',
            travelMode: TravelMode.transit,
          ),
          const _RoutePlace(
            name: 'Meiji Shrine',
            category: 'Shrine',
            area: 'Harajuku',
            day: 2,
            travelTime: null,
            travelMode: null,
          ),
        ];
  }

  int _assignDay(int index) {
    final placesPerDay = (_places.isEmpty ? 5 : _places.length) / _totalDays;
    return (index / placesPerDay).floor() + 1;
  }

  String _getMockTravelTime(int index) {
    final times = ['12 min walk', '8 min walk', '15 min transit', '20 min walk'];
    return times[index % times.length];
  }

  TravelMode _getMockTravelMode(int index) {
    final modes = [
      TravelMode.walk,
      TravelMode.walk,
      TravelMode.transit,
      TravelMode.walk
    ];
    return modes[index % modes.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: _buildHeader(),
          ),

          // Map placeholder
          _buildMapSection(),

          // Places list
          Expanded(
            child: _buildPlacesList(),
          ),

          // Footer with CTA
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Route',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Drag to reorder \u2022 Check distances',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1568554766943-c077eb3a4a03?w=800',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Map pins (positioned as mock overlay)
          ..._buildMapPins(),
        ],
      ),
    );
  }

  List<Widget> _buildMapPins() {
    final positions = [
      const Offset(80, 60),
      const Offset(140, 120),
      const Offset(200, 80),
      const Offset(280, 140),
      const Offset(320, 60),
    ];

    return _places.asMap().entries.map((entry) {
      final index = entry.key;
      final position = positions[index % positions.length];
      final isHighlighted = index < 2;

      return Positioned(
        left: position.dx,
        top: position.dy,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.accent : AppColors.border,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.background,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color:
                    isHighlighted ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPlacesList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_places.length} places',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Select all action
                },
                child: Text(
                  'Select All',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Places organized by day
          ..._buildDayGroups(),
        ],
      ),
    );
  }

  List<Widget> _buildDayGroups() {
    final widgets = <Widget>[];
    int currentDay = 0;

    for (var i = 0; i < _places.length; i++) {
      final place = _places[i];

      // Add day header if this is a new day
      if (place.day != currentDay) {
        currentDay = place.day;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : 12,
              bottom: 8,
            ),
            child: Text(
              'Day $currentDay',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      }

      // Add place item
      widgets.add(_buildPlaceItem(place, i));

      // Add travel connector if not last item and not last item of day
      if (i < _places.length - 1 && _places[i + 1].day == place.day) {
        widgets.add(_buildTravelConnector(place));
      }
    }

    return widgets;
  }

  Widget _buildPlaceItem(_RoutePlace place, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Number badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Place info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${place.category} \u2022 ${place.area}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Drag handle
          const Icon(
            LucideIcons.gripVertical,
            size: 16,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 8),

          // Remove button
          GestureDetector(
            onTap: () {
              setState(() {
                _places.removeAt(index);
              });
            },
            child: const Icon(
              LucideIcons.x,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelConnector(_RoutePlace place) {
    if (place.travelTime == null) return const SizedBox(height: 8);

    final icon = place.travelMode == TravelMode.transit
        ? LucideIcons.train
        : LucideIcons.footprints;

    final color = place.travelMode == TravelMode.transit
        ? AppColors.borderDark
        : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 6, 0, 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            place.travelTime!,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        40,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: GestureDetector(
        onTap: _handleCreateItinerary,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create Itinerary',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.check,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCreateItinerary() {
    // Navigate to the day builder screen
    context.push(AppRoutes.savedDayBuilder, extra: {
      'name': widget.name ?? 'Tokyo Weekend',
      'cityName': widget.cityName ?? 'Tokyo',
      'country': widget.country ?? 'Japan',
      'days': _totalDays,
      'places': _places.map((p) => {
            'name': p.name,
            'category': p.category,
            'area': p.area,
            'day': p.day,
          }).toList(),
    });
  }
}

enum TravelMode { walk, transit, car, plane }

class _RoutePlace {
  const _RoutePlace({
    required this.name,
    required this.category,
    required this.area,
    required this.day,
    this.travelTime,
    this.travelMode,
  });

  final String name;
  final String category;
  final String area;
  final int day;
  final String? travelTime;
  final TravelMode? travelMode;
}
