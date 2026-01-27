import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Screen for customizing an itinerary from saved places
class CustomizeItineraryScreen extends StatefulWidget {
  const CustomizeItineraryScreen({
    super.key,
    required this.itineraryId,
    this.cityName,
    this.country,
    this.places,
  });

  final String itineraryId;
  final String? cityName;
  final String? country;
  final List<String>? places;

  @override
  State<CustomizeItineraryScreen> createState() =>
      _CustomizeItineraryScreenState();
}

class _CustomizeItineraryScreenState extends State<CustomizeItineraryScreen> {
  final _nameController = TextEditingController();
  double _durationDays = 2;
  static const _minDays = 1.0;
  static const _maxDays = 14.0;

  // Mock data - would come from provider
  late List<_SelectedPlaceData> _selectedPlaces;

  @override
  void initState() {
    super.initState();
    _nameController.text = '${widget.cityName ?? "Tokyo"} Weekend';

    // Initialize selected places from widget or mock data
    _selectedPlaces = widget.places?.asMap().entries.map((entry) {
          return _SelectedPlaceData(
            name: entry.value,
            category: _getMockCategory(entry.key),
            area: _getMockArea(entry.key),
          );
        }).toList() ??
        const [
          _SelectedPlaceData(
            name: 'Ichiran Ramen',
            category: 'Restaurant',
            area: 'Shibuya',
          ),
          _SelectedPlaceData(
            name: 'Senso-ji Temple',
            category: 'Attraction',
            area: 'Asakusa',
          ),
          _SelectedPlaceData(
            name: 'Shibuya Crossing',
            category: 'Attraction',
            area: 'Shibuya',
          ),
          _SelectedPlaceData(
            name: 'Tsukiji Outer Market',
            category: 'Food Market',
            area: 'Tsukiji',
          ),
          _SelectedPlaceData(
            name: 'Meiji Shrine',
            category: 'Shrine',
            area: 'Harajuku',
          ),
        ];
  }

  String _getMockCategory(int index) {
    final categories = [
      'Restaurant',
      'Attraction',
      'Attraction',
      'Food Market',
      'Shrine'
    ];
    return categories[index % categories.length];
  }

  String _getMockArea(int index) {
    final areas = ['Shibuya', 'Asakusa', 'Shibuya', 'Tsukiji', 'Harajuku'];
    return areas[index % areas.length];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int get _suggestedDays {
    // Suggest days based on number of places (2-3 places per day)
    return (_selectedPlaces.length / 2.5).ceil().clamp(1, 14);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name section
                    _buildNameSection(),
                    const SizedBox(height: AppSpacing.lg),

                    // Duration section
                    _buildDurationSection(),
                    const SizedBox(height: AppSpacing.lg),

                    // Selected places section
                    _buildPlacesSection(),
                  ],
                ),
              ),
            ),

            // Footer with CTA
            _buildFooter(),
          ],
        ),
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
                  'Customize Itinerary',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_selectedPlaces.length} places selected from ${widget.cityName ?? "Tokyo"}, ${widget.country ?? "Japan"}',
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

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itinerary Name',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),

        // Suggestion row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.lightbulb,
                size: 16,
                color: Color(0xFF65A30D),
              ),
              const SizedBox(width: 8),
              Text(
                'Based on ${_selectedPlaces.length} places, we suggest $_suggestedDays days',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF65A30D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Slider row
        Row(
          children: [
            Text(
              '${_minDays.toInt()}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accent,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.accent,
                  overlayColor: AppColors.accent.withValues(alpha: 0.2),
                  trackHeight: 6,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  value: _durationDays,
                  min: _minDays,
                  max: _maxDays,
                  divisions: (_maxDays - _minDays).toInt(),
                  onChanged: (value) {
                    setState(() {
                      _durationDays = value;
                    });
                  },
                ),
              ),
            ),
            Text(
              '${_maxDays.toInt()}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        // Value display
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_durationDays.toInt()} days',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlacesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Places',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedPlaces.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _selectedPlaces.removeAt(oldIndex);
              _selectedPlaces.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            final place = _selectedPlaces[index];
            return _buildPlaceItem(key: ValueKey(place.name), place: place, index: index);
          },
        ),
      ],
    );
  }

  Widget _buildPlaceItem({
    required Key key,
    required _SelectedPlaceData place,
    required int index,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
                  '${place.category} \u00b7 ${place.area}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: const Icon(
              LucideIcons.gripVertical,
              size: 16,
              color: AppColors.textTertiary,
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
        onTap: _handleContinue,
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
                'Continue',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.arrowRight,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    context.push(AppRoutes.reviewRoute, extra: {
      'name': _nameController.text,
      'cityName': widget.cityName ?? 'Tokyo',
      'country': widget.country ?? 'Japan',
      'days': _durationDays.toInt(),
      'places': _selectedPlaces.map((p) => {
            'name': p.name,
            'category': p.category,
            'area': p.area,
          }).toList(),
    });
  }
}

class _SelectedPlaceData {
  const _SelectedPlaceData({
    required this.name,
    required this.category,
    required this.area,
  });

  final String name;
  final String category;
  final String area;
}
