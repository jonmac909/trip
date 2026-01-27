import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/domain/models/activity.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Itinerary builder screen with day-by-day view
class ItineraryBuilderScreen extends StatefulWidget {
  const ItineraryBuilderScreen({
    required this.destination,
    required this.country,
    required this.startDate,
    required this.endDate,
    required this.travelers,
    super.key,
    this.routeIndex,
  });

  final String destination;
  final String country;
  final DateTime startDate;
  final DateTime endDate;
  final int travelers;
  final int? routeIndex;

  @override
  State<ItineraryBuilderScreen> createState() => _ItineraryBuilderScreenState();
}

class _ItineraryBuilderScreenState extends State<ItineraryBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<_DayItinerary> _days;
  int _selectedDayIndex = 0;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _initializeDays();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _initializeDays() {
    final totalDays = _endDate.difference(_startDate).inDays + 1;
    _days = List.generate(totalDays, (index) {
      return _DayItinerary(
        dayNumber: index + 1,
        date: _startDate.add(Duration(days: index)),
        activities: widget.routeIndex != null && widget.routeIndex != -1
            ? _getDemoActivities(index)
            : [],
      );
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final earliest = _startDate.isBefore(DateTime(now.year, 1, 1))
        ? DateTime(_startDate.year, 1, 1)
        : DateTime(now.year, 1, 1);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: earliest,
      lastDate: now.add(const Duration(days: 730)),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _initializeDays();
      });
    }
  }

  List<_ScheduledActivity> _getDemoActivities(int dayIndex) {
    // Demo activities for pre-built routes
    final demoActivities = [
      [
        const _ScheduledActivity(
          id: '1',
          name: 'Morning Coffee & Breakfast',
          category: ActivityCategory.cafe,
          startTime: '08:00',
          endTime: '09:00',
          location: 'Local Cafe',
        ),
        const _ScheduledActivity(
          id: '2',
          name: 'City Walking Tour',
          category: ActivityCategory.tour,
          startTime: '09:30',
          endTime: '12:30',
          location: 'City Center',
        ),
        const _ScheduledActivity(
          id: '3',
          name: 'Lunch at Local Restaurant',
          category: ActivityCategory.restaurant,
          startTime: '13:00',
          endTime: '14:30',
          location: 'Downtown',
        ),
        const _ScheduledActivity(
          id: '4',
          name: 'Museum Visit',
          category: ActivityCategory.museum,
          startTime: '15:00',
          endTime: '17:30',
          location: 'National Museum',
        ),
        const _ScheduledActivity(
          id: '5',
          name: 'Dinner & Evening Stroll',
          category: ActivityCategory.restaurant,
          startTime: '19:00',
          endTime: '21:00',
          location: 'Waterfront District',
        ),
      ],
      [
        const _ScheduledActivity(
          id: '6',
          name: 'Sunrise Viewpoint',
          category: ActivityCategory.landmark,
          startTime: '06:00',
          endTime: '07:30',
          location: 'Observation Deck',
        ),
        const _ScheduledActivity(
          id: '7',
          name: 'Traditional Market Tour',
          category: ActivityCategory.shopping,
          startTime: '08:30',
          endTime: '11:00',
          location: 'Local Market',
        ),
        const _ScheduledActivity(
          id: '8',
          name: 'Cooking Class',
          category: ActivityCategory.entertainment,
          startTime: '11:30',
          endTime: '14:30',
          location: 'Cooking School',
        ),
        const _ScheduledActivity(
          id: '9',
          name: 'Temple Visit',
          category: ActivityCategory.temple,
          startTime: '15:30',
          endTime: '17:30',
          location: 'Historic Temple',
        ),
        const _ScheduledActivity(
          id: '10',
          name: 'Night Market Exploration',
          category: ActivityCategory.nightlife,
          startTime: '19:00',
          endTime: '22:00',
          location: 'Night Market',
        ),
      ],
    ];

    return demoActivities[dayIndex % demoActivities.length];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destination),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveTrip,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Itinerary'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(
            destination: widget.destination,
            country: widget.country,
            startDate: _startDate,
            endDate: _endDate,
            travelers: widget.travelers,
            days: _days,
            onPickDates: _pickDateRange,
          ),
          _ItineraryTab(
            days: _days,
            selectedDayIndex: _selectedDayIndex,
            onDaySelected: (index) {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            onAddActivity: _addActivity,
            onActivityTap: _editActivity,
            onActivityReorder: _reorderActivity,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateItinerary,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.auto_awesome, color: AppColors.textOnPrimary),
        label: const Text(
          'Generate',
          style: TextStyle(color: AppColors.textOnPrimary),
        ),
      ),
    );
  }

  void _saveTrip() {
    // TODO: Save trip to Supabase
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trip saved!')));
    context.go(AppRoutes.home);
  }

  void _addActivity(int dayIndex) {
    // TODO: Open activity search/add modal
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Add activity coming soon!')));
  }

  void _editActivity(_ScheduledActivity activity) {
    // TODO: Open activity edit modal
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit ${activity.name}')));
  }

  void _reorderActivity(int dayIndex, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final activity = _days[dayIndex].activities.removeAt(oldIndex);
      _days[dayIndex].activities.insert(newIndex, activity);
    });
  }

  void _generateItinerary() {
    // TODO: Call AI to generate itinerary
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI itinerary generation coming soon!')),
    );
  }
}

/// Day itinerary data model
class _DayItinerary {
  _DayItinerary({
    required this.dayNumber,
    required this.date,
    required this.activities,
  });

  final int dayNumber;
  final DateTime date;
  final List<_ScheduledActivity> activities;
}

/// Scheduled activity data model
class _ScheduledActivity {
  const _ScheduledActivity({
    required this.id,
    required this.name,
    required this.category,
    this.startTime,
    this.endTime,
    this.location,
    this.notes,
    this.isCompleted = false,
  });

  final String id;
  final String name;
  final ActivityCategory category;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? notes;
  final bool isCompleted;
}

/// Overview tab showing trip summary
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.destination,
    required this.country,
    required this.startDate,
    required this.endDate,
    required this.travelers,
    required this.days,
    required this.onPickDates,
  });

  final String destination;
  final String country;
  final DateTime startDate;
  final DateTime endDate;
  final int travelers;
  final List<_DayItinerary> days;
  final VoidCallback onPickDates;

  @override
  Widget build(BuildContext context) {
    final totalActivities = days.fold<int>(
      0,
      (sum, day) => sum + day.activities.length,
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Destination header
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.landscape,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      country,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Trip stats
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.calendar_today,
                value: '${days.length}',
                label: 'Days',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                value: '$travelers',
                label: 'Travelers',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.place,
                value: '$totalActivities',
                label: 'Activities',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Date range (tappable)
        GestureDetector(
          onTap: onPickDates,
          child: _InfoRow(
            icon: Icons.date_range,
            title: 'Dates',
            value: _formatDateRange(),
          ),
        ),
        const Divider(height: AppSpacing.xl),

        // Quick day overview
        Text(
          'Daily Overview',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.md),
        ...days.map((day) => _DayOverviewCard(day: day)),
      ],
    );
  }

  String _formatDateRange() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[startDate.month - 1]} ${startDate.day} - ${months[endDate.month - 1]} ${endDate.day}, ${endDate.year}';
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Info row widget
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

/// Day overview card
class _DayOverviewCard extends StatelessWidget {
  const _DayOverviewCard({required this.day});

  final _DayItinerary day;

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[day.date.weekday - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekday,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                ),
                Text(
                  '${day.date.day}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${day.dayNumber}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  day.activities.isEmpty
                      ? 'No activities planned'
                      : '${day.activities.length} activities',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

/// Itinerary tab with day-by-day activities
class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab({
    required this.days,
    required this.selectedDayIndex,
    required this.onDaySelected,
    required this.onAddActivity,
    required this.onActivityTap,
    required this.onActivityReorder,
  });

  final List<_DayItinerary> days;
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelected;
  final void Function(int dayIndex) onAddActivity;
  final void Function(_ScheduledActivity activity) onActivityTap;
  final void Function(int dayIndex, int oldIndex, int newIndex)
  onActivityReorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day selector
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.md,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = index == selectedDayIndex;
              final weekdays = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ];
              final weekday = weekdays[day.date.weekday - 1];

              return GestureDetector(
                onTap: () => onDaySelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? AppColors.textOnPrimary.withValues(alpha: 0.8)
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${day.date.day}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.textOnPrimary
                                  : AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Day header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day ${selectedDayIndex + 1}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: () => onAddActivity(selectedDayIndex),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add'),
              ),
            ],
          ),
        ),

        // Activities list
        Expanded(
          child: days[selectedDayIndex].activities.isEmpty
              ? _EmptyDayPlaceholder(
                  onAddActivity: () => onAddActivity(selectedDayIndex),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: days[selectedDayIndex].activities.length,
                  onReorder: (oldIndex, newIndex) {
                    onActivityReorder(selectedDayIndex, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final activity = days[selectedDayIndex].activities[index];
                    return _ActivityCard(
                      key: ValueKey(activity.id),
                      activity: activity,
                      onTap: () => onActivityTap(activity),
                      isFirst: index == 0,
                      isLast:
                          index == days[selectedDayIndex].activities.length - 1,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Empty day placeholder
class _EmptyDayPlaceholder extends StatelessWidget {
  const _EmptyDayPlaceholder({required this.onAddActivity});

  final VoidCallback onAddActivity;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_note_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No activities yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add activities or generate an itinerary',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onAddActivity,
              icon: const Icon(Icons.add),
              label: const Text('Add Activity'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity card widget
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  final _ScheduledActivity activity;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activity.startTime ?? '--:--',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (activity.endTime != null)
                  Text(
                    activity.endTime!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 80, color: AppColors.border),
            ],
          ),
          const SizedBox(width: AppSpacing.md),

          // Activity content
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CategoryIcon(category: activity.category),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            activity.name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(
                          Icons.drag_handle,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ],
                    ),
                    if (activity.location != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            activity.location!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category icon widget
class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});

  final ActivityCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        _getIconForCategory(category),
        size: 16,
        color: AppColors.primary,
      ),
    );
  }

  IconData _getIconForCategory(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.restaurant:
        return Icons.restaurant;
      case ActivityCategory.cafe:
        return Icons.local_cafe;
      case ActivityCategory.bar:
        return Icons.local_bar;
      case ActivityCategory.museum:
        return Icons.museum;
      case ActivityCategory.temple:
        return Icons.temple_buddhist;
      case ActivityCategory.landmark:
        return Icons.location_city;
      case ActivityCategory.shopping:
        return Icons.shopping_bag;
      case ActivityCategory.park:
        return Icons.park;
      case ActivityCategory.beach:
        return Icons.beach_access;
      case ActivityCategory.tour:
        return Icons.tour;
      case ActivityCategory.nightlife:
        return Icons.nightlife;
      case ActivityCategory.entertainment:
        return Icons.movie;
      case ActivityCategory.spa:
        return Icons.spa;
      case ActivityCategory.sport:
        return Icons.sports;
      case ActivityCategory.transport:
        return Icons.directions_transit;
      case ActivityCategory.accommodation:
        return Icons.hotel;
      default:
        return Icons.place;
    }
  }
}
