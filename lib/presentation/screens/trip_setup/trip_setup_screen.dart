import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/presentation/navigation/app_router.dart';

/// Trip size options as defined in PRD
enum TripSize {
  short('Short trip', '1-4 days'),
  weekLong('Week-long', '5-10 days'),
  long('Long or open-ended', '10+ days or flexible');

  const TripSize(this.label, this.description);
  final String label;
  final String description;
}

/// Country data with flag
class CountryData {
  const CountryData(this.name, this.flag);
  final String name;
  final String flag;
}

/// Trip setup screen - PRD Section 3.2 (design 44)
class TripSetupScreen extends StatefulWidget {
  const TripSetupScreen({super.key});

  @override
  State<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends State<TripSetupScreen> {
  final _countryController = TextEditingController();
  final _focusNode = FocusNode();
  final List<CountryData> _selectedCountries = [];
  TripSize? _selectedTripSize;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && _countryController.text.isEmpty;
    });
  }

  @override
  void dispose() {
    _countryController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and title
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
                  const SizedBox(width: 16),
                  Text(
                    'Plan a Trip',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Scrollable form content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country section
                      _buildCountrySection(),
                      const SizedBox(height: AppSpacing.lg),

                      // Trip size section
                      _buildTripSizeSection(),
                    ],
                  ),
                ),
              ),

              // Bottom CTA button
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where do you want to go?',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add one or more countries',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Search input with dark border when focused
        _CountryAutocomplete(
          controller: _countryController,
          focusNode: _focusNode,
          selectedCountries: _selectedCountries,
          onCountrySelected: (country) {
            if (!_selectedCountries.any((c) => c.name == country.name)) {
              setState(() {
                _selectedCountries.add(country);
                _countryController.clear();
              });
            }
          },
        ),
        const SizedBox(height: 12),

        // Selected countries as chips
        if (_selectedCountries.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedCountries.map((country) {
              return _CountryChip(
                label: country.name,
                onRemove: () {
                  setState(() {
                    _selectedCountries.remove(country);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTripSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How long is your trip?',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),

        // Trip size options
        ...TripSize.values.map((size) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TripSizeOption(
              title: size.label,
              subtitle: size.description,
              isSelected: _selectedTripSize == size,
              onTap: () {
                setState(() {
                  _selectedTripSize = size;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContinueButton() {
    final isEnabled = _selectedCountries.isNotEmpty && _selectedTripSize != null;

    return GestureDetector(
      onTap: isEnabled ? _onSeeRoutes : null,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'See Recommended Routes',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isEnabled
                    ? AppColors.textOnPrimary
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.arrowRight,
              size: 20,
              color: isEnabled ? AppColors.textOnPrimary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _onSeeRoutes() {
    context.push(
      AppRoutes.recommendedRoutes,
      extra: {
        'countries': _selectedCountries.map((c) => c.name).toList(),
        'tripSize': _selectedTripSize,
      },
    );
  }
}

/// Trip size option widget (design 44)
class _TripSizeOption extends StatelessWidget {
  const _TripSizeOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFF2A2A2E),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side - title and subtitle
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            // Right side - radio button
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(
                        color: const Color(0xFF3A3A40),
                        width: 2,
                      ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Country chip widget (design 44)
class _CountryChip extends StatelessWidget {
  const _CountryChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              LucideIcons.x,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Country autocomplete input (design 44)
class _CountryAutocomplete extends StatelessWidget {
  const _CountryAutocomplete({
    required this.controller,
    required this.focusNode,
    required this.selectedCountries,
    required this.onCountrySelected,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<CountryData> selectedCountries;
  final ValueChanged<CountryData> onCountrySelected;

  static const _countries = [
    CountryData('Japan', '\u{1F1EF}\u{1F1F5}'),
    CountryData('Thailand', '\u{1F1F9}\u{1F1ED}'),
    CountryData('Italy', '\u{1F1EE}\u{1F1F9}'),
    CountryData('France', '\u{1F1EB}\u{1F1F7}'),
    CountryData('Spain', '\u{1F1EA}\u{1F1F8}'),
    CountryData('Greece', '\u{1F1EC}\u{1F1F7}'),
    CountryData('Portugal', '\u{1F1F5}\u{1F1F9}'),
    CountryData('United Kingdom', '\u{1F1EC}\u{1F1E7}'),
    CountryData('Germany', '\u{1F1E9}\u{1F1EA}'),
    CountryData('Netherlands', '\u{1F1F3}\u{1F1F1}'),
    CountryData('Switzerland', '\u{1F1E8}\u{1F1ED}'),
    CountryData('Austria', '\u{1F1E6}\u{1F1F9}'),
    CountryData('Czech Republic', '\u{1F1E8}\u{1F1FF}'),
    CountryData('Croatia', '\u{1F1ED}\u{1F1F7}'),
    CountryData('Turkey', '\u{1F1F9}\u{1F1F7}'),
    CountryData('Morocco', '\u{1F1F2}\u{1F1E6}'),
    CountryData('Australia', '\u{1F1E6}\u{1F1FA}'),
    CountryData('New Zealand', '\u{1F1F3}\u{1F1FF}'),
    CountryData('Indonesia', '\u{1F1EE}\u{1F1E9}'),
    CountryData('Vietnam', '\u{1F1FB}\u{1F1F3}'),
    CountryData('South Korea', '\u{1F1F0}\u{1F1F7}'),
    CountryData('Singapore', '\u{1F1F8}\u{1F1EC}'),
    CountryData('Malaysia', '\u{1F1F2}\u{1F1FE}'),
    CountryData('Philippines', '\u{1F1F5}\u{1F1ED}'),
    CountryData('India', '\u{1F1EE}\u{1F1F3}'),
    CountryData('United States', '\u{1F1FA}\u{1F1F8}'),
    CountryData('Canada', '\u{1F1E8}\u{1F1E6}'),
    CountryData('Mexico', '\u{1F1F2}\u{1F1FD}'),
    CountryData('Peru', '\u{1F1F5}\u{1F1EA}'),
    CountryData('Argentina', '\u{1F1E6}\u{1F1F7}'),
    CountryData('Brazil', '\u{1F1E7}\u{1F1F7}'),
    CountryData('Iceland', '\u{1F1EE}\u{1F1F8}'),
    CountryData('Norway', '\u{1F1F3}\u{1F1F4}'),
    CountryData('Sweden', '\u{1F1F8}\u{1F1EA}'),
    CountryData('Denmark', '\u{1F1E9}\u{1F1F0}'),
    CountryData('Finland', '\u{1F1EB}\u{1F1EE}'),
    CountryData('Ireland', '\u{1F1EE}\u{1F1EA}'),
  ];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<CountryData>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<CountryData>.empty();
        }
        return _countries.where((country) {
          return country.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ) &&
              !selectedCountries.any((c) => c.name == country.name);
        });
      },
      displayStringForOption: (option) => option.name,
      onSelected: onCountrySelected,
      fieldViewBuilder: (context, textController, fieldFocusNode, onSubmitted) {
        // Sync the controllers
        textController.text = controller.text;
        textController.addListener(() {
          if (controller.text != textController.text) {
            controller.text = textController.text;
          }
        });

        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: fieldFocusNode.hasFocus
                  ? const Color(0xFF2A2A2E)
                  : AppColors.border,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                LucideIcons.search,
                size: 20,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: textController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search countries...',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primary,
                  ),
                  onSubmitted: (_) => onSubmitted(),
                ),
              ),
            ],
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 350),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    leading: Text(
                      option.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      option.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
