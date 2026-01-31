import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/core/services/claude_service.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/navigation/app_router.dart';
import 'package:trippified/presentation/widgets/day_card.dart';
import 'package:trippified/presentation/widgets/modals/generate_day_modal.dart';
import 'package:trippified/presentation/widgets/activity_timeline_item.dart';

/// Lightweight city info for trip-level navigation
class TripCityInfo {
  const TripCityInfo({required this.cityName, required this.days});

  final String cityName;
  final int days;
}

/// Day builder screen for planning individual days
class DayBuilderScreen extends StatefulWidget {
  const DayBuilderScreen({
    required this.cityName,
    required this.days,
    this.tripCities = const [],
    this.tripId,
    super.key,
  });

  final String cityName;
  final int days;

  /// All cities in the current trip (for the city switcher dropdown)
  final List<TripCityInfo> tripCities;

  /// Trip ID for navigation between cities
  final String? tripId;

  @override
  State<DayBuilderScreen> createState() => _DayBuilderScreenState();
}

class _DayBuilderScreenState extends State<DayBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _bottomNavIndex = 0;
  int _selectedTabIndex = 0;
  bool _isAutoFilling = false;
  int? _refreshingDayIndex;

  // Mock day data - would come from provider
  late List<_DayPlanData> _dayPlans;

  // Mutable date range
  late DateTime _startDate;
  late DateTime _endDate;

  // City coordinates for Google Maps
  static const _cityCoordinates = <String, LatLng>{
    'Tokyo': LatLng(35.6762, 139.6503),
    'Kyoto': LatLng(35.0116, 135.7681),
    'Osaka': LatLng(34.6937, 135.5023),
    'Hanoi': LatLng(21.0285, 105.8542),
    'Nara': LatLng(34.6851, 135.8048),
    'Paris': LatLng(48.8566, 2.3522),
    'Rome': LatLng(41.9028, 12.4964),
    'Ho Chi Minh City': LatLng(10.8231, 106.6297),
    'Ha Long Bay': LatLng(20.9101, 107.1839),
    'Sapa': LatLng(22.3363, 103.8438),
    'Bangkok': LatLng(13.7563, 100.5018),
    'Chiang Mai': LatLng(18.7883, 98.9853),
    'Phuket': LatLng(7.8804, 98.3923),
    'Hiroshima': LatLng(34.3853, 132.4553),
    'Fukuoka': LatLng(33.5904, 130.4017),
    'Sapporo': LatLng(43.0618, 141.3545),
    'Yokohama': LatLng(35.4437, 139.6380),
    'Nagoya': LatLng(35.1815, 136.9066),
    'Kobe': LatLng(34.6901, 135.1956),
  };

  LatLng get _cityCenter =>
      _cityCoordinates[widget.cityName] ??
      const LatLng(35.6762, 139.6503);

  // Flight data - populated from user's bookings
  FlightTicketData? _flight;

  // Hotel data - populated from user's bookings
  HotelTicketData? _hotel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    _startDate = DateTime(2025, 2, 11);
    _endDate = _startDate.add(Duration(days: widget.days - 1));
    _initializeDays();
  }

  void _initializeDays() {
    _dayPlans = List.generate(widget.days, (index) {
      final date = _startDate.add(Duration(days: index));
      return _DayPlanData(
        dayNumber: index + 1,
        date: _formatDayDate(date),
        status: DayStatus.empty,
        themeLabel: null,
        activityCount: 0,
        activityPreviews: [],
      );
    });
  }

  String _formatDayDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String get _dateRangeText {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = months[_startDate.month - 1];
    return '$m ${_startDate.day} - ${_endDate.day}';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final earliest = _startDate.isBefore(DateTime(now.year, 1, 1))
        ? DateTime(_startDate.year, 1, 1)
        : DateTime(now.year, 1, 1);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: earliest,
      lastDate: DateTime(now.year + 2, 12, 31),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _refreshDayDates();
      });
    }
  }

  void _refreshDayDates() {
    for (int i = 0; i < _dayPlans.length; i++) {
      final date = _startDate.add(Duration(days: i));
      _dayPlans[i] = _DayPlanData(
        dayNumber: _dayPlans[i].dayNumber,
        date: _formatDayDate(date),
        status: _dayPlans[i].status,
        themeLabel: _dayPlans[i].themeLabel,
        activityCount: _dayPlans[i].activityCount,
        activityPreviews: _dayPlans[i].activityPreviews,
        generatedActivities: _dayPlans[i].generatedActivities,
      );
    }
  }

  @override
  void dispose() {
    _dismissDropdown();
    _tabController.dispose();
    super.dispose();
  }

  int get _daysPlanned =>
      _dayPlans.where((day) => day.status != DayStatus.empty).length;

  int get _daysToplan =>
      _dayPlans.where((day) => day.status == DayStatus.empty).length;

  String get _progressText {
    if (_daysPlanned == 0) {
      return '${widget.days} days to plan';
    }
    return '$_daysPlanned of ${widget.days} days planned';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Map section with collapse handle
          _buildMapSection(),

          // Content section
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _OverviewTab(
                          dayPlans: _dayPlans,
                          progressText: _progressText,
                          showAutoFill: _daysToplan > 0,
                          isAutoFilling: _isAutoFilling,
                          refreshingDayIndex: _refreshingDayIndex,
                          onAutoFill: _autoFillDays,
                          onGenerateDay: _showGenerateModal,
                          onEditDay: _editDay,
                          onRefreshDay: _refreshDay,
                        ),
                        _ItineraryTab(
                          dayPlans: _dayPlans,
                          cityName: widget.cityName,
                          totalDays: widget.days,
                          flight: _flight,
                          hotel: _hotel,
                        ),
                        _BookingsTab(
                          flight: _flight,
                          hotel: _hotel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          if (index != _bottomNavIndex) {
            context.go(AppRoutes.home);
          }
        },
      ),
    );
  }

  Widget _buildMapSection() {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.45,
      child: Stack(
        children: [
          // Apple Maps — muted standard style
          Positioned.fill(
            child: AppleMap(
              key: const ValueKey('day_builder_map'),
              mapType: MapType.standard,
              initialCameraPosition: CameraPosition(
                target: _cityCenter,
                zoom: 13,
              ),
              annotations: {
                Annotation(
                  annotationId: AnnotationId('city_pin'),
                  position: _cityCenter,
                  infoWindow: InfoWindow(
                    title: widget.cityName,
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
          ),

          // Back button — plain arrow
          Positioned(
            top: topPadding + 12,
            left: AppSpacing.md,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(
                LucideIcons.chevronLeft,
                size: 28,
                color: AppColors.primary,
              ),
            ),
          ),

          // Rounded overlap bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18),
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

  bool get _hasSiblingCities => widget.tripCities.length > 1;

  final _headerKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;

  void _showCitySwitcher() {
    if (!_hasSiblingCities) return;

    // If already showing, dismiss
    if (_dropdownOverlay != null) {
      _dismissDropdown();
      return;
    }

    final renderBox =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final top = position.dy + size.height + 4;

    _dropdownOverlay = OverlayEntry(
      builder: (context) => _CityDropdownOverlay(
        top: top,
        cities: widget.tripCities,
        currentCityName: widget.cityName,
        onSelect: (city) {
          _dismissDropdown();
          _navigateToCity(city);
        },
        onDismiss: _dismissDropdown,
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _dismissDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  void _navigateToCity(TripCityInfo city) {
    final tripId = widget.tripId ?? 'new';
    context.go(
      '/trip/$tripId/day/${city.cityName}',
      extra: {
        'days': city.days,
        'tripCities': widget.tripCities
            .map((c) => {'cityName': c.cityName, 'days': c.days})
            .toList(),
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // City title with dropdown
          GestureDetector(
            key: _headerKey,
            onTap: _hasSiblingCities ? _showCitySwitcher : null,
            child: Row(
              children: [
                Text(
                  '${widget.days} Days in ${widget.cityName}',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (_hasSiblingCities) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    LucideIcons.chevronDown,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
          // Date badge (tappable)
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
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

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildTab('Overview', 0),
          _buildTab('Itinerary', 1),
          _buildTab('Bookings', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
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
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _autoFillDays() async {
    final emptyDayNumbers = <int>[];
    final filledDayThemes = <int, String>{};

    for (final plan in _dayPlans) {
      if (plan.status == DayStatus.empty) {
        emptyDayNumbers.add(plan.dayNumber);
      } else if (plan.themeLabel != null) {
        filledDayThemes[plan.dayNumber] = plan.themeLabel!;
      }
    }

    if (emptyDayNumbers.isEmpty) return;

    setState(() {
      _isAutoFilling = true;
    });

    try {
      final generatedPlans = await ClaudeService.instance.generateDayPlans(
        cityName: widget.cityName,
        totalDays: widget.days,
        emptyDayNumbers: emptyDayNumbers,
        filledDayThemes: filledDayThemes,
      );

      if (!mounted) return;

      setState(() {
        for (final generated in generatedPlans) {
          final index = generated.dayNumber - 1;
          if (index < 0 || index >= _dayPlans.length) continue;
          if (_dayPlans[index].status != DayStatus.empty) continue;

          final previews = generated.activities
              .map((a) => DayActivityPreview(
                    name: a.name,
                    isAnchor: a.isAnchor,
                  ))
              .toList();

          _dayPlans[index] = _DayPlanData(
            dayNumber: _dayPlans[index].dayNumber,
            date: _dayPlans[index].date,
            status: DayStatus.generated,
            themeLabel: generated.themeLabel,
            activityCount: previews.length,
            activityPreviews: previews,
            generatedActivities: generated.activities,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${generatedPlans.length} days auto-filled!'),
          ),
        );
      }
    } on AiGenerationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to auto-fill. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAutoFilling = false;
        });
      }
    }
  }

  Future<void> _showGenerateModal(int dayIndex) async {
    final selectedTheme = await GenerateDayModal.show(
      context: context,
      dayNumber: dayIndex + 1,
      cityName: widget.cityName,
    );

    if (selectedTheme != null) {
      _generateDayWithTheme(dayIndex, selectedTheme);
    }
  }

  Future<void> _generateDayWithTheme(
    int dayIndex,
    DayThemeOption theme,
  ) async {
    setState(() {
      _refreshingDayIndex = dayIndex;
    });

    try {
      final filledDayThemes = <int, String>{};
      for (final plan in _dayPlans) {
        if (plan.status != DayStatus.empty &&
            plan.themeLabel != null &&
            plan.dayNumber != _dayPlans[dayIndex].dayNumber) {
          filledDayThemes[plan.dayNumber] = plan.themeLabel!;
        }
      }

      final generatedPlans = await ClaudeService.instance.generateDayPlans(
        cityName: widget.cityName,
        totalDays: widget.days,
        emptyDayNumbers: [_dayPlans[dayIndex].dayNumber],
        filledDayThemes: filledDayThemes,
        themePreference: theme.title,
      );

      if (!mounted) return;

      if (generatedPlans.isNotEmpty) {
        final generated = generatedPlans.first;
        final previews = generated.activities
            .map((a) => DayActivityPreview(
                  name: a.name,
                  isAnchor: a.isAnchor,
                ))
            .toList();

        setState(() {
          _dayPlans[dayIndex] = _DayPlanData(
            dayNumber: _dayPlans[dayIndex].dayNumber,
            date: _dayPlans[dayIndex].date,
            status: DayStatus.generated,
            themeLabel: generated.themeLabel,
            activityCount: previews.length,
            activityPreviews: previews,
            generatedActivities: generated.activities,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Day ${dayIndex + 1} generated with ${theme.title}!'),
            ),
          );
        }
      }
    } on AiGenerationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _refreshingDayIndex = null;
        });
      }
    }
  }

  Future<void> _editDay(int dayIndex) async {
    final selectedTheme = await GenerateDayModal.show(
      context: context,
      dayNumber: dayIndex + 1,
      cityName: widget.cityName,
    );

    if (selectedTheme != null) {
      await _generateDayWithTheme(dayIndex, selectedTheme);
    }
  }

  Future<void> _refreshDay(int dayIndex) async {
    setState(() {
      _refreshingDayIndex = dayIndex;
    });

    try {
      final filledDayThemes = <int, String>{};
      for (final plan in _dayPlans) {
        if (plan.status != DayStatus.empty &&
            plan.themeLabel != null &&
            plan.dayNumber != _dayPlans[dayIndex].dayNumber) {
          filledDayThemes[plan.dayNumber] = plan.themeLabel!;
        }
      }

      final generatedPlans = await ClaudeService.instance.generateDayPlans(
        cityName: widget.cityName,
        totalDays: widget.days,
        emptyDayNumbers: [_dayPlans[dayIndex].dayNumber],
        filledDayThemes: filledDayThemes,
      );

      if (!mounted) return;

      if (generatedPlans.isNotEmpty) {
        final generated = generatedPlans.first;
        final previews = generated.activities
            .map((a) => DayActivityPreview(
                  name: a.name,
                  isAnchor: a.isAnchor,
                ))
            .toList();

        setState(() {
          _dayPlans[dayIndex] = _DayPlanData(
            dayNumber: _dayPlans[dayIndex].dayNumber,
            date: _dayPlans[dayIndex].date,
            status: DayStatus.generated,
            themeLabel: generated.themeLabel,
            activityCount: previews.length,
            activityPreviews: previews,
            generatedActivities: generated.activities,
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Day ${dayIndex + 1} refreshed!'),
            ),
          );
        }
      }
    } on AiGenerationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to refresh. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _refreshingDayIndex = null;
        });
      }
    }
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.dayPlans,
    required this.progressText,
    required this.showAutoFill,
    required this.isAutoFilling,
    required this.onAutoFill,
    required this.onGenerateDay,
    required this.onEditDay,
    required this.onRefreshDay,
    this.refreshingDayIndex,
  });

  final List<_DayPlanData> dayPlans;
  final String progressText;
  final bool showAutoFill;
  final bool isAutoFilling;
  final int? refreshingDayIndex;
  final VoidCallback onAutoFill;
  final void Function(int) onGenerateDay;
  final void Function(int) onEditDay;
  final void Function(int) onRefreshDay;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        10,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        // Header row with progress and auto-fill button
        Padding(
          padding: const EdgeInsets.only(right: 14, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressText,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (showAutoFill)
                GestureDetector(
                  onTap: isAutoFilling ? null : onAutoFill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isAutoFilling
                          ? AppColors.border
                          : AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAutoFilling)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textSecondary,
                            ),
                          )
                        else
                          const Icon(
                            LucideIcons.sparkles,
                            size: 14,
                            color: AppColors.textOnAccent,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          isAutoFilling ? 'Generating...' : 'Auto-fill',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isAutoFilling
                                ? AppColors.textSecondary
                                : AppColors.textOnAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Day cards
        ...dayPlans.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: DayCard(
              dayNumber: day.dayNumber,
              date: day.date,
              status: day.status,
              themeLabel: day.themeLabel,
              activityCount: day.activityCount,
              activityPreviews: day.activityPreviews,
              isRefreshing: refreshingDayIndex == index,
              onGenerate: day.status == DayStatus.empty
                  ? () => onGenerateDay(index)
                  : null,
              onEdit: day.status != DayStatus.empty
                  ? () => onEditDay(index)
                  : null,
              onTap: () {
                // Navigate to day detail
              },
              onRefresh: day.status != DayStatus.empty
                  ? () => onRefreshDay(index)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}

class _ItineraryTab extends StatefulWidget {
  const _ItineraryTab({
    required this.dayPlans,
    required this.cityName,
    required this.totalDays,
    this.flight,
    this.hotel,
  });

  final List<_DayPlanData> dayPlans;
  final String cityName;
  final int totalDays;
  final FlightTicketData? flight;
  final HotelTicketData? hotel;

  @override
  State<_ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends State<_ItineraryTab> {
  int _selectedDayIndex = 0;

  List<_ItinerarySection> _buildItineraryFromActivities(
    List<GeneratedActivity> activities,
  ) {
    if (activities.isEmpty) return [];

    // Group activities by time period
    final morning = <GeneratedActivity>[];
    final midday = <GeneratedActivity>[];
    final afternoon = <GeneratedActivity>[];
    final evening = <GeneratedActivity>[];

    for (final activity in activities) {
      final period = _getTimePeriod(activity.time);
      switch (period) {
        case 'Morning':
          morning.add(activity);
        case 'Midday':
          midday.add(activity);
        case 'Afternoon':
          afternoon.add(activity);
        case 'Evening':
          evening.add(activity);
      }
    }

    final sections = <_ItinerarySection>[];
    var idCounter = 0;

    void addSection(String period, List<GeneratedActivity> items) {
      if (items.isEmpty) return;
      sections.add(
        _ItinerarySection(
          period: period,
          items: items
              .map((a) => ActivityTimelineData(
                    id: '${idCounter++}',
                    name: a.name,
                    time: a.time,
                    location: a.location,
                    type: _mapCategoryToType(a.category),
                    description: a.description,
                    duration: _formatDuration(a.durationMinutes),
                    bookingStatus: BookingStatus.none,
                  ))
              .toList(),
        ),
      );
    }

    addSection('Morning', morning);
    addSection('Midday', midday);
    addSection('Afternoon', afternoon);
    addSection('Evening', evening);

    return sections;
  }

  String _getTimePeriod(String time) {
    // Parse "9:00 AM", "1:30 PM" etc.
    final upper = time.toUpperCase().trim();
    final isPM = upper.contains('PM');
    final parts = upper.replaceAll(RegExp(r'[APM\s]'), '').split(':');
    var hour = int.tryParse(parts.first) ?? 9;
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    if (hour < 12) return 'Morning';
    if (hour < 14) return 'Midday';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  TimelineItemType _mapCategoryToType(String category) {
    switch (category) {
      case 'restaurant':
      case 'cafe':
      case 'bar':
        return TimelineItemType.meal;
      default:
        return TimelineItemType.activity;
    }
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remaining = minutes % 60;
      if (remaining == 0) return '~$hours hr${hours > 1 ? 's' : ''}';
      return '~$hours hr $remaining min';
    }
    return '~$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day tabs
        _buildDayTabs(),
        // Itinerary list
        Expanded(
          child: _buildItineraryList(),
        ),
      ],
    );
  }

  Widget _buildDayTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.totalDays,
          (index) => _buildDayTab(index),
        ),
      ),
    );
  }

  Widget _buildDayTab(int index) {
    final isSelected = _selectedDayIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDayIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Day ${index + 1}',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildItineraryList() {
    final selectedDay = widget.dayPlans[_selectedDayIndex];
    final itinerary =
        _buildItineraryFromActivities(selectedDay.generatedActivities);

    if (selectedDay.status == DayStatus.empty ||
        selectedDay.generatedActivities.isEmpty) {
      return _buildEmptyDayState();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      children: [
        // Flight card if present and Day 1
        if (widget.flight != null && _selectedDayIndex == 0) ...[
          const TimePeriodLabel(label: 'Flight'),
          const SizedBox(height: AppSpacing.md),
          FlightTicketCard(
            flight: widget.flight!,
            onViewReservation: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View flight reservation')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Hotel card if present and Day 1
        if (widget.hotel != null && _selectedDayIndex == 0) ...[
          const TimePeriodLabel(label: 'Accommodation'),
          const SizedBox(height: AppSpacing.md),
          HotelTicketCard(
            hotel: widget.hotel!,
            onViewReservation: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View hotel reservation')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TravelTimeConnector(
            travelTime: const TravelTimeData(
              duration: '10 min walk',
              mode: TravelMode.walk,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Itinerary sections
        ...itinerary.asMap().entries.expand((entry) {
          final index = entry.key;
          final section = entry.value;
          final widgets = <Widget>[];

          // Period label
          if (section.period != null) {
            widgets.add(TimePeriodLabel(label: section.period!));
            widgets.add(const SizedBox(height: AppSpacing.md));
          }

          // Activity items
          for (final activity in section.items) {
            widgets.add(
              ActivityTimelineItem(
                activity: activity,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('View ${activity.name}')),
                  );
                },
              ),
            );
            widgets.add(const SizedBox(height: AppSpacing.md));
          }

          // Travel time connector
          if (section.travelAfter != null && index < itinerary.length - 1) {
            widgets.add(
              TravelTimeConnector(travelTime: section.travelAfter!),
            );
            widgets.add(const SizedBox(height: AppSpacing.md));
          }

          return widgets;
        }),

        // Add activity button
        const SizedBox(height: AppSpacing.sm),
        _buildAddActivityButton(),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildEmptyDayState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.calendarPlus,
                size: 36,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No activities yet',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Generate this day from the Overview\ntab to see your itinerary.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddActivityButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add activity - coming soon!')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.plus,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Activity',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section data for itinerary timeline
class _ItinerarySection {
  const _ItinerarySection({
    this.period,
    required this.items,
    this.travelAfter,
  });

  final String? period;
  final List<ActivityTimelineData> items;
  final TravelTimeData? travelAfter;
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab({
    this.flight,
    this.hotel,
  });

  final FlightTicketData? flight;
  final HotelTicketData? hotel;

  bool get _hasBookings => flight != null || hotel != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasBookings) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Flight booking
        if (flight != null) ...[
          Text(
            'Flights',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FlightTicketCard(
            flight: flight!,
            onViewReservation: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View flight reservation')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Hotel booking
        if (hotel != null) ...[
          Text(
            'Accommodation',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          HotelTicketCard(
            hotel: hotel!,
            onViewReservation: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View hotel reservation')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Add booking button
        const SizedBox(height: AppSpacing.md),
        _buildAddBookingButton(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          const Spacer(flex: 3),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.ticket,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No bookings yet',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add flights, hotels, and activities\nto track your bookings',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(
              'Add Booking',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }

  Widget _buildAddBookingButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add booking - coming soon!')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.plus,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Booking',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown overlay for switching between trip cities
class _CityDropdownOverlay extends StatelessWidget {
  const _CityDropdownOverlay({
    required this.top,
    required this.cities,
    required this.currentCityName,
    required this.onSelect,
    required this.onDismiss,
  });

  final double top;
  final List<TripCityInfo> cities;
  final String currentCityName;
  final void Function(TripCityInfo) onSelect;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dimmed backdrop
        GestureDetector(
          onTap: onDismiss,
          child: Container(color: const Color(0x55000000)),
        ),
        // Dropdown card
        Positioned(
          top: top,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: cities.map((city) {
                  final isCurrent = city.cityName == currentCityName;
                  return GestureDetector(
                    onTap: () {
                      if (!isCurrent) {
                        onSelect(city);
                      } else {
                        onDismiss();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.accent.withValues(alpha: 0.08)
                            : Colors.transparent,
                        border: Border(
                          bottom: city != cities.last
                              ? const BorderSide(color: AppColors.border)
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${city.days} Days in ${city.cityName}',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            const Icon(
                              LucideIcons.check,
                              size: 16,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayPlanData {
  const _DayPlanData({
    required this.dayNumber,
    required this.date,
    required this.status,
    this.themeLabel,
    required this.activityCount,
    required this.activityPreviews,
    this.generatedActivities = const [],
  });

  final int dayNumber;
  final String date;
  final DayStatus status;
  final String? themeLabel;
  final int activityCount;
  final List<DayActivityPreview> activityPreviews;
  final List<GeneratedActivity> generatedActivities;
}
