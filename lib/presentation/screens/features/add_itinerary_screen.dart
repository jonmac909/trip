import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Add itinerary screen for searching and adding itinerary blocks
class AddItineraryScreen extends StatefulWidget {
  const AddItineraryScreen({super.key});

  @override
  State<AddItineraryScreen> createState() => _AddItineraryScreenState();
}

class _AddItineraryScreenState extends State<AddItineraryScreen> {
  int _selectedFilterIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'UK', 'Europe', 'Asia', 'My Saved'];

  final List<_ItineraryCard> _popularItineraries = [
    _ItineraryCard(
      id: '1',
      title: 'Classic London',
      days: 4,
      tags: 'Museums, History, Theatre',
      rating: 4.8,
      saves: '2.3k',
      imageUrl:
          'https://images.unsplash.com/photo-1765924848189-1c4e1c890962?w=400&q=80',
      isSaved: false,
    ),
    _ItineraryCard(
      id: '2',
      title: 'Cotswolds Villages',
      days: 4,
      tags: 'Countryside, Scenic drives',
      rating: 4.9,
      saves: '1.8k',
      imageUrl:
          'https://images.unsplash.com/photo-1703291544385-2e616d4fda92?w=400&q=80',
      isSaved: false,
    ),
    _ItineraryCard(
      id: '3',
      title: 'Edinburgh & Highlands',
      days: 5,
      tags: 'Castles, Nature, Whisky',
      rating: 4.7,
      saves: '1.2k',
      imageUrl:
          'https://images.unsplash.com/photo-1595275842222-bb71d4209726?w=400&q=80',
      isSaved: false,
    ),
  ];

  final List<_ItineraryCard> _savedItineraries = [
    _ItineraryCard(
      id: '4',
      title: 'My Paris Trip',
      days: 3,
      tags: 'Custom itinerary',
      rating: 0,
      saves: '',
      imageUrl:
          'https://images.unsplash.com/photo-1682261878943-d2c1382ca9a1?w=400&q=80',
      isSaved: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          // Title row
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
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Add Itinerary Block',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Search bar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.search,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search cities or itineraries...',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedFilterIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXl),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _filters[index],
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textOnAccent
                            : AppColors.textSecondary,
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

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        // Popular Itineraries section
        Text(
          'Popular Itineraries',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._popularItineraries.map(
          (itinerary) => _ItineraryListCard(
            itinerary: itinerary,
            onAdd: () => _onAddItinerary(itinerary),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Saved Itineraries section
        Text(
          'Your Saved Itineraries',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._savedItineraries.map(
          (itinerary) => _ItineraryListCard(
            itinerary: itinerary,
            onAdd: () => _onAddItinerary(itinerary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  void _onAddItinerary(_ItineraryCard itinerary) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${itinerary.title} added to trip!')),
    );
    context.pop();
  }
}

class _ItineraryListCard extends StatelessWidget {
  const _ItineraryListCard({
    required this.itinerary,
    required this.onAdd,
  });

  final _ItineraryCard itinerary;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: CachedNetworkImage(
                imageUrl: itinerary.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.shimmerBase,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.shimmerBase,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itinerary.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${itinerary.days} days \u00b7 ${itinerary.tags}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  if (itinerary.isSaved)
                    _buildSavedBadge()
                  else
                    _buildRatingRow(),
                ],
              ),
            ),
            // Add button
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.plus,
                  size: 18,
                  color: AppColors.textOnAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        const Icon(
          LucideIcons.star,
          size: 12,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '${itinerary.rating} \u00b7 ${itinerary.saves} saves',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSavedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        'Saved',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ItineraryCard {
  const _ItineraryCard({
    required this.id,
    required this.title,
    required this.days,
    required this.tags,
    required this.rating,
    required this.saves,
    required this.imageUrl,
    required this.isSaved,
  });

  final String id;
  final String title;
  final int days;
  final String tags;
  final double rating;
  final String saves;
  final String imageUrl;
  final bool isSaved;
}
