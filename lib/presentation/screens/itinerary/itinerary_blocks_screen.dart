import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/widgets/city_block.dart';
import 'package:trippified/presentation/widgets/transport_connector.dart';

/// Itinerary blocks screen for arranging cities
/// Matches design 47 (Itinerary Blocks) and 49 (Itinerary Blocks - Scrolled)
class ItineraryBlocksScreen extends StatefulWidget {
  const ItineraryBlocksScreen({super.key});

  @override
  State<ItineraryBlocksScreen> createState() => _ItineraryBlocksScreenState();
}

class _ItineraryBlocksScreenState extends State<ItineraryBlocksScreen> {
  // Mock data - would come from provider
  final List<_CountryItinerary> _itinerary = [
    _CountryItinerary(
      name: 'Japan',
      flag: '\u{1F1EF}\u{1F1F5}',
      cities: [
        _CityData(name: 'Tokyo', days: 5),
        _CityData(name: 'Kyoto', days: 4),
        _CityData(name: 'Osaka', days: 3),
      ],
      transports: [
        _TransportData(type: TransportType.train, duration: '2h 15m'),
        _TransportData(type: TransportType.train, duration: '15m'),
      ],
    ),
    _CountryItinerary(
      name: 'Vietnam',
      flag: '\u{1F1FB}\u{1F1F3}',
      cities: [
        _CityData(name: 'Hanoi', days: 4),
        _CityData(name: 'Ho Chi Minh City', days: 3),
      ],
      transports: [
        _TransportData(type: TransportType.plane, duration: '1h 20m'),
      ],
    ),
  ];

  int? _selectedCityIndex;
  int? _selectedCountryIndex;

  int get _totalDays {
    return _itinerary.fold(
      0,
      (sum, country) =>
          sum + country.cities.fold(0, (citySum, city) => citySum + city.days),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button and title
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
                      const SizedBox(width: 12),
                      Text(
                        'Your Itinerary',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  // Total days badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$_totalDays days',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Drag to reorder cities and countries',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Itinerary list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: _buildItineraryList(),
              ),
            ),

            // Add city button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _AddCityButton(onTap: _onAddCity),
            ),
            const SizedBox(height: AppSpacing.md),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onCreateTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                  ),
                  child: Text(
                    'Create My Trip',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItineraryList() {
    final widgets = <Widget>[];

    for (int countryIdx = 0; countryIdx < _itinerary.length; countryIdx++) {
      final country = _itinerary[countryIdx];

      // Country header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: CountrySectionHeader(
            countryName: country.name,
            flag: country.flag,
          ),
        ),
      );

      // Cities and transports
      for (int cityIdx = 0; cityIdx < country.cities.length; cityIdx++) {
        final city = country.cities[cityIdx];
        final isSelected =
            _selectedCountryIndex == countryIdx &&
            _selectedCityIndex == cityIdx;

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: CityBlock(
              cityName: city.name,
              days: city.days,
              isSelected: isSelected,
              onEdit: () => _onEditCity(countryIdx, cityIdx),
              onRemove: () => _onRemoveCity(countryIdx, cityIdx),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCountryIndex = null;
                    _selectedCityIndex = null;
                  } else {
                    _selectedCountryIndex = countryIdx;
                    _selectedCityIndex = cityIdx;
                  }
                });
              },
            ),
          ),
        );

        // Transport connector (if not last city in country)
        if (cityIdx < country.transports.length) {
          final transport = country.transports[cityIdx];
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: TransportConnector(
                transportType: transport.type,
                duration: transport.duration,
              ),
            ),
          );
        }
      }

      // Flight connector between countries (if not last country)
      if (countryIdx < _itinerary.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: TransportConnector(
              transportType: TransportType.plane,
              duration: '2h 30m',
              destination: _itinerary[countryIdx + 1].name,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  void _onEditCity(int countryIndex, int cityIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) => _EditCitySheet(
        city: _itinerary[countryIndex].cities[cityIndex],
        onSave: (days) {
          setState(() {
            _itinerary[countryIndex].cities[cityIndex] = _CityData(
              name: _itinerary[countryIndex].cities[cityIndex].name,
              days: days,
            );
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _onRemoveCity(int countryIndex, int cityIndex) {
    setState(() {
      _itinerary[countryIndex].cities.removeAt(cityIndex);
      // Also remove transport if exists
      if (cityIndex < _itinerary[countryIndex].transports.length) {
        _itinerary[countryIndex].transports.removeAt(cityIndex);
      } else if (_itinerary[countryIndex].transports.isNotEmpty) {
        _itinerary[countryIndex].transports.removeLast();
      }
      // Remove country if no cities left
      if (_itinerary[countryIndex].cities.isEmpty) {
        _itinerary.removeAt(countryIndex);
      }
    });
  }

  void _onAddCity() {
    // Show add city dialog
  }

  void _onCreateTrip() {
    // Navigate to trip dashboard
    context.go('/trip/new');
  }
}

class _AddCityButton extends StatelessWidget {
  const _AddCityButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.plus,
              size: 18,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Text(
              'Add City',
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

class _EditCitySheet extends StatefulWidget {
  const _EditCitySheet({
    required this.city,
    required this.onSave,
  });

  final _CityData city;
  final ValueChanged<int> onSave;

  @override
  State<_EditCitySheet> createState() => _EditCitySheetState();
}

class _EditCitySheetState extends State<_EditCitySheet> {
  late int _days;

  @override
  void initState() {
    super.initState();
    _days = widget.city.days;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit ${widget.city.name}',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Number of days',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              IconButton(
                onPressed: _days > 1
                    ? () => setState(() => _days--)
                    : null,
                icon: const Icon(LucideIcons.minus),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_days ${_days == 1 ? 'day' : 'days'}',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _days++),
                icon: const Icon(LucideIcons.plus),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => widget.onSave(_days),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _CountryItinerary {
  _CountryItinerary({
    required this.name,
    required this.flag,
    required this.cities,
    required this.transports,
  });

  final String name;
  final String flag;
  final List<_CityData> cities;
  final List<_TransportData> transports;
}

class _CityData {
  const _CityData({
    required this.name,
    required this.days,
  });

  final String name;
  final int days;
}

class _TransportData {
  const _TransportData({
    required this.type,
    required this.duration,
  });

  final TransportType type;
  final String duration;
}
