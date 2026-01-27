import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Destination detail screen with Overview, Cities, Itineraries, and History tabs
class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({
    super.key,
    required this.destinationId,
  });

  final String destinationId;

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMapView = true;
  int _selectedRegionIndex = 0;

  // Mock data - replace with actual data fetching
  final _destination = _MockDestination(
    name: 'Thailand',
    nativeText: '\u0e02\u0e2d\u0e1a\u0e04\u0e38\u0e13\u0e04\u0e23\u0e31\u0e1a/\u0e04\u0e48\u0e30',
    pronunciation: '"khob khun krap/ka"',
    imageUrl:
        'https://images.unsplash.com/photo-1768746845614-e757e075007b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w4NDM0ODN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjkyNzM4MjZ8&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Thailand is a Southeast Asian country known for tropical beaches, opulent royal palaces, ancient ruins and ornate temples displaying figures of Buddha.',
    tags: [
      'Beaches',
      'Street Food',
      'Temples',
      'Islands',
      'Wellness',
    ],
    phrases: [
      _Phrase('Hello', '\u0e2a\u0e27\u0e31\u0e2a\u0e14\u0e35', '"sa-wat-dee krap/ka"'),
      _Phrase('Thank you', '\u0e02\u0e2d\u0e1a\u0e04\u0e38\u0e13', '"khob khun krap/ka"'),
    ],
    alerts: [
      _Alert(LucideIcons.sun, 'Best time: Nov - Feb (cool & dry)'),
      _Alert(LucideIcons.cloudRain, 'Monsoon season: Jun - Oct'),
      _Alert(LucideIcons.fileText, 'Visa-free for 30 days (most countries)'),
      _Alert(LucideIcons.shieldCheck, 'Generally safe for tourists'),
    ],
  );

  final _regions = [
    _Region('Northern', 6, const Color(0xFFF87171)),
    _Region('Central', 5, const Color(0xFF6B7280)),
    _Region('Eastern', 3, const Color(0xFFFB923C)),
    _Region('Gulf Islands', 3, const Color(0xFF4ADE80)),
    _Region('Andaman', 7, const Color(0xFF38BDF8)),
  ];

  final _cities = [
    _City('Bangkok', 'Capital', 'Temples, street food, nightlife',
        'https://images.unsplash.com/photo-1644085237808-c2412ddea427?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400'),
    _City('Chiang Mai', 'Northern', 'Mountains, culture, elephants',
        'https://images.unsplash.com/photo-1721038469269-17abe535770e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400'),
    _City('Phuket', 'Andaman', 'Beaches, islands, resorts',
        'https://images.unsplash.com/photo-1767175937036-4c840d326b8f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400'),
    _City('Krabi', 'Andaman', 'Cliffs, kayaking, islands',
        'https://images.unsplash.com/photo-1735797745671-e9a9ae2516cc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400'),
    _City('Ayutthaya', 'Central', 'UNESCO ruins, ancient temples',
        'https://images.unsplash.com/photo-1768147097186-d5c4e03dfb11?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400'),
  ];

  final _itineraries = [
    _Itinerary(
      'Classic Thailand',
      '14 days',
      'Bangkok \u2192 Chiang Mai \u2192 Phuket \u2192 Krabi',
      ['Culture', 'Beach', 'Adventure'],
      'https://images.unsplash.com/photo-1713862022101-0945a30f2398?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
    ),
    _Itinerary(
      'Beach Hopper',
      '7 days',
      'Phuket \u2192 Phi Phi \u2192 Krabi \u2192 Koh Lanta',
      ['Beach', 'Relaxation'],
      'https://images.unsplash.com/photo-1551418843-01c6b62e864d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
    ),
    _Itinerary(
      'Northern Explorer',
      '10 days',
      'Bangkok \u2192 Ayutthaya \u2192 Chiang Mai \u2192 Pai',
      ['Culture', 'History'],
      'https://images.unsplash.com/photo-1682826556359-dfec7215b1f2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
    ),
  ];

  final _historyTimeline = [
    _TimelineEvent('1238', 'Sukhothai Kingdom Founded',
        'First Thai kingdom established, considered the birthplace of Thai culture, art, and language.'),
    _TimelineEvent('1351', 'Ayutthaya Kingdom Rises',
        'Golden age of Thai civilization. Major trading hub connecting East and West.'),
    _TimelineEvent('1782', 'Chakri Dynasty Begins',
        'Bangkok founded as capital. Current royal dynasty established, continuing to present day.'),
    _TimelineEvent('1939', 'Siam Becomes Thailand',
        "Country renamed from Siam to Thailand, meaning 'Land of the Free'."),
    _TimelineEvent('Today', 'Modern Thailand',
        "Constitutional monarchy, major tourist destination, and Southeast Asia's second-largest economy."),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildHeroSection(),
                SliverToBoxAdapter(
                  child: _buildTabBar(),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildCitiesTab(),
                      _buildItinerariesTab(),
                      _buildHistoryTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppBottomNav(
            currentIndex: 1,
            onTap: (index) {
              if (index != 1) {
                context.go(AppRoutes.home);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          // Hero image
          CachedNetworkImage(
            imageUrl: _destination.imageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 220,
              color: AppColors.shimmerBase,
            ),
            errorWidget: (context, url, error) => Container(
              height: 220,
              color: AppColors.shimmerBase,
              child: const Icon(LucideIcons.image, color: AppColors.textTertiary),
            ),
          ),
          // Content overlay
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                _buildBackButton(),
                // Title and subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _destination.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_destination.nativeText} \u00b7 ${_destination.pronunciation}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.pop(),
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
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Cities'),
          Tab(text: 'Itineraries'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            _destination.description,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Quick glance
          _buildSectionTitle('Quick glance'),
          const SizedBox(height: 12),
          _buildTags(),
          const SizedBox(height: 16),
          // Useful phrases
          _buildSectionTitle('Useful phrases'),
          const SizedBox(height: 8),
          _buildPhrases(),
          const SizedBox(height: 16),
          // Alerts
          _buildSectionTitle('Alerts'),
          const SizedBox(height: 12),
          _buildAlerts(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTags() {
    final tagEmojis = [
      '\ud83c\udfd6\ufe0f', // Beaches
      '\ud83c\udf5c', // Street Food
      '\ud83d\uded5', // Temples
      '\ud83c\udf34', // Islands
      '\ud83d\udc86', // Wellness
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: List.generate(_destination.tags.length, (index) {
        final emoji = index < tagEmojis.length ? tagEmojis[index] : '';
        return Text(
          '$emoji ${_destination.tags[index]}',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.secondary,
          ),
        );
      }),
    );
  }

  Widget _buildPhrases() {
    return Column(
      children: _destination.phrases.map((phrase) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                phrase.english,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${phrase.native} \u00b7 ${phrase.pronunciation}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAlerts() {
    return Column(
      children: _destination.alerts.map((alert) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  alert.icon,
                  size: 18,
                  color: const Color(0xFF5B21B6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    alert.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5B21B6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle row
          _buildViewToggle(),
          const SizedBox(height: 16),
          if (_isMapView) ...[
            // Map view
            _buildMapPlaceholder(),
            const SizedBox(height: 16),
            _buildRegionTabs(),
            const SizedBox(height: 16),
            _buildRegionCities(),
          ] else ...[
            // List view
            _buildCityList(),
          ],
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              _isMapView ? LucideIcons.map : LucideIcons.list,
              size: 16,
              color: _isMapView ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              _isMapView ? 'Map view' : 'List view',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _isMapView ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() => _isMapView = !_isMapView),
          child: Container(
            width: 44,
            height: 24,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _isMapView ? AppColors.accent : AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  _isMapView ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.map,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              'Map placeholder',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionTabs() {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children: List.generate(_regions.length, (index) {
        final region = _regions[index];
        final isSelected = index == _selectedRegionIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedRegionIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? region.color : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : region.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${region.name} (${region.count})',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color:
                        isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRegionCities() {
    // Show first 4 cities for the selected region
    final citiesToShow = _cities.take(4).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: citiesToShow.map((city) {
          return GestureDetector(
            onTap: () {
              context.push('/explore/city/${city.name.hashCode}', extra: {
                'cityName': city.name,
                'region': city.region,
                'imageUrl': city.imageUrl,
              });
            },
            child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: CachedNetworkImage(
                    imageUrl: city.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.shimmerBase,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.shimmerBase,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  city.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCityList() {
    return Column(
      children: _cities.map((city) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CityListCard(city: city),
        );
      }).toList(),
    );
  }

  Widget _buildItinerariesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _itineraries.length,
      itemBuilder: (context, index) {
        final itinerary = _itineraries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ItineraryCard(itinerary: itinerary),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The only Southeast Asian nation never colonized. From ancient Sukhothai to the modern Chakri dynasty.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_historyTimeline.length, (index) {
        final event = _historyTimeline[index];
        final isLast = index == _historyTimeline.length - 1;
        return _TimelineEventWidget(event: event, isLast: isLast);
      }),
    );
  }
}

/// City list card for list view
class _CityListCard extends StatelessWidget {
  const _CityListCard({required this.city});

  final _City city;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/explore/city/${city.name.hashCode}', extra: {
          'cityName': city.name,
          'region': city.region,
          'imageUrl': city.imageUrl,
        });
      },
      child: Container(
      height: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: city.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 64,
                height: 64,
                color: AppColors.shimmerBase,
              ),
              errorWidget: (context, url, error) => Container(
                width: 64,
                height: 64,
                color: AppColors.shimmerBase,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  city.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${city.region} \u2022 ${city.highlights}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
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

/// Itinerary card for itineraries tab
class _ItineraryCard extends StatelessWidget {
  const _ItineraryCard({required this.itinerary});

  final _Itinerary itinerary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/explore/itinerary/${itinerary.title.hashCode}');
      },
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl - 1),
            ),
            child: CachedNetworkImage(
              imageUrl: itinerary.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 120,
                color: AppColors.shimmerBase,
              ),
              errorWidget: (context, url, error) => Container(
                height: 120,
                color: AppColors.shimmerBase,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itinerary.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${itinerary.duration} \u00b7 ${itinerary.route}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: itinerary.tags.map((tag) {
                    return _ItineraryTag(tag: tag);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Tag chip for itineraries
class _ItineraryTag extends StatelessWidget {
  const _ItineraryTag({required this.tag});

  final String tag;

  Color get _tagColor {
    switch (tag.toLowerCase()) {
      case 'beach':
        return const Color(0xFF1976D2);
      case 'adventure':
        return const Color(0xFFE65100);
      case 'history':
        return const Color(0xFF7B1FA2);
      case 'culture':
      case 'relaxation':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _tagColor == AppColors.primary
            ? Colors.white
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: _tagColor,
        ),
      ),
    );
  }
}

/// Timeline event widget for history tab
class _TimelineEventWidget extends StatelessWidget {
  const _TimelineEventWidget({
    required this.event,
    required this.isLast,
  });

  final _TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot and line column
        SizedBox(
          width: 20,
          child: Column(
            children: [
              // Dot
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Line
              if (!isLast)
                Container(
                  width: 2,
                  height: 50,
                  color: AppColors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.year,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Mock data classes
class _MockDestination {
  _MockDestination({
    required this.name,
    required this.nativeText,
    required this.pronunciation,
    required this.imageUrl,
    required this.description,
    required this.tags,
    required this.phrases,
    required this.alerts,
  });

  final String name;
  final String nativeText;
  final String pronunciation;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final List<_Phrase> phrases;
  final List<_Alert> alerts;
}

class _Phrase {
  _Phrase(this.english, this.native, this.pronunciation);
  final String english;
  final String native;
  final String pronunciation;
}

class _Alert {
  _Alert(this.icon, this.text);
  final IconData icon;
  final String text;
}

class _Region {
  _Region(this.name, this.count, this.color);
  final String name;
  final int count;
  final Color color;
}

class _City {
  _City(this.name, this.region, this.highlights, this.imageUrl);
  final String name;
  final String region;
  final String highlights;
  final String imageUrl;
}

class _Itinerary {
  _Itinerary(
      this.title, this.duration, this.route, this.tags, this.imageUrl);
  final String title;
  final String duration;
  final String route;
  final List<String> tags;
  final String imageUrl;
}

class _TimelineEvent {
  _TimelineEvent(this.year, this.title, this.description);
  final String year;
  final String title;
  final String description;
}
