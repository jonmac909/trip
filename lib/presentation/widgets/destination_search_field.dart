import 'package:flutter/material.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';

/// Search field for selecting a destination city
class DestinationSearchField extends StatefulWidget {
  const DestinationSearchField({
    required this.onDestinationSelected,
    super.key,
  });

  final void Function(String city, String country) onDestinationSelected;

  @override
  State<DestinationSearchField> createState() => _DestinationSearchFieldState();
}

class _DestinationSearchFieldState extends State<DestinationSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<_Destination> _filteredDestinations = [];

  // Popular destinations for demo (will be replaced with Google Places API)
  static const _popularDestinations = [
    _Destination('Tokyo', 'Japan', '🇯🇵'),
    _Destination('Paris', 'France', '🇫🇷'),
    _Destination('London', 'United Kingdom', '🇬🇧'),
    _Destination('New York', 'United States', '🇺🇸'),
    _Destination('Bangkok', 'Thailand', '🇹🇭'),
    _Destination('Barcelona', 'Spain', '🇪🇸'),
    _Destination('Rome', 'Italy', '🇮🇹'),
    _Destination('Sydney', 'Australia', '🇦🇺'),
    _Destination('Dubai', 'United Arab Emirates', '🇦🇪'),
    _Destination('Singapore', 'Singapore', '🇸🇬'),
    _Destination('Bali', 'Indonesia', '🇮🇩'),
    _Destination('Amsterdam', 'Netherlands', '🇳🇱'),
    _Destination('Seoul', 'South Korea', '🇰🇷'),
    _Destination('Kyoto', 'Japan', '🇯🇵'),
    _Destination('Osaka', 'Japan', '🇯🇵'),
    _Destination('Florence', 'Italy', '🇮🇹'),
    _Destination('Prague', 'Czech Republic', '🇨🇿'),
    _Destination('Vienna', 'Austria', '🇦🇹'),
    _Destination('Lisbon', 'Portugal', '🇵🇹'),
    _Destination('Berlin', 'Germany', '🇩🇪'),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _filteredDestinations = _popularDestinations;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDestinations = _popularDestinations;
      } else {
        _filteredDestinations = _popularDestinations
            .where(
              (d) =>
                  d.city.toLowerCase().contains(query.toLowerCase()) ||
                  d.country.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _onDestinationTap(_Destination destination) {
    widget.onDestinationSelected(destination.city, destination.country);
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search destinations...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        if (_showSuggestions) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _filteredDestinations.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Center(
                      child: Text(
                        'No destinations found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    itemCount: _filteredDestinations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final destination = _filteredDestinations[index];
                      return _DestinationTile(
                        destination: destination,
                        onTap: () => _onDestinationTap(destination),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}

/// Individual destination model
class _Destination {
  const _Destination(this.city, this.country, this.flag);

  final String city;
  final String country;
  final String flag;
}

/// Destination list tile
class _DestinationTile extends StatelessWidget {
  const _DestinationTile({required this.destination, required this.onTap});

  final _Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Text(destination.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.city,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    destination.country,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
