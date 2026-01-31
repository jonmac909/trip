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
  const RecommendedRoutesScreen({this.countries = const [], super.key});

  final List<String> countries;

  @override
  State<RecommendedRoutesScreen> createState() =>
      _RecommendedRoutesScreenState();
}

class _RecommendedRoutesScreenState extends State<RecommendedRoutesScreen> {
  int _currentCountryIndex = 0;
  final Map<String, int?> _selectedRoutes = {};
  final Map<String, List<String>> _customRouteCities = {};

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
                    // Add extra bottom padding for the fixed CTA button
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: _CustomRouteOption(
                        isSelected: _selectedRoutes[_currentCountry] == -1,
                        selectedCities:
                            _customRouteCities[_currentCountry] ?? [],
                        onTap: () => _showCustomRouteBuilder(),
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

            // Bottom CTA - fixed at bottom
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
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
                        const Icon(LucideIcons.arrowRight, size: 20),
                      ],
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

  bool get _hasSelection => _selectedRoutes[_currentCountry] != null;

  bool get _isLastCountry => _currentCountryIndex == _countries.length - 1;

  String get _nextCountry => _currentCountryIndex < _countries.length - 1
      ? _countries[_currentCountryIndex + 1]
      : '';

  void _onContinue() {
    if (_isLastCountry) {
      // Navigate to itinerary blocks
      context.push(
        AppRoutes.itineraryBuilder,
        extra: {
          'countries': _countries,
          'selectedRoutes': _selectedRoutes,
          'customRouteCities': _customRouteCities,
          'routeDurations': _buildRouteDurations(),
        },
      );
    } else {
      setState(() {
        _currentCountryIndex++;
      });
    }
  }

  /// Build a map of country -> duration in days for each selected route
  Map<String, int> _buildRouteDurations() {
    final durations = <String, int>{};
    for (final country in _countries) {
      final routeIndex = _selectedRoutes[country];
      if (routeIndex == null) continue;

      if (routeIndex == -1) {
        // Custom route - estimate 2 days per city, min 3, max 14
        final cities = _customRouteCities[country] ?? [];
        durations[country] = (cities.length * 2).clamp(3, 14);
      } else {
        // Pre-made route - get duration from route data
        final routes = _getRoutesForCountry(country);
        if (routeIndex >= 0 && routeIndex < routes.length) {
          durations[country] = _parseDuration(routes[routeIndex].duration);
        }
      }
    }
    return durations;
  }

  /// Parse duration string like "12 days" -> 12
  int _parseDuration(String duration) {
    final match = RegExp(r'(\d+)').firstMatch(duration);
    return match != null ? int.parse(match.group(1)!) : 7;
  }

  Future<void> _showCustomRouteBuilder() async {
    final availableCities = _getAvailableCitiesForCountry(_currentCountry);
    final currentSelection = List<String>.from(
      _customRouteCities[_currentCountry] ?? [],
    );

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CustomRouteBuilderSheet(
        country: _currentCountry,
        availableCities: availableCities,
        initialSelection: currentSelection,
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _customRouteCities[_currentCountry] = result;
        _selectedRoutes[_currentCountry] = -1;
      });
    }
  }

  List<String> _getAvailableCitiesForCountry(String country) {
    final cities = <String, List<String>>{
      'Japan': [
        'Tokyo',
        'Kyoto',
        'Osaka',
        'Nara',
        'Hiroshima',
        'Kanazawa',
        'Takayama',
        'Hakone',
        'Nikko',
        'Fukuoka',
      ],
      'Vietnam': [
        'Hanoi',
        'Ho Chi Minh City',
        'Ha Long Bay',
        'Hoi An',
        'Da Nang',
        'Sapa',
        'Hue',
        'Nha Trang',
        'Phu Quoc',
        'Mekong Delta',
      ],
      'Thailand': [
        'Bangkok',
        'Chiang Mai',
        'Phuket',
        'Krabi',
        'Phi Phi',
        'Koh Samui',
        'Pattaya',
        'Ayutthaya',
        'Chiang Rai',
        'Pai',
      ],
      'Indonesia': [
        'Bali',
        'Jakarta',
        'Yogyakarta',
        'Lombok',
        'Ubud',
        'Seminyak',
        'Komodo',
        'Raja Ampat',
        'Bandung',
        'Surabaya',
      ],
      'South Korea': [
        'Seoul',
        'Busan',
        'Jeju',
        'Gyeongju',
        'Incheon',
        'Daegu',
        'Jeonju',
        'Sokcho',
        'Suwon',
        'Gangneung',
      ],
      'United States': [
        'New York',
        'Los Angeles',
        'San Francisco',
        'Miami',
        'Honolulu',
        'Las Vegas',
        'Chicago',
        'New Orleans',
        'San Diego',
        'Seattle',
        'Boston',
        'Washington DC',
        'Austin',
        'Nashville',
        'Denver',
      ],
      'Italy': [
        'Rome',
        'Florence',
        'Venice',
        'Milan',
        'Amalfi Coast',
        'Cinque Terre',
        'Naples',
        'Sicily',
        'Bologna',
        'Tuscany',
      ],
      'France': [
        'Paris',
        'Nice',
        'Lyon',
        'Marseille',
        'Bordeaux',
        'Strasbourg',
        'Provence',
        'Mont Saint-Michel',
        'Chamonix',
        'Cannes',
      ],
      'Spain': [
        'Barcelona',
        'Madrid',
        'Seville',
        'Valencia',
        'Granada',
        'San Sebastian',
        'Mallorca',
        'Ibiza',
        'Bilbao',
        'Toledo',
      ],
      'Greece': [
        'Athens',
        'Santorini',
        'Mykonos',
        'Crete',
        'Rhodes',
        'Corfu',
        'Thessaloniki',
        'Meteora',
        'Delphi',
        'Zakynthos',
      ],
      'Portugal': [
        'Lisbon',
        'Porto',
        'Algarve',
        'Sintra',
        'Madeira',
        'Azores',
        'Coimbra',
        'Évora',
        'Cascais',
        'Lagos',
      ],
      'United Kingdom': [
        'London',
        'Edinburgh',
        'Manchester',
        'Liverpool',
        'Bath',
        'Oxford',
        'Cambridge',
        'York',
        'Brighton',
        'Glasgow',
      ],
      'Germany': [
        'Berlin',
        'Munich',
        'Hamburg',
        'Frankfurt',
        'Cologne',
        'Dresden',
        'Heidelberg',
        'Nuremberg',
        'Black Forest',
        'Neuschwanstein',
      ],
      'Australia': [
        'Sydney',
        'Melbourne',
        'Brisbane',
        'Perth',
        'Gold Coast',
        'Cairns',
        'Great Barrier Reef',
        'Tasmania',
        'Adelaide',
        'Uluru',
      ],
      'New Zealand': [
        'Auckland',
        'Queenstown',
        'Wellington',
        'Rotorua',
        'Christchurch',
        'Milford Sound',
        'Hobbiton',
        'Bay of Islands',
        'Wanaka',
        'Napier',
      ],
      'Mexico': [
        'Mexico City',
        'Cancun',
        'Playa del Carmen',
        'Tulum',
        'Oaxaca',
        'Puerto Vallarta',
        'Guadalajara',
        'San Miguel de Allende',
        'Los Cabos',
        'Merida',
      ],
      'Canada': [
        'Vancouver',
        'Toronto',
        'Montreal',
        'Banff',
        'Quebec City',
        'Victoria',
        'Whistler',
        'Calgary',
        'Ottawa',
        'Niagara Falls',
      ],
      'Brazil': [
        'Rio de Janeiro',
        'São Paulo',
        'Salvador',
        'Iguazu Falls',
        'Florianópolis',
        'Brasília',
        'Paraty',
        'Fernando de Noronha',
        'Manaus',
        'Recife',
      ],
      'Peru': [
        'Lima',
        'Cusco',
        'Machu Picchu',
        'Sacred Valley',
        'Arequipa',
        'Lake Titicaca',
        'Nazca',
        'Amazon Rainforest',
        'Huacachina',
        'Colca Canyon',
      ],
      'Argentina': [
        'Buenos Aires',
        'Mendoza',
        'Patagonia',
        'Iguazu Falls',
        'Bariloche',
        'Ushuaia',
        'Salta',
        'Córdoba',
        'El Calafate',
        'Perito Moreno',
      ],
    };
    return cities[country] ?? [];
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
      'United States': [
        _RouteData(
          title: 'West Coast Classic',
          imageUrl:
              'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=400&q=80',
          duration: '10 days',
          cityCount: 3,
          cities: ['Los Angeles', 'San Francisco', 'Las Vegas'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'East Coast Explorer',
          imageUrl:
              'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400&q=80',
          duration: '10 days',
          cityCount: 4,
          cities: ['New York', 'Boston', 'Washington DC', 'Philadelphia'],
          isFeatured: false,
        ),
        _RouteData(
          title: 'Hawaii Paradise',
          imageUrl:
              'https://images.unsplash.com/photo-1507876466758-bc54f384809c?w=400&q=80',
          duration: '7 days',
          cityCount: 2,
          cities: ['Honolulu', 'Maui'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Florida & Miami',
          imageUrl:
              'https://images.unsplash.com/photo-1533106497176-45ae19e68ba2?w=400&q=80',
          duration: '7 days',
          cityCount: 3,
          cities: ['Miami', 'Orlando', 'Key West'],
          isFeatured: false,
        ),
      ],
      'Italy': [
        _RouteData(
          title: 'Classic Italy',
          imageUrl:
              'https://images.unsplash.com/photo-1515859005217-8a1f08870f59?w=400&q=80',
          duration: '10 days',
          cityCount: 3,
          cities: ['Rome', 'Florence', 'Venice'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Amalfi & Naples',
          imageUrl:
              'https://images.unsplash.com/photo-1534008897995-27a23e859048?w=400&q=80',
          duration: '7 days',
          cityCount: 3,
          cities: ['Naples', 'Amalfi Coast', 'Capri'],
          isFeatured: false,
        ),
      ],
      'France': [
        _RouteData(
          title: 'Paris & Beyond',
          imageUrl:
              'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400&q=80',
          duration: '10 days',
          cityCount: 3,
          cities: ['Paris', 'Lyon', 'Nice'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'French Riviera',
          imageUrl:
              'https://images.unsplash.com/photo-1533104816931-20fa691ff6ca?w=400&q=80',
          duration: '7 days',
          cityCount: 3,
          cities: ['Nice', 'Monaco', 'Cannes'],
          isFeatured: false,
        ),
      ],
      'Spain': [
        _RouteData(
          title: 'Spanish Highlights',
          imageUrl:
              'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=400&q=80',
          duration: '10 days',
          cityCount: 3,
          cities: ['Barcelona', 'Madrid', 'Seville'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Barcelona & Coast',
          imageUrl:
              'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=400&q=80',
          duration: '7 days',
          cityCount: 2,
          cities: ['Barcelona', 'Valencia'],
          isFeatured: false,
        ),
      ],
      'Greece': [
        _RouteData(
          title: 'Greek Islands',
          imageUrl:
              'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=400&q=80',
          duration: '10 days',
          cityCount: 3,
          cities: ['Athens', 'Santorini', 'Mykonos'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Athens & Mainland',
          imageUrl:
              'https://images.unsplash.com/photo-1555993539-1732b0258235?w=400&q=80',
          duration: '7 days',
          cityCount: 3,
          cities: ['Athens', 'Delphi', 'Meteora'],
          isFeatured: false,
        ),
      ],
      'Indonesia': [
        _RouteData(
          title: 'Bali Explorer',
          imageUrl:
              'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400&q=80',
          duration: '10 days',
          cityCount: 3,
          cities: ['Ubud', 'Seminyak', 'Uluwatu'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Bali & Lombok',
          imageUrl:
              'https://images.unsplash.com/photo-1570789210967-2cac24f00b92?w=400&q=80',
          duration: '12 days',
          cityCount: 2,
          cities: ['Bali', 'Lombok'],
          isFeatured: false,
        ),
      ],
      'South Korea': [
        _RouteData(
          title: 'Korean Classic',
          imageUrl:
              'https://images.unsplash.com/photo-1538485399081-7191377e8241?w=400&q=80',
          duration: '10 days',
          cityCount: 3,
          cities: ['Seoul', 'Busan', 'Jeju'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Seoul Deep Dive',
          imageUrl:
              'https://images.unsplash.com/photo-1517154421773-0529f29ea451?w=400&q=80',
          duration: '7 days',
          cityCount: 1,
          cities: ['Seoul'],
          isFeatured: false,
        ),
      ],
      'Australia': [
        _RouteData(
          title: 'East Coast Australia',
          imageUrl:
              'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400&q=80',
          duration: '14 days',
          cityCount: 3,
          cities: ['Sydney', 'Melbourne', 'Brisbane'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Sydney & Surrounds',
          imageUrl:
              'https://images.unsplash.com/photo-1523482580672-f109ba8cb9be?w=400&q=80',
          duration: '7 days',
          cityCount: 1,
          cities: ['Sydney'],
          isFeatured: false,
        ),
      ],
      'Mexico': [
        _RouteData(
          title: 'Riviera Maya',
          imageUrl:
              'https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?w=400&q=80',
          duration: '7 days',
          cityCount: 3,
          cities: ['Cancun', 'Playa del Carmen', 'Tulum'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Mexico City & Oaxaca',
          imageUrl:
              'https://images.unsplash.com/photo-1518659526054-e36c6c6e5e5d?w=400&q=80',
          duration: '7 days',
          cityCount: 2,
          cities: ['Mexico City', 'Oaxaca'],
          isFeatured: false,
        ),
      ],
      'United Kingdom': [
        _RouteData(
          title: 'British Highlights',
          imageUrl:
              'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400&q=80',
          duration: '10 days',
          cityCount: 3,
          cities: ['London', 'Edinburgh', 'Bath'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'London & Oxford',
          imageUrl:
              'https://images.unsplash.com/photo-1486299267070-83823f5448dd?w=400&q=80',
          duration: '7 days',
          cityCount: 2,
          cities: ['London', 'Oxford'],
          isFeatured: false,
        ),
      ],
      'Canada': [
        _RouteData(
          title: 'Western Canada',
          imageUrl:
              'https://images.unsplash.com/photo-1503614472-8c93d56e92ce?w=400&q=80',
          duration: '10 days',
          cityCount: 3,
          cities: ['Vancouver', 'Banff', 'Victoria'],
          isFeatured: true,
        ),
        _RouteData(
          title: 'Toronto & Montreal',
          imageUrl:
              'https://images.unsplash.com/photo-1517935706615-2717063c2225?w=400&q=80',
          duration: '7 days',
          cityCount: 2,
          cities: ['Toronto', 'Montreal'],
          isFeatured: false,
        ),
      ],
    };

    // For countries without specific routes, generate from available cities
    if (routes[country] != null) {
      return routes[country]!;
    }

    // Get cities for this country to build a default route
    final cities = _getAvailableCitiesForCountry(country);
    if (cities.isEmpty) {
      return [
        _RouteData(
          title: 'Highlights Tour',
          imageUrl:
              'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&q=80',
          duration: '7 days',
          cityCount: 3,
          cities: [country],
          isFeatured: true,
        ),
      ];
    }

    // Build routes from available cities
    final topCities = cities.take(3).toList();
    return [
      _RouteData(
        title: 'Highlights Tour',
        imageUrl:
            'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&q=80',
        duration: '7 days',
        cityCount: topCities.length,
        cities: topCities,
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
    required this.selectedCities,
    required this.onTap,
  });

  final bool isSelected;
  final List<String> selectedCities;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCities = selectedCities.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: hasCities
            ? const EdgeInsets.all(14)
            : const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: hasCities
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Custom Route',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Edit',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        LucideIcons.pencil,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (int i = 0; i < selectedCities.length; i++) ...[
                        if (i > 0)
                          const Icon(
                            LucideIcons.arrowRight,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selectedCities[i],
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
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

/// Bottom sheet for building a custom route
class _CustomRouteBuilderSheet extends StatefulWidget {
  const _CustomRouteBuilderSheet({
    required this.country,
    required this.availableCities,
    required this.initialSelection,
  });

  final String country;
  final List<String> availableCities;
  final List<String> initialSelection;

  @override
  State<_CustomRouteBuilderSheet> createState() =>
      _CustomRouteBuilderSheetState();
}

class _CustomRouteBuilderSheetState extends State<_CustomRouteBuilderSheet> {
  late List<String> _selectedCities;
  late List<String> _allCities;
  final _customCityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCities = List.from(widget.initialSelection);
    _allCities = List.from(widget.availableCities);
  }

  @override
  void dispose() {
    _customCityController.dispose();
    super.dispose();
  }

  void _toggleCity(String city) {
    setState(() {
      if (_selectedCities.contains(city)) {
        _selectedCities.remove(city);
      } else {
        _selectedCities.add(city);
      }
    });
  }

  void _addCustomCity() {
    final cityName = _customCityController.text.trim();
    if (cityName.isEmpty) return;

    // Check if city already exists (case-insensitive)
    final exists = _allCities.any(
      (c) => c.toLowerCase() == cityName.toLowerCase(),
    );

    setState(() {
      if (!exists) {
        _allCities.add(cityName);
      }
      if (!_selectedCities.contains(cityName)) {
        _selectedCities.add(cityName);
      }
      _customCityController.clear();
    });
  }

  void _reorderCity(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final city = _selectedCities.removeAt(oldIndex);
      _selectedCities.insert(newIndex, city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Build Your Route',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select cities in ${widget.country}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedCities.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedCities.length} selected',
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
            // Selected cities (reorderable)
            if (_selectedCities.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your route order (drag to reorder)',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: _selectedCities.length,
                      onReorder: _reorderCity,
                      itemBuilder: (context, index) {
                        final city = _selectedCities[index];
                        return ReorderableDragStartListener(
                          key: ValueKey(city),
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    city,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.gripVertical,
                                  size: 18,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1, color: AppColors.border),
            ),
            const SizedBox(height: 12),
            // Add custom city input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _customCityController,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a custom city...',
                          hintStyle: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _addCustomCity(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addCustomCity,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.plus,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Available cities
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available cities',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allCities.map((city) {
                      final isSelected = _selectedCities.contains(city);
                      return GestureDetector(
                        onTap: () => _toggleCity(city),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(
                                  LucideIcons.check,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                city,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            // Bottom CTA
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
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedCities.isNotEmpty
                      ? () => Navigator.pop(context, _selectedCities)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    disabledBackgroundColor: AppColors.surfaceVariant,
                    disabledForegroundColor: AppColors.textTertiary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    _selectedCities.isEmpty
                        ? 'Select at least one city'
                        : 'Save Route (${_selectedCities.length} cities)',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
