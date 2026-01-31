import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/core/services/claude_service.dart';
import 'package:trippified/domain/models/activity.dart';
import 'package:trippified/presentation/navigation/app_router.dart';
import 'package:trippified/presentation/providers/trips_provider.dart';

/// Itinerary builder screen with day-by-day view
class ItineraryBuilderScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ItineraryBuilderScreen> createState() => _ItineraryBuilderScreenState();
}

class _ItineraryBuilderScreenState extends ConsumerState<ItineraryBuilderScreen>
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
        activities: [], // Always start empty - user will generate with AI
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

  String _getFirstCountry() {
    // Extract first country from comma-separated list
    final countries = widget.country.split(',').map((c) => c.trim()).toList();
    return countries.isNotEmpty ? countries.first : widget.country;
  }

  String _getImageForCountry(String country) {
    final images = {
      'United States':
          'https://images.unsplash.com/photo-1485738422979-f5c462d49f74?w=800&q=80',
      'Japan':
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80',
      'Vietnam':
          'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800&q=80',
      'Thailand':
          'https://images.unsplash.com/photo-1528181304800-259b08848526?w=800&q=80',
      'Italy':
          'https://images.unsplash.com/photo-1515859005217-8a1f08870f59?w=800&q=80',
      'France':
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&q=80',
      'Spain':
          'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800&q=80',
      'Greece':
          'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=800&q=80',
      'Indonesia':
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800&q=80',
      'South Korea':
          'https://images.unsplash.com/photo-1538485399081-7191377e8241?w=800&q=80',
      'Australia':
          'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800&q=80',
      'Mexico':
          'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=800&q=80',
      'United Kingdom':
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&q=80',
      'Canada':
          'https://images.unsplash.com/photo-1503614472-8c93d56e92ce?w=800&q=80',
    };
    return images[country] ??
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80';
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.country,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bookmark, color: AppColors.primary),
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
          indicatorWeight: 2,
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
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(
            destination: widget.destination,
            country: widget.country,
            imageUrl: _getImageForCountry(_getFirstCountry()),
            startDate: _startDate,
            endDate: _endDate,
            travelers: widget.travelers,
            days: _days,
            onPickDates: _pickDateRange,
            onGenerate: _generateItinerary,
            onDayTap: (dayIndex) {
              // Navigate to day builder detail screen with ALL days' activities
              final allDaysActivities = _days.map((day) {
                return day.activities.map((a) => {
                  'name': a.name,
                  'time': a.startTime,
                  'location': a.location ?? '',
                  'note': a.notes ?? '',
                  'category': a.category.name,
                }).toList();
              }).toList();

              context.push(AppRoutes.dayBuilderDetail, extra: {
                'cityName': widget.destination.isNotEmpty
                    ? widget.destination.split('→').first.trim()
                    : _getFirstCountry(),
                'dayNumber': dayIndex + 1,
                'totalDays': _days.length,
                'allDaysActivities': allDaysActivities,
              });
            },
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
            onGenerate: _generateItinerary,
          ),
        ],
      ),
    );
  }

  void _saveTrip() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateString = '${months[_startDate.month - 1]} ${_startDate.day} - '
        '${months[_endDate.month - 1]} ${_endDate.day}';
    final daysUntil = _startDate.difference(DateTime.now()).inDays;

    // Parse cities from destination string (e.g., "Tokyo → Kyoto → Osaka")
    final cities = widget.destination
        .split('→')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    // Parse countries - can be comma-separated or single
    final countriesList = widget.country
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    // Use countries joined as title if multiple, otherwise just the country
    final title = countriesList.length > 1
        ? countriesList.join(' & ')
        : countriesList.first;

    final newTrip = SavedTrip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      imageUrl: _getImageForCountry(_getFirstCountry()),
      dates: dateString,
      daysUntil: daysUntil > 0 ? daysUntil : 0,
      cityNames: cities.isNotEmpty ? cities : countriesList,
      countries: countriesList,
      startDate: _startDate,
      endDate: _endDate,
      travelers: widget.travelers,
      status: TripStatus.upcoming,
    );

    ref.read(tripsProvider.notifier).addTrip(newTrip);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Trip saved!',
          style: GoogleFonts.dmSans(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
    context.go(AppRoutes.home);
  }

  void _addActivity(int dayIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Add activity coming soon!',
          style: GoogleFonts.dmSans(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editActivity(_ScheduledActivity activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit ${activity.name}',
          style: GoogleFonts.dmSans(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _reorderActivity(int dayIndex, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final activity = _days[dayIndex].activities.removeAt(oldIndex);
      _days[dayIndex].activities.insert(newIndex, activity);
    });
  }

  bool _isGenerating = false;

  Future<void> _generateItinerary() async {
    if (_isGenerating) return;

    setState(() => _isGenerating = true);

    // Show loading indicator - persistent until we explicitly hide it
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Generating itinerary with AI...',
              style: GoogleFonts.dmSans(),
            ),
          ],
        ),
        duration: const Duration(minutes: 5), // Won't auto-dismiss
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );

    try {
      // Parse all countries (ALWAYS use these as primary destinations)
      final countries = widget.country
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      // ALWAYS use countries as destinations - this ensures multi-country trips work
      final allDestinations = countries.isNotEmpty ? countries : [widget.country];
      final cityName = allDestinations.first;

      print('DEBUG: widget.country = ${widget.country}');
      print('DEBUG: widget.destination = ${widget.destination}');
      print('DEBUG: allDestinations = $allDestinations');

      // Find empty days that need generation
      final emptyDayNumbers = <int>[];
      final filledDayThemes = <int, String>{};

      for (var i = 0; i < _days.length; i++) {
        if (_days[i].activities.isEmpty) {
          emptyDayNumbers.add(i + 1); // 1-indexed
        } else {
          filledDayThemes[i + 1] = 'Already planned';
        }
      }

      if (emptyDayNumbers.isEmpty) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All days already have activities!',
              style: GoogleFonts.dmSans(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isGenerating = false);
        return;
      }

      // Call Claude to generate day plans for ALL destinations
      print('Calling Claude with destinations: $allDestinations, days: ${_days.length}, emptyDays: $emptyDayNumbers');
      final generatedPlans = await ClaudeService.instance.generateDayPlans(
        cityName: cityName,
        destinations: allDestinations,
        totalDays: _days.length,
        emptyDayNumbers: emptyDayNumbers,
        filledDayThemes: filledDayThemes,
      );
      print('Gemini returned ${generatedPlans.length} plans');

      // Build all updated days in memory first
      final updatedDays = List<_DayItinerary>.from(_days);
      for (final plan in generatedPlans) {
        print('Processing plan for day ${plan.dayNumber} with ${plan.activities.length} activities');
        final dayIndex = plan.dayNumber - 1;
        if (dayIndex >= 0 && dayIndex < updatedDays.length) {
          final activities = plan.activities.map((a) {
            return _ScheduledActivity(
              id: 'gen-${DateTime.now().millisecondsSinceEpoch}-${a.name.hashCode}',
              name: a.name,
              category: _categoryFromString(a.category),
              startTime: a.time,
              endTime: null,
              location: a.location,
              notes: a.description,
            );
          }).toList();

          updatedDays[dayIndex] = _DayItinerary(
            dayNumber: updatedDays[dayIndex].dayNumber,
            date: updatedDays[dayIndex].date,
            activities: activities,
          );
        }
      }

      // Single setState with all updates
      setState(() {
        _days = updatedDays;
      });

      // Wait for UI to fully render before hiding loading indicator
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Generated ${generatedPlans.length} day${generatedPlans.length == 1 ? '' : 's'} of activities!',
              style: GoogleFonts.dmSans(),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } on AiGenerationException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message,
            style: GoogleFonts.dmSans(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to generate itinerary. Please try again.',
            style: GoogleFonts.dmSans(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  ActivityCategory _categoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return ActivityCategory.restaurant;
      case 'cafe':
        return ActivityCategory.cafe;
      case 'bar':
        return ActivityCategory.bar;
      case 'museum':
        return ActivityCategory.museum;
      case 'temple':
        return ActivityCategory.temple;
      case 'landmark':
      case 'attraction':
        return ActivityCategory.landmark;
      case 'shopping':
        return ActivityCategory.shopping;
      case 'park':
        return ActivityCategory.park;
      case 'beach':
        return ActivityCategory.beach;
      case 'tour':
        return ActivityCategory.tour;
      case 'nightlife':
        return ActivityCategory.nightlife;
      case 'entertainment':
        return ActivityCategory.entertainment;
      case 'spa':
        return ActivityCategory.spa;
      case 'sport':
        return ActivityCategory.sport;
      default:
        return ActivityCategory.landmark;
    }
  }
}

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

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.destination,
    required this.country,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.travelers,
    required this.days,
    required this.onPickDates,
    required this.onGenerate,
    required this.onDayTap,
  });

  final String destination;
  final String country;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int travelers;
  final List<_DayItinerary> days;
  final VoidCallback onPickDates;
  final VoidCallback onGenerate;
  final void Function(int dayIndex) onDayTap;

  @override
  Widget build(BuildContext context) {
    final totalActivities = days.fold<int>(
      0,
      (sum, day) => sum + day.activities.length,
    );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Hero image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.shimmerBase,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.shimmerBase,
                          child: const Icon(
                            LucideIcons.image,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Container(
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
                      // "Trip" text (main) with country below
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trip',
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (country.isNotEmpty)
                              Text(
                                country,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
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
              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: LucideIcons.calendar,
                      value: '${days.length}',
                      label: 'Days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: LucideIcons.users,
                      value: '$travelers',
                      label: 'Travelers',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: LucideIcons.mapPin,
                      value: '$totalActivities',
                      label: 'Activities',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Date range
              GestureDetector(
                onTap: onPickDates,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.calendarDays,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Travel Dates',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDateRange(),
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Daily overview header
              Text(
                'Daily Overview',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Day cards
              ...days.asMap().entries.map((entry) => _DayOverviewCard(
                day: entry.value,
                onTap: () => onDayTap(entry.key),
              )),

              // Bottom padding for generate button
              const SizedBox(height: 80),
            ],
          ),
        ),

        // Bottom generate button
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          decoration: BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onGenerate,
                icon: const Icon(LucideIcons.sparkles, size: 20),
                label: Text(
                  'Generate with AI',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateRange() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[startDate.month - 1]} ${startDate.day} - ${months[endDate.month - 1]} ${endDate.day}, ${endDate.year}';
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayOverviewCard extends StatelessWidget {
  const _DayOverviewCard({
    required this.day,
    required this.onTap,
  });

  final _DayItinerary day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[day.date.weekday - 1];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekday,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${day.date.day}',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
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
                  day.activities.isEmpty
                      ? 'No activities planned'
                      : '${day.activities.length} activities',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
      ),
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab({
    required this.days,
    required this.selectedDayIndex,
    required this.onDaySelected,
    required this.onAddActivity,
    required this.onActivityTap,
    required this.onActivityReorder,
    required this.onGenerate,
  });

  final List<_DayItinerary> days;
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelected;
  final void Function(int dayIndex) onAddActivity;
  final void Function(_ScheduledActivity activity) onActivityTap;
  final void Function(int dayIndex, int oldIndex, int newIndex) onActivityReorder;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day selector
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = index == selectedDayIndex;
              final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final weekday = weekdays[day.date.weekday - 1];

              return GestureDetector(
                onTap: () => onDaySelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.textOnPrimary.withValues(alpha: 0.7)
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${day.date.day}',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : AppColors.primary,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day ${selectedDayIndex + 1}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              TextButton.icon(
                onPressed: () => onAddActivity(selectedDayIndex),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: Text(
                  'Add',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Activities list
        Expanded(
          child: days[selectedDayIndex].activities.isEmpty
              ? _EmptyDayPlaceholder(
                  onAddActivity: () => onAddActivity(selectedDayIndex),
                  onGenerate: onGenerate,
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
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
                      isLast: index == days[selectedDayIndex].activities.length - 1,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyDayPlaceholder extends StatelessWidget {
  const _EmptyDayPlaceholder({
    required this.onAddActivity,
    required this.onGenerate,
  });

  final VoidCallback onAddActivity;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.calendarPlus,
                size: 36,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No activities yet',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add activities manually or let AI generate your itinerary',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onAddActivity,
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: Text(
                    'Add',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(LucideIcons.sparkles, size: 18),
                  label: Text(
                    'Generate',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activity.startTime ?? '--:--',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (activity.endTime != null)
                  Text(
                    activity.endTime!,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 70, color: AppColors.border),
            ],
          ),
          const SizedBox(width: 12),

          // Activity content
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CategoryIcon(category: activity.category),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            activity.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Icon(
                          LucideIcons.gripVertical,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                      ],
                    ),
                    if (activity.location != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activity.location!,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
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

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});

  final ActivityCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
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
        return LucideIcons.utensils;
      case ActivityCategory.cafe:
        return LucideIcons.coffee;
      case ActivityCategory.bar:
        return LucideIcons.wine;
      case ActivityCategory.museum:
        return LucideIcons.landmark;
      case ActivityCategory.temple:
        return LucideIcons.church;
      case ActivityCategory.landmark:
        return LucideIcons.building;
      case ActivityCategory.shopping:
        return LucideIcons.shoppingBag;
      case ActivityCategory.park:
        return LucideIcons.trees;
      case ActivityCategory.beach:
        return LucideIcons.umbrella;
      case ActivityCategory.tour:
        return LucideIcons.map;
      case ActivityCategory.nightlife:
        return LucideIcons.music;
      case ActivityCategory.entertainment:
        return LucideIcons.clapperboard;
      case ActivityCategory.spa:
        return LucideIcons.sparkles;
      case ActivityCategory.sport:
        return LucideIcons.dumbbell;
      case ActivityCategory.transport:
        return LucideIcons.train;
      case ActivityCategory.accommodation:
        return LucideIcons.hotel;
      default:
        return LucideIcons.mapPin;
    }
  }
}
