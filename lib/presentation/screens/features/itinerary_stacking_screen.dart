import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Itinerary stacking screen for combining multiple itinerary blocks
class ItineraryStackingScreen extends StatefulWidget {
  const ItineraryStackingScreen({super.key});

  @override
  State<ItineraryStackingScreen> createState() =>
      _ItineraryStackingScreenState();
}

class _ItineraryStackingScreenState extends State<ItineraryStackingScreen> {
  // Itinerary blocks - populated from navigation params
  final List<_ItineraryBlock> _blocks = [];

  int get _totalDays => _blocks.fold(0, (sum, block) => sum + block.days);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBlocksList()),
            _buildBottomButtons(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    'Build Your Trip',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
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
          const SizedBox(height: AppSpacing.md),
          Text(
            'Stack itinerary blocks to create your perfect trip',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlocksList() {
    // Group blocks by country
    final ukBlocks =
        _blocks.where((b) => b.countryFlag == 'GB').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        // UK Section
        if (ukBlocks.isNotEmpty) ...[
          _buildCountryHeader('United Kingdom'),
          const SizedBox(height: AppSpacing.sm),
          ...ukBlocks.asMap().entries.map((entry) {
            final index = entry.key;
            final block = entry.value;
            return Column(
              children: [
                _ItineraryBlockCard(
                  block: block,
                  onTap: () => _onBlockTap(block),
                ),
                if (index < ukBlocks.length - 1) ...[
                  _buildConnector(icon: LucideIcons.car, duration: '2 hr drive'),
                ],
              ],
            );
          }),
        ],
        const SizedBox(height: AppSpacing.md),
        _buildAddBlockButton(),
      ],
    );
  }

  Widget _buildCountryHeader(String country) {
    return Row(
      children: [
        const Icon(
          LucideIcons.gripVertical,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          country,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required IconData icon, required String duration}) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 0, bottom: 0),
      child: Row(
        children: [
          Container(
            width: 1,
            height: 20,
            color: AppColors.border,
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            duration,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBlockButton() {
    return GestureDetector(
      onTap: _onAddBlock,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.borderDark, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.plus,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Add another itinerary block',
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

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          // Save button (outlined)
          GestureDetector(
            onTap: _onSaveToTrips,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                'Save to My Trips',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Open Day Builder button (filled)
          GestureDetector(
            onTap: _onOpenDayBuilder,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              alignment: Alignment.center,
              child: Text(
                'Open Day Builder',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBlockTap(_ItineraryBlock block) {
    // Navigate to block detail
  }

  void _onAddBlock() {
    context.push('/features/add-itinerary');
  }

  void _onSaveToTrips() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip saved!')),
    );
  }

  void _onOpenDayBuilder() {
    if (_blocks.isNotEmpty) {
      context.push(
        '/trip/trip-id/day/${_blocks.first.city}',
        extra: {
          'days': _blocks.first.days,
          'tripCities': _blocks
              .map((b) => {'cityName': b.city, 'days': b.days})
              .toList(),
        },
      );
    }
  }
}

class _ItineraryBlockCard extends StatelessWidget {
  const _ItineraryBlockCard({
    required this.block,
    required this.onTap,
  });

  final _ItineraryBlock block;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: block.isSelected ? AppColors.primary : AppColors.border,
            width: block.isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.gripVertical,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.city,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${block.days} days \u00b7 ${block.theme}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
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

class _ItineraryBlock {
  const _ItineraryBlock({
    required this.id,
    required this.city,
    required this.country,
    required this.countryFlag,
    required this.days,
    required this.theme,
    this.isSelected = false,
  });

  final String id;
  final String city;
  final String country;
  final String countryFlag;
  final int days;
  final String theme;
  final bool isSelected;
}
