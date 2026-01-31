import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';

/// Day builder detail screen showing single day expanded view
class DayBuilderDetailScreen extends StatefulWidget {
  const DayBuilderDetailScreen({
    super.key,
    required this.cityName,
    this.dayNumber = 1,
    this.totalDays = 4,
    this.allDaysActivities = const [],
  });

  final String cityName;
  final int dayNumber;
  final int totalDays;
  final List<List<Map<String, dynamic>>> allDaysActivities;

  @override
  State<DayBuilderDetailScreen> createState() => _DayBuilderDetailScreenState();
}

class _DayBuilderDetailScreenState extends State<DayBuilderDetailScreen> {
  int _selectedDayIndex = 0;
  int _selectedTabIndex = 1; // Itinerary tab selected by default
  int _bottomNavIndex = 0;
  bool _isEditMode = false;

  // Activities per day - parsed from navigation params
  late List<List<_Activity>> _allDaysActivities;

  // Category-based images for activities
  static const _categoryImages = {
    'restaurant': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&q=80',
    'cafe': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=200&q=80',
    'bar': 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=200&q=80',
    'museum': 'https://images.unsplash.com/photo-1554907984-15263bfd63bd?w=200&q=80',
    'temple': 'https://images.unsplash.com/photo-1528181304800-259b08848526?w=200&q=80',
    'landmark': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=200&q=80',
    'shopping': 'https://images.unsplash.com/photo-1481437156560-3205f6a55735?w=200&q=80',
    'park': 'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?w=200&q=80',
    'beach': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200&q=80',
    'tour': 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=200&q=80',
    'nightlife': 'https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?w=200&q=80',
    'entertainment': 'https://images.unsplash.com/photo-1603190287605-e6ade32fa852?w=200&q=80',
    'spa': 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=200&q=80',
    'sport': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=200&q=80',
  };

  // City-based header images
  static const _cityImages = {
    'bangkok': 'https://images.unsplash.com/photo-1508009603885-50cf7c579365?w=800&q=80',
    'chiang mai': 'https://images.unsplash.com/photo-1512553594657-f48d01b99f76?w=800&q=80',
    'phuket': 'https://images.unsplash.com/photo-1589394815804-964ed0be2eb5?w=800&q=80',
    'tokyo': 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800&q=80',
    'kyoto': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80',
    'osaka': 'https://images.unsplash.com/photo-1590559899731-a382839e5549?w=800&q=80',
    'paris': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&q=80',
    'london': 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&q=80',
    'new york': 'https://images.unsplash.com/photo-1485738422979-f5c462d49f74?w=800&q=80',
    'rome': 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800&q=80',
    'barcelona': 'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800&q=80',
    'bali': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800&q=80',
    'seoul': 'https://images.unsplash.com/photo-1538485399081-7191377e8241?w=800&q=80',
    'sydney': 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800&q=80',
    'dubai': 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80',
    'singapore': 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=800&q=80',
    'hong kong': 'https://images.unsplash.com/photo-1536599018102-9f803c979b10?w=800&q=80',
    'vietnam': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800&q=80',
    'hanoi': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800&q=80',
    'ho chi minh': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800&q=80',
  };

  String _getCityImage() {
    final cityLower = widget.cityName.toLowerCase();
    return _cityImages[cityLower] ??
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80';
  }

  String _getCategoryImage(String? category) {
    if (category == null) return _categoryImages['landmark']!;
    return _categoryImages[category.toLowerCase()] ??
        _categoryImages['landmark']!;
  }

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = widget.dayNumber - 1;
    _parseAllDaysActivities();
  }

  void _parseAllDaysActivities() {
    // Parse activities for all days
    _allDaysActivities = [];

    // Ensure we have entries for all days
    for (var dayIndex = 0; dayIndex < widget.totalDays; dayIndex++) {
      if (dayIndex < widget.allDaysActivities.length) {
        final dayActivities = widget.allDaysActivities[dayIndex];
        _allDaysActivities.add(_parseDayActivities(dayActivities));
      } else {
        _allDaysActivities.add([]); // Empty day
      }
    }
  }

  /// Parse hour from time string (handles both "3:00 PM" and "15:00" formats)
  int _parseHour(String time) {
    if (time.isEmpty) return 9;

    final upperTime = time.toUpperCase();
    final isPM = upperTime.contains('PM');
    final isAM = upperTime.contains('AM');

    // Extract hour number
    final hourStr = time.split(':').first.replaceAll(RegExp(r'[^0-9]'), '');
    var hour = int.tryParse(hourStr) ?? 9;

    // Convert to 24-hour format
    if (isPM && hour != 12) {
      hour += 12; // 3 PM -> 15
    } else if (isAM && hour == 12) {
      hour = 0; // 12 AM -> 0
    }

    return hour;
  }

  List<_Activity> _parseDayActivities(List<Map<String, dynamic>> activities) {
    return activities.asMap().entries.map((entry) {
      final index = entry.key;
      final a = entry.value;
      final time = a['time'] as String? ?? '';
      final category = a['category'] as String?;

      // Determine time of day based on time string
      _TimeOfDay timeOfDay = _TimeOfDay.morning;
      if (time.isNotEmpty) {
        final hour = _parseHour(time);
        if (hour >= 17) {
          timeOfDay = _TimeOfDay.evening;
        } else if (hour >= 14) {
          timeOfDay = _TimeOfDay.afternoon;
        } else if (hour >= 12) {
          timeOfDay = _TimeOfDay.midday;
        }
      } else {
        // Distribute activities evenly if no time
        if (index >= 3) {
          timeOfDay = _TimeOfDay.afternoon;
        } else if (index >= 2) {
          timeOfDay = _TimeOfDay.midday;
        }
      }

      return _Activity(
        id: 'activity-$index',
        name: a['name'] as String? ?? 'Activity',
        time: time.isNotEmpty ? time : '${9 + index * 2}:00',
        location: a['location'] as String? ?? '',
        note: a['note'] as String? ?? '',
        category: category ?? 'landmark',
        duration: '1-2h',
        imageUrl: _getCategoryImage(category),
        timeOfDay: timeOfDay,
      );
    }).toList();
  }

  List<_Activity> get _currentDayActivities {
    if (_selectedDayIndex >= 0 && _selectedDayIndex < _allDaysActivities.length) {
      return _allDaysActivities[_selectedDayIndex];
    }
    return [];
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });

    if (_isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Edit mode enabled. Tap activities to modify.',
            style: GoogleFonts.dmSans(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          action: SnackBarAction(
            label: 'Done',
            textColor: AppColors.accent,
            onPressed: () => setState(() => _isEditMode = false),
          ),
        ),
      );
    }
  }

  void _deleteActivity(int activityIndex) {
    setState(() {
      _allDaysActivities[_selectedDayIndex].removeAt(activityIndex);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Activity removed', style: GoogleFonts.dmSans()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildMapSection(context),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: _getCityImage(),
          height: 240,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 240,
            color: AppColors.shimmerBase,
          ),
          errorWidget: (context, url, error) => Container(
            height: 240,
            color: AppColors.shimmerBase,
            child: const Icon(
              LucideIcons.map,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        // Day indicator overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Day ${_selectedDayIndex + 1} of ${widget.totalDays}',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Collapse handle bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusXl),
              ),
            ),
            alignment: Alignment.center,
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
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(),
          _buildDayTabs(),
          _buildMainTabs(),
          Expanded(child: _buildTabContent()),
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
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.cityName,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                LucideIcons.chevronDown,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          _buildEditBadge(),
        ],
      ),
    );
  }

  Widget _buildEditBadge() {
    return GestureDetector(
      onTap: _toggleEditMode,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: _isEditMode ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: _isEditMode ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isEditMode ? LucideIcons.check : LucideIcons.pencil,
              size: 12,
              color: _isEditMode ? AppColors.textOnPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _isEditMode ? 'Done' : 'Edit',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _isEditMode ? AppColors.textOnPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.totalDays, (index) {
            final isSelected = index == _selectedDayIndex;
            final hasActivities = index < _allDaysActivities.length &&
                _allDaysActivities[index].isNotEmpty;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Day ${index + 1}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (hasActivities) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.accent.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMainTabs() {
    final tabs = ['Overview', 'Itinerary', 'Bookings'];

    return Row(
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        final isSelected = index == _selectedTabIndex;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    tab,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildItineraryTab();
      case 2:
        return _buildBookingsTab();
      default:
        return _buildItineraryTab();
    }
  }

  Widget _buildOverviewTab() {
    final activities = _currentDayActivities;
    final totalActivities = activities.length;

    // Count by category
    final categoryCount = <String, int>{};
    for (final activity in activities) {
      categoryCount[activity.category] =
          (categoryCount[activity.category] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Day summary card
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day ${_selectedDayIndex + 1} Summary',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _buildStatItem(
                    icon: LucideIcons.mapPin,
                    value: '$totalActivities',
                    label: 'Activities',
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _buildStatItem(
                    icon: LucideIcons.clock,
                    value: '${totalActivities * 2}h',
                    label: 'Est. Time',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Categories breakdown
        if (categoryCount.isNotEmpty) ...[
          Text(
            'Activity Types',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categoryCount.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entry.key.capitalize()} (${entry.value})',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Quick activity list
        if (activities.isNotEmpty) ...[
          Text(
            'Activities',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...activities.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    a.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  a.time,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          )),
        ] else ...[
          _buildEmptyState(),
        ],
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItineraryTab() {
    final activities = _currentDayActivities;

    if (activities.isEmpty) {
      return _buildEmptyState();
    }

    // Group activities by time of day
    final morningActivities =
        activities.where((a) => a.timeOfDay == _TimeOfDay.morning).toList();
    final middayActivities =
        activities.where((a) => a.timeOfDay == _TimeOfDay.midday).toList();
    final afternoonActivities =
        activities.where((a) => a.timeOfDay == _TimeOfDay.afternoon).toList();
    final eveningActivities =
        activities.where((a) => a.timeOfDay == _TimeOfDay.evening).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (morningActivities.isNotEmpty) ...[
          _buildTimeLabel('Morning'),
          ...morningActivities.asMap().entries.map((e) =>
              _ActivityCard(
                activity: e.value,
                isEditMode: _isEditMode,
                onDelete: () => _deleteActivity(
                  activities.indexOf(e.value),
                ),
              )),
          if (middayActivities.isNotEmpty)
            _buildTravelConnector(icon: LucideIcons.footprints, text: '15 min walk'),
        ],
        if (middayActivities.isNotEmpty) ...[
          _buildTimeLabel('Midday'),
          ...middayActivities.map((a) => _ActivityCard(
            activity: a,
            isEditMode: _isEditMode,
            onDelete: () => _deleteActivity(activities.indexOf(a)),
          )),
          if (afternoonActivities.isNotEmpty)
            _buildTravelConnector(icon: LucideIcons.footprints, text: '10 min walk'),
        ],
        if (afternoonActivities.isNotEmpty) ...[
          _buildTimeLabel('Afternoon'),
          ...afternoonActivities.map((a) => _ActivityCard(
            activity: a,
            isEditMode: _isEditMode,
            onDelete: () => _deleteActivity(activities.indexOf(a)),
          )),
          if (eveningActivities.isNotEmpty)
            _buildTravelConnector(icon: LucideIcons.footprints, text: '15 min walk'),
        ],
        if (eveningActivities.isNotEmpty) ...[
          _buildTimeLabel('Evening'),
          ...eveningActivities.map((a) => _ActivityCard(
            activity: a,
            isEditMode: _isEditMode,
            onDelete: () => _deleteActivity(activities.indexOf(a)),
          )),
        ],
      ],
    );
  }

  Widget _buildBookingsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.ticket,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No bookings yet',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Book tours, tickets, and restaurants\nfor this day',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking feature coming soon!',
                    style: GoogleFonts.dmSans(),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(
              'Add Booking',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.calendar,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No activities planned',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Generate activities with AI or add manually',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTravelConnector({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 1,
            height: 16,
            color: AppColors.border,
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    this.isEditMode = false,
    this.onDelete,
  });

  final _Activity activity;
  final bool isEditMode;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isEditMode ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: CachedNetworkImage(
                imageUrl: activity.imageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 44,
                  height: 44,
                  color: AppColors.shimmerBase,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 44,
                  height: 44,
                  color: AppColors.shimmerBase,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${activity.time} · ${activity.location.isNotEmpty ? activity.location : activity.category.capitalize()}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isEditMode)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: Colors.red,
                  ),
                ),
              )
            else
              Text(
                activity.duration,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _TimeOfDay {
  morning,
  midday,
  afternoon,
  evening,
}

class _Activity {
  const _Activity({
    required this.id,
    required this.name,
    required this.time,
    required this.location,
    required this.note,
    required this.category,
    required this.duration,
    required this.imageUrl,
    required this.timeOfDay,
  });

  final String id;
  final String name;
  final String time;
  final String location;
  final String note;
  final String category;
  final String duration;
  final String imageUrl;
  final _TimeOfDay timeOfDay;
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
