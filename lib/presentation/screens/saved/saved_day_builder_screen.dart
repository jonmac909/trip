import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Day builder screen for saved itineraries - shows overview of all days
class SavedDayBuilderScreen extends StatefulWidget {
  const SavedDayBuilderScreen({
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
  State<SavedDayBuilderScreen> createState() => _SavedDayBuilderScreenState();
}

class _SavedDayBuilderScreenState extends State<SavedDayBuilderScreen> {
  int _selectedTab = 0; // 0 = Overview, 1 = Itinerary

  late List<_DayData> _dayData;
  DateTime? _startDate;
  DateTime? _endDate;

  static const _cityCoordinates = <String, LatLng>{
    'Tokyo': LatLng(35.6762, 139.6503),
    'Kyoto': LatLng(35.0116, 135.7681),
    'Osaka': LatLng(34.6937, 135.5023),
    'Hanoi': LatLng(21.0285, 105.8542),
    'Nara': LatLng(34.6851, 135.8048),
    'Paris': LatLng(48.8566, 2.3522),
    'Rome': LatLng(41.9028, 12.4964),
    'London': LatLng(51.5074, -0.1278),
    'Barcelona': LatLng(41.3874, 2.1686),
    'Bangkok': LatLng(13.7563, 100.5018),
    'Seoul': LatLng(37.5665, 126.978),
    'Singapore': LatLng(1.3521, 103.8198),
    'New York': LatLng(40.7128, -74.006),
    'Dubai': LatLng(25.2048, 55.2708),
    'Istanbul': LatLng(41.0082, 28.9784),
    'Lisbon': LatLng(38.7223, -9.1393),
    'Amsterdam': LatLng(52.3676, 4.9041),
    'Prague': LatLng(50.0755, 14.4378),
    'Vienna': LatLng(48.2082, 16.3738),
    'Berlin': LatLng(52.52, 13.405),
    'Bali': LatLng(-8.3405, 115.092),
    'Sydney': LatLng(-33.8688, 151.2093),
    'Ho Chi Minh City': LatLng(10.8231, 106.6297),
    'Taipei': LatLng(25.033, 121.5654),
    'Hong Kong': LatLng(22.3193, 114.1694),
  };

  LatLng get _cityCenter =>
      _cityCoordinates[widget.cityName] ??
      const LatLng(35.6762, 139.6503);

  String get _dateRangeText {
    if (_startDate == null || _endDate == null) return 'Add dates';
    final start = DateFormat('MMM d').format(_startDate!);
    final end = DateFormat('d').format(_endDate!);
    return '$start - $end';
  }

  @override
  void initState() {
    super.initState();
    _initializeDayData();
  }

  void _initializeDayData() {
    final totalDays = widget.days ?? 2;
    final places = widget.places ?? [];

    // Group places by day
    final placesByDay = <int, List<String>>{};
    for (final place in places) {
      final day = place['day'] as int? ?? 1;
      placesByDay.putIfAbsent(day, () => []);
      placesByDay[day]!.add(place['name'] as String? ?? 'Unknown');
    }

    // Create day data
    _dayData = List.generate(totalDays, (index) {
      final dayNum = index + 1;
      return _DayData(
        dayNumber: dayNum,
        label: 'Custom day',
        activities: placesByDay[dayNum] ?? [],
      );
    });

    // If no places provided, use mock data
    if (places.isEmpty) {
      _dayData = const [
        _DayData(
          dayNumber: 1,
          label: 'Custom day',
          activities: ['Ichiran Ramen', 'Senso-ji Temple'],
        ),
        _DayData(
          dayNumber: 2,
          label: 'Custom day',
          activities: ['Shibuya Crossing', 'Tsukiji Outer Market', 'Meiji Shrine'],
        ),
      ];
    }
  }

  int get _plannedDays => _dayData.where((d) => d.activities.isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Map section at top
          _buildMapSection(),

          // Content section
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  // Header with title
                  _buildHeader(),

                  // Tabs
                  _buildTabs(),

                  // Tab content
                  Expanded(
                    child: _selectedTab == 0
                        ? _buildOverviewTab()
                        : _buildItineraryTab(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            context.go(AppRoutes.home);
          } else if (index == 3) {
            context.go(AppRoutes.profile);
          }
        },
      ),
    );
  }

  Widget _buildMapSection() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // Apple Maps
          AppleMap(
            key: const ValueKey('saved_day_builder_map'),
            initialCameraPosition: CameraPosition(
              target: _cityCenter,
              zoom: 13,
            ),
            annotations: {
              Annotation(
                annotationId: AnnotationId('city_pin'),
                position: _cityCenter,
                infoWindow: InfoWindow(
                  title: widget.cityName ?? 'Location',
                ),
              ),
            },
            myLocationEnabled: false,
            compassEnabled: false,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            pitchGesturesEnabled: true,
          ),

          // Collapse bar handle at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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

  Widget _buildHeader() {
    final displayName = widget.name ?? 'Tokyo Weekend';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back button and title
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      LucideIcons.arrowLeft,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  displayName,
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  LucideIcons.chevronDown,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Date badge
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _dateRangeText,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        // Overview tab
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = 0;
              });
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Overview',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight:
                          _selectedTab == 0 ? FontWeight.w600 : FontWeight.w500,
                      color: _selectedTab == 0
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                if (_selectedTab == 0)
                  Container(
                    height: 2,
                    color: AppColors.primary,
                  )
                else
                  const SizedBox(height: 2),
              ],
            ),
          ),
        ),

        // Itinerary tab
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = 1;
              });
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Itinerary',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight:
                          _selectedTab == 1 ? FontWeight.w600 : FontWeight.w500,
                      color: _selectedTab == 1
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                if (_selectedTab == 1)
                  Container(
                    height: 2,
                    color: AppColors.primary,
                  )
                else
                  const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Days planned subtitle
        Text(
          '$_plannedDays of ${_dayData.length} days planned',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Day cards
        ..._dayData.map((day) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildDayCard(day),
            )),
      ],
    );
  }

  Widget _buildDayCard(_DayData day) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Day info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${day.dayNumber}',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    day.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Edit button
              GestureDetector(
                onTap: () => _handleEditDay(day),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Activities list
          if (day.activities.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                children: day.activities
                    .map((activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(
                                '\u00b7',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                activity,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItineraryTab() {
    // Placeholder for itinerary tab content
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.calendar,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Itinerary View',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detailed timeline coming soon',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialStart = _startDate ?? now;
    final initialEnd = _endDate ?? now.add(Duration(days: _dayData.length - 1));
    final earliest = initialStart.isBefore(DateTime(now.year, 1, 1))
        ? DateTime(initialStart.year, 1, 1)
        : DateTime(now.year, 1, 1);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: earliest,
      lastDate: now.add(const Duration(days: 730)),
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _handleEditDay(_DayData day) {
    // Navigate to day detail editor
    context.push(AppRoutes.dayBuilderDetail, extra: {
      'cityName': widget.cityName ?? 'Tokyo',
      'dayNumber': day.dayNumber,
      'totalDays': _dayData.length,
    });
  }
}

class _DayData {
  const _DayData({
    required this.dayNumber,
    required this.label,
    required this.activities,
  });

  final int dayNumber;
  final String label;
  final List<String> activities;
}
