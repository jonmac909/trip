import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/widgets/app_bottom_nav.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Screen for viewing saved places within a specific city
class SavedCityDetailScreen extends StatefulWidget {
  const SavedCityDetailScreen({
    super.key,
    required this.cityId,
    this.cityName,
    this.country,
    this.placeCount,
  });

  final String cityId;
  final String? cityName;
  final String? country;
  final int? placeCount;

  @override
  State<SavedCityDetailScreen> createState() => _SavedCityDetailScreenState();
}

class _SavedCityDetailScreenState extends State<SavedCityDetailScreen> {
  String _selectedFilter = 'All';
  bool _isSelectMode = false;
  final Set<String> _selectedPlaces = {};

  // Mock data - would come from provider
  final List<_SavedPlaceData> _places = [
    const _SavedPlaceData(
      id: '1',
      name: 'Ichiran Ramen',
      category: 'Restaurant',
      area: 'Shibuya',
      source: 'TikTok',
      sourceIcon: LucideIcons.video,
      imageUrl:
          'https://images.unsplash.com/photo-1638628081165-b5afe1ecebf3?w=400',
    ),
    const _SavedPlaceData(
      id: '2',
      name: 'Senso-ji Temple',
      category: 'Attraction',
      area: 'Asakusa',
      source: 'IG',
      sourceIcon: LucideIcons.instagram,
      imageUrl:
          'https://images.unsplash.com/photo-1761141659472-4654f3b0a3fd?w=400',
    ),
    const _SavedPlaceData(
      id: '3',
      name: 'Shibuya Crossing',
      category: 'Attraction',
      area: 'Shibuya',
      source: 'Explore',
      sourceIcon: LucideIcons.compass,
      imageUrl:
          'https://images.unsplash.com/photo-1691459841469-87e136cbaa27?w=400',
    ),
    const _SavedPlaceData(
      id: '4',
      name: 'Tsukiji Outer Market',
      category: 'Food Market',
      area: 'Tsukiji',
      source: 'TikTok',
      sourceIcon: LucideIcons.video,
      imageUrl:
          'https://images.unsplash.com/photo-1759928236164-a7f6ca707b7b?w=400',
    ),
    const _SavedPlaceData(
      id: '5',
      name: 'Akihabara District',
      category: 'Shopping',
      area: 'Akihabara',
      source: 'IG',
      sourceIcon: LucideIcons.instagram,
      imageUrl:
          'https://images.unsplash.com/photo-1762356201958-d8ece711e4c3?w=400',
    ),
  ];

  final List<String> _filters = ['All', 'Food', 'Sights', 'Shopping'];

  List<_SavedPlaceData> get _filteredPlaces {
    if (_selectedFilter == 'All') return _places;
    return _places.where((place) {
      switch (_selectedFilter) {
        case 'Food':
          return place.category.contains('Restaurant') ||
              place.category.contains('Food');
        case 'Sights':
          return place.category.contains('Attraction') ||
              place.category.contains('Temple') ||
              place.category.contains('Shrine');
        case 'Shopping':
          return place.category.contains('Shopping');
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayCityName = widget.cityName ?? 'Tokyo';
    final displayCountry = widget.country ?? 'Japan';
    final displayPlaceCount = widget.placeCount ?? _places.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(displayCityName, displayCountry, displayPlaceCount),

            // Search and filters
            _buildSearchAndFilters(displayCityName),

            // Places list
            Expanded(
              child: _buildPlacesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            context.go(AppRoutes.home);
          } else if (index == 3) {
            context.go(AppRoutes.profile);
          }
        },
      ),
    );
  }

  Widget _buildHeader(String cityName, String country, int placeCount) {
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
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
                  '$cityName, $country',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$placeCount places saved',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Select button
          GestureDetector(
            onTap: () {
              setState(() {
                _isSelectMode = !_isSelectMode;
                if (!_isSelectMode) {
                  _selectedPlaces.clear();
                }
              });
            },
            child: Text(
              _isSelectMode ? 'Done' : 'Select',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(String cityName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.search,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Search in $cityName...',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.background
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _filteredPlaces.length + 1, // +1 for CTA
      itemBuilder: (context, index) {
        if (index == _filteredPlaces.length) {
          return _buildCreateTripCta();
        }

        final place = _filteredPlaces[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: Key(place.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmDelete(context),
            onDismissed: (_) {
              setState(() {
                _places.removeWhere((p) => p.id == place.id);
              });
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.trash2,
                color: Colors.white,
                size: 22,
              ),
            ),
            child: _buildPlaceCard(place),
          ),
        );
      },
    );
  }

  Widget _buildPlaceCard(_SavedPlaceData place) {
    final isSelected = _selectedPlaces.contains(place.id);

    return GestureDetector(
      onTap: () {
        if (_isSelectMode) {
          setState(() {
            if (isSelected) {
              _selectedPlaces.remove(place.id);
            } else {
              _selectedPlaces.add(place.id);
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Selection circle (when in select mode)
            if (_isSelectMode) ...[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderDark,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        LucideIcons.check,
                        size: 14,
                        color: AppColors.background,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
            ],

            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 50,
                height: 50,
                child: CachedNetworkImage(
                  imageUrl: place.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.shimmerBase),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.shimmerBase),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
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
                    '${place.category} \u2022 ${place.area}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Source badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    place.sourceIcon,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    place.source,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
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
    );
  }

  Widget _buildCreateTripCta() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: _handleCreateTrip,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.sparkles,
                size: 20,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'Create a Trip',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Delete',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this place?',
          style: GoogleFonts.dmSans(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreateTrip() {
    // Navigate to customize itinerary with selected places
    final selectedPlaces = _isSelectMode && _selectedPlaces.isNotEmpty
        ? _places.where((p) => _selectedPlaces.contains(p.id)).toList()
        : _places;

    context.push(AppRoutes.customizeItinerary.replaceFirst(':id', widget.cityId), extra: {
      'cityName': widget.cityName ?? 'Tokyo',
      'country': widget.country ?? 'Japan',
      'places': selectedPlaces.map((p) => p.name).toList(),
    });
  }
}

class _SavedPlaceData {
  const _SavedPlaceData({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.source,
    required this.sourceIcon,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final String area;
  final String source;
  final IconData sourceIcon;
  final String imageUrl;
}
