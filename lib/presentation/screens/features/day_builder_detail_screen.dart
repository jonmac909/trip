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
  });

  final String cityName;
  final int dayNumber;
  final int totalDays;

  @override
  State<DayBuilderDetailScreen> createState() => _DayBuilderDetailScreenState();
}

class _DayBuilderDetailScreenState extends State<DayBuilderDetailScreen> {
  int _selectedDayIndex = 0;
  int _selectedTabIndex = 1; // Itinerary tab selected by default
  int _bottomNavIndex = 0;

  final List<_Activity> _activities = [
    _Activity(
      id: '1',
      name: 'British Museum',
      time: '9:00 AM',
      location: 'Bloomsbury',
      note: 'Free entry',
      duration: '~3 hrs',
      imageUrl:
          'https://images.unsplash.com/photo-1672244438282-aab5aae2bc2a?w=400&q=80',
      timeOfDay: TimeOfDay.morning,
    ),
    _Activity(
      id: '2',
      name: 'Covent Garden',
      time: '12:30 PM',
      location: 'West End',
      note: 'Lunch & explore',
      duration: '~2 hrs',
      imageUrl:
          'https://images.unsplash.com/photo-1543484623-542877a80db5?w=400&q=80',
      timeOfDay: TimeOfDay.midday,
    ),
    _Activity(
      id: '3',
      name: 'Tower of London',
      time: '3:00 PM',
      location: 'Tower Hill',
      note: 'Crown Jewels',
      duration: '~2.5 hrs',
      imageUrl:
          'https://images.unsplash.com/photo-1712865640443-c74e7528b343?w=400&q=80',
      timeOfDay: TimeOfDay.afternoon,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = widget.dayNumber - 1;
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
          imageUrl:
              'https://images.unsplash.com/photo-1556821862-dc1f261b8416?w=800&q=80',
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
          Expanded(child: _buildActivitiesList()),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.pencil,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Edit',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.totalDays, (index) {
          final isSelected = index == _selectedDayIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDayIndex = index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  'Day ${index + 1}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
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

  Widget _buildActivitiesList() {
    // Group activities by time of day
    final morningActivities =
        _activities.where((a) => a.timeOfDay == TimeOfDay.morning).toList();
    final middayActivities =
        _activities.where((a) => a.timeOfDay == TimeOfDay.midday).toList();
    final afternoonActivities =
        _activities.where((a) => a.timeOfDay == TimeOfDay.afternoon).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (morningActivities.isNotEmpty) ...[
          _buildTimeLabel('Morning'),
          ...morningActivities.map((a) => _ActivityCard(activity: a)),
          if (morningActivities.isNotEmpty && middayActivities.isNotEmpty)
            _buildTravelConnector(icon: LucideIcons.footprints, text: '15 min walk'),
        ],
        if (middayActivities.isNotEmpty) ...[
          _buildTimeLabel('Midday'),
          ...middayActivities.map((a) => _ActivityCard(activity: a)),
        ],
        if (afternoonActivities.isNotEmpty) ...[
          _buildTimeLabel('Afternoon'),
          ...afternoonActivities.map((a) => _ActivityCard(activity: a)),
        ],
      ],
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
  const _ActivityCard({required this.activity});

  final _Activity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
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
                    '${activity.time} \u00b7 ${activity.location} \u00b7 ${activity.note}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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

enum TimeOfDay {
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
    required this.duration,
    required this.imageUrl,
    required this.timeOfDay,
  });

  final String id;
  final String name;
  final String time;
  final String location;
  final String note;
  final String duration;
  final String imageUrl;
  final TimeOfDay timeOfDay;
}
