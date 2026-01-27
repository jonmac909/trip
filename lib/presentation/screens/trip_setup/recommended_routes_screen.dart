import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/navigation/app_router.dart';
import 'package:trippified/presentation/widgets/route_card.dart';

/// Screen showing recommended routes for selected countries
/// Matches design 45 (Routes - Japan) and 46 (Routes - Vietnam)
class RecommendedRoutesScreen extends StatefulWidget {
  const RecommendedRoutesScreen({
    this.countries = const [],
    super.key,
  });

  final List<String> countries;

  @override
  State<RecommendedRoutesScreen> createState() =>
      _RecommendedRoutesScreenState();
}

class _RecommendedRoutesScreenState extends State<RecommendedRoutesScreen> {
  int _currentCountryIndex = 0;
  final Map<String, int?> _selectedRoutes = {};

  List<String> get _countries =>
      widget.countries.isNotEmpty ? widget.countries : ['Japan', 'Vietnam'];

  String get _currentCountry => _countries[_currentCountryIndex];

  String get _countryFlag => _getCountryFlag(_currentCountry);

  String _getCountryFlag(String country) {
    final flags = {
      'Japan': '\u{1F1EF}\u{1F1F5}',
      'Vietnam': '\u{1F1FB}\u{1F1F3}',
      'Thailand': '\u{1F1F9}\u{1F1ED}',
      'Indonesia': '\u{1F1EE}\u{1F1E9}',
      'South Korea': '\u{1F1F0}\u{1F1F7}',
    };
    return flags[country] ?? '\u{1F30D}';
  }

  @override
  Widget build(BuildContext context) {
    final routes = _getRoutesForCountry(_currentCountry);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Routes',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  // Country badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _countryFlag,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _currentCountry,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_currentCountryIndex + 1}/${_countries.length}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Choose a pre-made route or create your own',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Routes list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: routes.length + 1, // +1 for custom route option
                itemBuilder: (context, index) {
                  if (index == routes.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _CustomRouteOption(
                        isSelected: _selectedRoutes[_currentCountry] == -1,
                        onTap: () {
                          setState(() {
                            _selectedRoutes[_currentCountry] = -1;
                          });
                        },
                      ),
                    );
                  }

                  final route = routes[index];
                  final isSelected = _selectedRoutes[_currentCountry] == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: RouteCard(
                      title: route.title,
                      imageUrl: route.imageUrl,
                      duration: route.duration,
                      cityCount: route.cityCount,
                      cities: route.cities,
                      isFeatured: route.isFeatured,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedRoutes[_currentCountry] = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

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
                  onPressed: _hasSelection ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    disabledBackgroundColor: AppColors.surfaceVariant,
                    disabledForegroundColor: AppColors.textTertiary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLastCountry
                            ? 'Create Itinerary'
                            : 'Next: $_nextCountry',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.arrowRight,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasSelection => _selectedRoutes[_currentCountry] != null;

  bool get _isLastCountry => _currentCountryIndex == _countries.length - 1;

  String get _nextCountry => _currentCountryIndex < _countries.length - 1
      ? _countries[_currentCountryIndex + 1]
      : '';

  void _onContinue() {
    if (_isLastCountry) {
      // Navigate to itinerary blocks
      context.push(AppRoutes.itineraryBuilder, extra: {
        'countries': _countries,
        'selectedRoutes': _selectedRoutes,
      });
    } else {
      setState(() {
        _currentCountryIndex++;
      });
    }
  }

  List<_RouteData> _getRoutesForCountry(String country) {
    final routes = <String, List<_RouteData>>{
      'Japan': [
        _RouteData(
          title: 'Classic Japan',
          imageUrl:
              'https://images.unsplash.com/photo-1768541089409-7d3c0bc386eb?w=400&q=80',
          duration: '12 days',
          cityCount: 3,
          cities: ['Tokyo', 'Kyoto', 'Osaka'],
          isFeatured: false,
        ),
        _RouteData(
          title: 'Tokyo Focus',
          imageUrl:
              'https://images.unsplash.com/photo-1759200408113-40c48a58d6b8?w=400&q=80',
          duration: '7 days',
          cityCount: 1,
          cities: ['Tokyo'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Kyoto & Osaka',
          imageUrl:
              'https://images.unsplash.com/photo-1736944821880-0713b1073121?w=400&q=80',
          duration: '7 days',
          cityCount: 2,
          cities: ['Kyoto', 'Osaka'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Hidden Gems',
          imageUrl:
              'https://images.unsplash.com/photo-1678959059270-9fa1ae2f87bc?w=400&q=80',
          duration: '10 days',
          cityCount: 4,
          cities: ['Kanazawa', 'Takayama'],
          isFeatured: false,
        ),
      ],
      'Vietnam': [
        _RouteData(
          title: 'Classic Vietnam',
          imageUrl:
              'https://images.unsplash.com/photo-1650166227943-d603bb37d11b?w=400&q=80',
          duration: '14 days',
          cityCount: 4,
          cities: ['Hanoi', 'Ha Long Bay', 'Hoi An', 'Ho Chi Minh City'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'North Vietnam',
          imageUrl:
              'https://images.unsplash.com/photo-1760366488897-49ed7f4d9f20?w=400&q=80',
          duration: '7 days',
          cityCount: 3,
          cities: ['Hanoi', 'Ha Long Bay', 'Sapa'],
          isFeatured: false,
        ),
        _RouteData(
          title: 'South Vietnam',
          imageUrl:
              'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=400&q=80',
          duration: '7 days',
          cityCount: 3,
          cities: ['Ho Chi Minh City', 'Mekong Delta', 'Phu Quoc'],
          isFeatured: false,
        ),
      ],
      'Thailand': [
        _RouteData(
          title: 'Thai Highlights',
          imageUrl:
              'https://images.unsplash.com/photo-1528181304800-259b08848526?w=400&q=80',
          duration: '12 days',
          cityCount: 4,
          cities: ['Bangkok', 'Chiang Mai', 'Phuket', 'Krabi'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Island Hopping',
          imageUrl:
              'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=400&q=80',
          duration: '7 days',
          cityCount: 3,
          cities: ['Phuket', 'Phi Phi', 'Krabi'],
          isFeatured: false,
        ),
      ],
    };

    return routes[country] ??
        [
          _RouteData(
            title: 'Highlights Tour',
            imageUrl:
                'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&q=80',
            duration: '7 days',
            cityCount: 3,
            cities: ['City 1', 'City 2', 'City 3'],
            isFeatured: true,
          ),
        ];
  }
}

class _RouteData {
  const _RouteData({
    required this.title,
    required this.imageUrl,
    required this.duration,
    required this.cityCount,
    required this.cities,
    required this.isFeatured,
  });

  final String title;
  final String imageUrl;
  final String duration;
  final int cityCount;
  final List<String> cities;
  final bool isFeatured;
}

/// Custom route option button
class _CustomRouteOption extends StatelessWidget {
  const _CustomRouteOption({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.plus,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Create custom route',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
