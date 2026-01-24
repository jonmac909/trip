import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Trip size options as defined in PRD
enum TripSize {
  short('Short', '1-4 days'),
  weekLong('Week-long', '5-9 days'),
  long('Long or open-ended', '10+ days');

  const TripSize(this.label, this.description);
  final String label;
  final String description;
}

/// Trip setup screen - PRD Section 3.2
/// Input: Countries (autocomplete, multiple allowed)
/// Input: Trip size (Short / Week-long / Long or open-ended)
/// Output: Recommended routes
class TripSetupScreen extends StatefulWidget {
  const TripSetupScreen({super.key});

  @override
  State<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends State<TripSetupScreen> {
  final _countryController = TextEditingController();
  final List<String> _selectedCountries = [];
  TripSize? _selectedTripSize;

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Trip'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                // Countries input
                Text(
                  'Where to?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Add one or more countries',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _CountryAutocomplete(
                  controller: _countryController,
                  selectedCountries: _selectedCountries,
                  onCountrySelected: (country) {
                    if (!_selectedCountries.contains(country)) {
                      setState(() {
                        _selectedCountries.add(country);
                        _countryController.clear();
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),

                // Selected countries as chips
                if (_selectedCountries.isNotEmpty)
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _selectedCountries.map((country) {
                      return _CountryChip(
                        country: country,
                        onRemove: () {
                          setState(() {
                            _selectedCountries.remove(country);
                          });
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: AppSpacing.xl),

                // Trip size selector
                Text(
                  'How long?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...TripSize.values.map((size) {
                  return _TripSizeOption(
                    tripSize: size,
                    isSelected: _selectedTripSize == size,
                    onTap: () {
                      setState(() {
                        _selectedTripSize = size;
                      });
                    },
                  );
                }),
              ],
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: FilledButton(
                onPressed: _canContinue ? _onSeeRoutes : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                ),
                child: const Text('See recommended routes'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CTA disabled until ≥1 country AND trip size selected
  bool get _canContinue =>
      _selectedCountries.isNotEmpty && _selectedTripSize != null;

  void _onSeeRoutes() {
    context.push(
      AppRoutes.recommendedRoutes,
      extra: {
        'countries': _selectedCountries,
        'tripSize': _selectedTripSize,
      },
    );
  }
}

/// Country autocomplete input
class _CountryAutocomplete extends StatelessWidget {
  const _CountryAutocomplete({
    required this.controller,
    required this.selectedCountries,
    required this.onCountrySelected,
  });

  final TextEditingController controller;
  final List<String> selectedCountries;
  final ValueChanged<String> onCountrySelected;

  // Common travel destination countries
  static const _countries = [
    'Japan',
    'Thailand',
    'Italy',
    'France',
    'Spain',
    'Greece',
    'Portugal',
    'United Kingdom',
    'Germany',
    'Netherlands',
    'Switzerland',
    'Austria',
    'Czech Republic',
    'Croatia',
    'Turkey',
    'Morocco',
    'Egypt',
    'South Africa',
    'Australia',
    'New Zealand',
    'Indonesia',
    'Vietnam',
    'South Korea',
    'Singapore',
    'Malaysia',
    'Philippines',
    'India',
    'Sri Lanka',
    'Nepal',
    'Maldives',
    'United States',
    'Canada',
    'Mexico',
    'Costa Rica',
    'Colombia',
    'Peru',
    'Argentina',
    'Brazil',
    'Chile',
    'Iceland',
    'Norway',
    'Sweden',
    'Denmark',
    'Finland',
    'Ireland',
    'Scotland',
    'Belgium',
    'Poland',
    'Hungary',
    'Romania',
  ];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _countries.where((country) {
          return country.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ) &&
              !selectedCountries.contains(country);
        });
      },
      onSelected: onCountrySelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Search countries...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onSubmitted: (_) => onSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    leading: const Icon(
                      Icons.flag_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Removable country chip
class _CountryChip extends StatelessWidget {
  const _CountryChip({
    required this.country,
    required this.onRemove,
  });

  final String country;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flag, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            country,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: const Icon(Icons.close, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

/// Trip size option button
class _TripSizeOption extends StatelessWidget {
  const _TripSizeOption({
    required this.tripSize,
    required this.isSelected,
    required this.onTap,
  });

  final TripSize tripSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripSize.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tripSize.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? AppColors.textOnPrimary.withValues(alpha: 0.8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.textOnPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
