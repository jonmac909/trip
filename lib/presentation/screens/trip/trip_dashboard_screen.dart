import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/navigation/app_router.dart';
import 'package:trippified/presentation/widgets/checklist_item.dart';
import 'package:trippified/presentation/widgets/transport_connector.dart';

/// Trip dashboard screen showing trip overview
/// Matches designs 48-53 (Trip Dashboard variants with checklist)
class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({required this.tripId, super.key});

  final String tripId;

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen> {
  int _bottomNavIndex = 0;
  bool _showChecklist = false;
  bool _isEditing = false;
  DateTime? _startDate;
  DateTime? _endDate;
  late List<_CityItinerary> _cityItineraries;

  // Mock trip data - would come from provider
  late final _TripData _tripData;

  static final _mockTrips = <String, _TripData>{
    '1': _TripData(
      id: '1',
      title: 'Japan Adventure',
      imageUrl:
          'https://images.unsplash.com/photo-1743515169286-7be1203c641a?w=800&q=80',
      cities: 3,
      countries: 1,
      days: 14,
      startDate: DateTime(2025, 3, 15),
      endDate: DateTime(2025, 3, 28),
      cityItineraries: [
        _CityItinerary(
          name: 'Tokyo',
          imageUrl:
              'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400&q=80',
          days: 5,
          status: 'Planning',
        ),
        _CityItinerary(
          name: 'Kyoto',
          imageUrl:
              'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400&q=80',
          days: 5,
          status: null,
        ),
        _CityItinerary(
          name: 'Osaka',
          imageUrl:
              'https://images.unsplash.com/photo-1590559899731-a382839e5549?w=400&q=80',
          days: 4,
          status: null,
        ),
      ],
      transports: [
        _TransportInfo(type: TransportType.train, duration: '2 hr 15 min'),
        _TransportInfo(type: TransportType.train, duration: '15 min'),
      ],
    ),
    '2': _TripData(
      id: '2',
      title: 'Europe Trip 2025',
      imageUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&q=80',
      cities: 2,
      countries: 2,
      days: 9,
      startDate: DateTime(2025, 6, 15),
      endDate: DateTime(2025, 6, 24),
      cityItineraries: [
        _CityItinerary(
          name: 'Paris',
          imageUrl:
              'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400&q=80',
          days: 5,
          status: 'Planning',
        ),
        _CityItinerary(
          name: 'Rome',
          imageUrl:
              'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400&q=80',
          days: 4,
          status: null,
        ),
      ],
      transports: [
        _TransportInfo(type: TransportType.plane, duration: '2 hr'),
      ],
    ),
  };

  // Checklist sections state
  late List<ChecklistSectionData> _checklistSections;

  @override
  void initState() {
    super.initState();
    _tripData = _mockTrips[widget.tripId] ?? _mockTrips['1']!;
    _startDate = _tripData.startDate;
    _endDate = _tripData.endDate;
    _cityItineraries = List.from(_tripData.cityItineraries);
    _initializeChecklist();
  }

  void _initializeChecklist() {
    _checklistSections = [
      ChecklistSectionData(
        id: 'transport',
        title: 'Transport',
        icon: LucideIcons.plane,
        isExpanded: true,
        items: [
          const ChecklistItemData(
            id: 'flight_tokyo',
            title: 'Flight to Tokyo',
            subtitle: 'Japan Airlines \u00b7 Feb 10',
            isChecked: true,
            badge: 'Booked',
          ),
          const ChecklistItemData(
            id: 'shinkansen',
            title: 'Shinkansen to Kyoto',
            subtitle: 'Nozomi 225 \u00b7 Feb 14',
            isChecked: true,
            badge: 'Booked',
          ),
          const ChecklistItemData(
            id: 'flight_vietnam',
            title: 'Flight to Vietnam',
            subtitle: 'VietJet Air \u00b7 Feb 18',
            isChecked: false,
          ),
        ],
      ),
      ChecklistSectionData(
        id: 'accommodation',
        title: 'Accommodation',
        icon: LucideIcons.bed,
        isExpanded: false,
        items: [
          const ChecklistItemData(
            id: 'tokyo_hotel',
            title: 'Tokyo Hotel',
            subtitle: 'Shinjuku Prince Hotel \u00b7 7 nights',
            isChecked: true,
            badge: 'Booked',
          ),
          const ChecklistItemData(
            id: 'hanoi_hotel',
            title: 'Hanoi Hotel',
            subtitle: 'Old Quarter area',
            isChecked: false,
          ),
        ],
      ),
      ChecklistSectionData(
        id: 'activities',
        title: 'Activities',
        icon: LucideIcons.mapPin,
        isExpanded: false,
        items: [
          const ChecklistItemData(
            id: 'teamlab',
            title: 'teamLab Borderless',
            subtitle: 'Tokyo \u00b7 Reservation required',
            isChecked: true,
            badge: 'Booked',
          ),
          const ChecklistItemData(
            id: 'fushimi',
            title: 'Fushimi Inari Shrine',
            subtitle: 'Kyoto \u00b7 Free entry',
            isChecked: false,
          ),
          const ChecklistItemData(
            id: 'halong',
            title: 'Ha Long Bay Cruise',
            subtitle: 'Vietnam \u00b7 Day trip',
            isChecked: false,
          ),
        ],
      ),
      ChecklistSectionData(
        id: 'before_you_go',
        title: 'Before You Go',
        icon: LucideIcons.calendarCheck,
        isExpanded: false,
        items: [
          const ChecklistItemData(
            id: 'visa',
            title: 'Check visa requirements',
            subtitle: 'Japan \u00b7 Visa-free for 90 days',
            isChecked: true,
          ),
          const ChecklistItemData(
            id: 'maps',
            title: 'Download offline maps',
            subtitle: 'Tokyo, Kyoto, Hanoi areas',
            isChecked: false,
          ),
          const ChecklistItemData(
            id: 'insurance',
            title: 'Travel insurance',
            subtitle: 'Recommended for international travel',
            isChecked: false,
          ),
          const ChecklistItemData(
            id: 'checkin',
            title: 'Check-in online',
            subtitle: 'Japan Airlines \u00b7 24hrs before',
            isChecked: false,
          ),
        ],
      ),
      ChecklistSectionData(
        id: 'packing',
        title: 'Packing',
        icon: LucideIcons.briefcase,
        isExpanded: false,
        items: [
          const ChecklistItemData(
            id: 'passport',
            title: 'Passport',
            subtitle: 'Valid for 6+ months',
            isChecked: true,
          ),
          const ChecklistItemData(
            id: 'charger',
            title: 'Universal adapter',
            subtitle: 'Japan uses Type A/B plugs',
            isChecked: false,
          ),
          const ChecklistItemData(
            id: 'medications',
            title: 'Medications',
            subtitle: 'Pack in carry-on',
            isChecked: false,
          ),
          const ChecklistItemData(
            id: 'clothes',
            title: 'Weather-appropriate clothes',
            subtitle: 'Check forecast before packing',
            isChecked: false,
          ),
          const ChecklistItemData(
            id: 'toiletries',
            title: 'Toiletries',
            subtitle: 'Travel-size for carry-on',
            isChecked: false,
          ),
          const ChecklistItemData(
            id: 'electronics',
            title: 'Camera & electronics',
            subtitle: 'Phone, camera, headphones',
            isChecked: false,
          ),
        ],
      ),
    ];
  }

  int get _totalChecklistItems {
    return _checklistSections.fold(
      0,
      (sum, section) => sum + section.items.length,
    );
  }

  int get _completedChecklistItems {
    return _checklistSections.fold(
      0,
      (sum, section) => sum + section.completedCount,
    );
  }

  void _toggleSection(String sectionId) {
    setState(() {
      _checklistSections = _checklistSections.map((section) {
        if (section.id == sectionId) {
          return section.copyWith(isExpanded: !section.isExpanded);
        }
        return section;
      }).toList();
    });
  }

  void _toggleItem(String sectionId, String itemId) {
    setState(() {
      _checklistSections = _checklistSections.map((section) {
        if (section.id == sectionId) {
          final updatedItems = section.items.map((item) {
            if (item.id == itemId) {
              return item.copyWith(isChecked: !item.isChecked);
            }
            return item;
          }).toList();
          return section.copyWith(items: updatedItems);
        }
        return section;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 20),
                  if (_showChecklist)
                    _buildChecklistView()
                  else
                    _buildItineraryView(),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildHeroImage() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          child: CachedNetworkImage(
            imageUrl: _tripData.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: AppColors.shimmerBase),
            errorWidget: (context, url, error) => Container(
              color: AppColors.shimmerBase,
              child: const Icon(
                LucideIcons.image,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 20,
          child: GestureDetector(
            onTap: () {
              if (_showChecklist) {
                setState(() => _showChecklist = false);
              } else {
                context.pop();
              }
            },
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
      ],
    );
  }

  Widget _buildHeaderSection() {
    final hasDate = _startDate != null && _endDate != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tripData.title,
          style: GoogleFonts.dmSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDateRange,
          child: hasDate
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDateRange(_startDate!, _endDate!),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        LucideIcons.calendar,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Text(
                      'Add dates?',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.pencil,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = months[start.month - 1];
    return '$m ${start.day} \u2013 ${end.day}, ${end.year}';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialStart = _startDate ?? now;
    final initialEnd =
        _endDate ?? now.add(Duration(days: _tripData.days));

    // firstDate must be on or before initialStart
    final earliest = initialStart.isBefore(DateTime(now.year, 1, 1))
        ? DateTime(initialStart.year, 1, 1)
        : DateTime(now.year, 1, 1);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: earliest,
      lastDate: DateTime(now.year + 2, 12, 31),
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd,
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
      });
    }
  }

  Widget _buildItineraryView() {
    final totalDays = _cityItineraries.fold(0, (sum, c) => sum + c.days);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '${_cityItineraries.length}',
                label: 'Cities',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                value: '${_tripData.countries}',
                label: 'Countries',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(value: '$totalDays', label: 'Days'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Checklist card (tap to expand)
        GestureDetector(
          onTap: () => setState(() => _showChecklist = true),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.listChecks,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trip Checklist',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_completedChecklistItems/$_totalChecklistItems done',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Your Itineraries section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Itineraries',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _isEditing = !_isEditing),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Text(
                  _isEditing ? 'Done' : 'Edit',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isEditing
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // City itinerary cards (reorderable)
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: _onReorder,
          proxyDecorator: (child, index, animation) {
            return Material(
              elevation: 4,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
          itemCount: _cityItineraries.length,
          itemBuilder: (context, index) {
            final city = _cityItineraries[index];
            final isLast = index == _cityItineraries.length - 1;

            return Padding(
              key: ValueKey('city_${city.name}'),
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CityItineraryCard(
                    city: city,
                    index: index,
                    isEditing: _isEditing,
                    onTap: () {
                      context.push(
                        '/trip/${_tripData.id}/day/${city.name}',
                        extra: {
                          'days': city.days,
                          'tripCities': _cityItineraries
                              .map((c) => {
                                    'cityName': c.name,
                                    'days': c.days,
                                  })
                              .toList(),
                        },
                      );
                    },
                    onDelete: () => _deleteCity(index),
                  ),
                  if (!isLast &&
                      index < _tripData.transports.length)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: DashboardTransportConnector(
                        transportType:
                            _tripData.transports[index].type,
                        duration:
                            _tripData.transports[index].duration,
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        // Add itinerary button
        const SizedBox(height: 10),
        _AddItineraryButton(onTap: _showAddCitySheet),
      ],
    );
  }

  Widget _buildChecklistView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checklist header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trip Checklist',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$_completedChecklistItems/$_totalChecklistItems',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Checklist sections
        ..._checklistSections.map((section) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ChecklistSectionWidget(
              section: section,
              onToggleExpand: () => _toggleSection(section.id),
              onToggleItem: (itemId) => _toggleItem(section.id, itemId),
            ),
          );
        }),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final adjustedIndex =
          newIndex > oldIndex ? newIndex - 1 : newIndex;
      final city = _cityItineraries.removeAt(oldIndex);
      _cityItineraries.insert(adjustedIndex, city);
    });
  }

  void _deleteCity(int index) {
    if (_cityItineraries.length <= 1) return;
    setState(() {
      _cityItineraries.removeAt(index);
    });
  }

  void _showAddCitySheet() {
    final cities = <String>[
      'Nara',
      'Hiroshima',
      'Fukuoka',
      'Sapporo',
      'Yokohama',
      'Nagoya',
      'Kobe',
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _AddCitySheet(
          suggestions: cities,
          onCitySelected: (city) {
            Navigator.pop(sheetContext);
            setState(() {
              _cityItineraries.add(_CityItinerary(
                name: city,
                imageUrl:
                    'https://images.unsplash.com/photo-1480796927426-f609979314bd?w=400&q=80',
                days: 3,
              ));
            });
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CityItineraryCard extends StatelessWidget {
  const _CityItineraryCard({
    super.key,
    required this.city,
    this.onTap,
    this.onDelete,
    this.isEditing = false,
    this.index = 0,
  });

  final _CityItinerary city;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isEditing;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Drag handle (activates reorder on drag)
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  LucideIcons.gripVertical,
                  size: 16,
                  color: AppColors.borderDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: CachedNetworkImage(
                  imageUrl: city.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: AppColors.shimmerBase),
                  errorWidget: (context, url, error) =>
                      Container(color: AppColors.shimmerBase),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Text(
                '${city.name} \u00b7 ${city.days} Days',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Delete button in edit mode
            if (isEditing)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            // Badge or Arrow in normal mode
            else if (city.status != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  city.status!,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              const Icon(
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

class _AddItineraryButton extends StatelessWidget {
  const _AddItineraryButton({required this.onTap});

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.plus,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Add another itinerary',
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

class _AddCitySheet extends StatefulWidget {
  const _AddCitySheet({
    required this.suggestions,
    required this.onCitySelected,
  });

  final List<String> suggestions;
  final ValueChanged<String> onCitySelected;

  @override
  State<_AddCitySheet> createState() => _AddCitySheetState();
}

class _AddCitySheetState extends State<_AddCitySheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onCitySelected(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add a city',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Text input
          TextField(
            controller: _controller,
            autofocus: false,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Type a city name...',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: _submit,
                icon: const Icon(
                  LucideIcons.arrowRight,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Text(
            'Suggestions',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.suggestions.map((city) {
              return GestureDetector(
                onTap: () => widget.onCitySelected(city),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    city,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TripData {
  const _TripData({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.cities,
    required this.countries,
    required this.days,
    required this.cityItineraries,
    required this.transports,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String title;
  final String imageUrl;
  final int cities;
  final int countries;
  final int days;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<_CityItinerary> cityItineraries;
  final List<_TransportInfo> transports;
}

class _CityItinerary {
  const _CityItinerary({
    required this.name,
    required this.imageUrl,
    required this.days,
    this.status,
  });

  final String name;
  final String imageUrl;
  final int days;
  final String? status;
}

class _TransportInfo {
  const _TransportInfo({required this.type, required this.duration});

  final TransportType type;
  final String duration;
}
