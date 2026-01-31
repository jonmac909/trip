import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/data/repositories/saved_repository.dart';
import 'package:trippified/presentation/navigation/app_router.dart';
import 'package:trippified/presentation/providers/saved_provider.dart';

/// Saved screen for viewing saved itineraries, places, and links
class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _urlController = TextEditingController();
  final _imagePicker = ImagePicker();

  // User's saved itineraries - populated from provider
  final List<_SavedItineraryData> _savedItineraries = [];

  // User's saved links - populated from provider
  final List<_SavedLinkData> _savedLinks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load saved items from repository
    Future.microtask(() {
      ref.read(savedItemsNotifierProvider.notifier).loadSavedItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool get _isEmpty {
    final savedState = ref.read(savedItemsNotifierProvider);
    final savedItems = savedState.value ?? [];
    return _savedItineraries.isEmpty &&
        savedItems.isEmpty &&
        _savedLinks.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 56 - kToolbarHeight + AppSpacing.lg),

            // Tabs
            _buildTabs(),
            const SizedBox(height: AppSpacing.lg),

            // Import row
            _buildImportRow(),
            const SizedBox(height: AppSpacing.lg),

            // Tab content
            Expanded(
              child: _isEmpty ? _buildEmptyState() : _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Itineraries', height: 44),
          Tab(text: 'Places', height: 44),
          Tab(text: 'Links', height: 44),
        ],
      ),
    );
  }

  Widget _buildImportRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _urlController,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste TikTok or Instagram URL',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      LucideIcons.link,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 38,
                    minHeight: 0,
                  ),
                  suffixIcon: _urlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            LucideIcons.x,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () {
                            setState(() {
                              _urlController.clear();
                            });
                          },
                        )
                      : IconButton(
                          icon: const Icon(
                            LucideIcons.clipboardPaste,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: _pasteFromClipboard,
                        ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _handleMediaUpload,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                LucideIcons.camera,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _handleImport,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.link,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Import',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.bookmark,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing saved yet',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 280,
              child: Text(
                'Save places from Explore or import from\nTikTok and Instagram',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // Navigate to explore
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.compass,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Start Exploring',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildItinerariesTab(),
        _buildPlacesTab(),
        _buildLinksTab(),
      ],
    );
  }

  Widget _buildItinerariesTab() {
    if (_savedItineraries.isEmpty) {
      return _buildTabEmptyState(
        'No saved itineraries',
        'Save itineraries from Explore to find them here',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Itineraries',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${_savedItineraries.length} saved',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ..._savedItineraries.map((itinerary) {
          final index = _savedItineraries.indexOf(itinerary);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _DismissibleCard(
              itemKey: itinerary.id,
              itemName: itinerary.title,
              onDismissed: () {
                setState(() {
                  _savedItineraries.removeWhere((i) => i.id == itinerary.id);
                });
              },
              onUndo: () {
                setState(() {
                  _savedItineraries.insert(index, itinerary);
                });
              },
              child: _SavedItineraryCard(itinerary: itinerary),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlacesTab() {
    final savedState = ref.watch(savedItemsNotifierProvider);

    return savedState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => _buildTabEmptyState(
        'Error loading places',
        'Pull to refresh or try again later',
      ),
      data: (items) {
        if (items.isEmpty) {
          return _buildTabEmptyState(
            'No saved places',
            'Scan TikTok or Instagram links to save places',
          );
        }

        // Group items by city (last part of "Neighborhood, City")
        final grouped = <String, List<SavedItem>>{};
        for (final item in items) {
          final fullLocation = item.metadata?['location'] as String? ??
              'Unknown Location';
          final parts = fullLocation.split(', ');
          final city = parts.length > 1 ? parts.last.trim() : fullLocation;
          grouped.putIfAbsent(city, () => []).add(item);
        }

        final cityGroups = grouped.entries.toList()
          ..sort((a, b) => b.value.length.compareTo(a.value.length));

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: [
            ...cityGroups.map((entry) {
              final entryIndex = cityGroups.indexOf(entry);
              final placesBackup = List<SavedItem>.from(entry.value);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _DismissibleCard(
                  itemKey: entry.key,
                  itemName: entry.key,
                  onDismissed: () => _deleteLocationGroup(entry.value),
                  onUndo: () {
                    // Re-add the places to state
                    final notifier =
                        ref.read(savedItemsNotifierProvider.notifier);
                    for (final place in placesBackup) {
                      notifier.addItemToState(place);
                    }
                  },
                  child: _SavedLocationGroup(
                    locationName: entry.key,
                    places: entry.value,
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                '${items.length} total places across '
                '${cityGroups.length} locations',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLinksTab() {
    if (_savedLinks.isEmpty) {
      return _buildTabEmptyState(
        'No saved links',
        'Import links from TikTok or Instagram',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Links',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${_savedLinks.length} saved',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ..._savedLinks.map((link) {
          final index = _savedLinks.indexOf(link);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _DismissibleCard(
              itemKey: link.title,
              itemName: link.title,
              onDismissed: () {
                setState(() {
                  _savedLinks.removeWhere((l) => l.title == link.title);
                });
              },
              onUndo: () {
                setState(() {
                  _savedLinks.insert(index, link);
                });
              },
              child: _SavedLinkCard(link: link),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTabEmptyState(String title, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.bookmark,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _urlController.text = data.text!.trim();
        _urlController.selection = TextSelection.collapsed(
          offset: _urlController.text.length,
        );
      });
    }
  }

  Future<void> _handleImport() async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste a TikTok or Instagram URL first')),
      );
      return;
    }

    if (!mounted) return;
    context.push(AppRoutes.tiktokScanResults, extra: {
      'url': url,
    });
  }

  Future<void> _deleteLocationGroup(List<SavedItem> places) async {
    final notifier = ref.read(savedItemsNotifierProvider.notifier);
    for (final place in places) {
      await notifier.unsaveItem(place.id);
    }
  }

  Future<void> _handleMediaUpload() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _MediaSourceSheet(),
    );

    if (choice == null || !mounted) return;

    if (choice == 'screenshots') {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (images.isEmpty || !mounted) return;

      final bytesList = await Future.wait(
        images.take(10).map((img) => img.readAsBytes()),
      );

      if (!mounted) return;
      context.push(AppRoutes.tiktokScanResults, extra: {
        'mediaBytes': bytesList,
        'mediaType': 'images',
      });
    } else if (choice == 'recording') {
      final video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      if (video == null || !mounted) return;

      final bytes = await video.readAsBytes();

      // Gemini inline limit is ~20MB
      if (bytes.lengthInBytes > 20 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video must be under 20MB')),
        );
        return;
      }

      if (!mounted) return;
      context.push(AppRoutes.tiktokScanResults, extra: {
        'mediaBytes': [bytes],
        'mediaType': 'video',
      });
    }
  }
}

class _MediaSourceSheet extends StatelessWidget {
  const _MediaSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Upload Media',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AI will scan for places mentioned in the content',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _MediaSourceOption(
              icon: LucideIcons.image,
              title: 'Upload Screenshots',
              description: 'Select screenshots from TikTok or Instagram',
              onTap: () => Navigator.pop(context, 'screenshots'),
            ),
            const SizedBox(height: 12),
            _MediaSourceOption(
              icon: LucideIcons.video,
              title: 'Upload Screen Recording',
              description: 'Select a screen recording (max 20MB)',
              onTap: () => Navigator.pop(context, 'recording'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MediaSourceOption extends StatelessWidget {
  const _MediaSourceOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
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
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedItineraryCard extends StatelessWidget {
  const _SavedItineraryCard({required this.itinerary});

  final _SavedItineraryData itinerary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/saved/customize/${itinerary.id}', extra: {
          'cityName': itinerary.title,
          'country': itinerary.country,
        });
      },
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(13),
            ),
            child: SizedBox(
              width: 80,
              height: 80,
              child: CachedNetworkImage(
                imageUrl: itinerary.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.shimmerBase,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.shimmerBase,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 4),
                  Text(
                    '${itinerary.country} \u00b7 ${itinerary.duration}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.star,
                        size: 14,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${itinerary.rating} \u00b7 ${itinerary.saves} saves',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _SavedLocationGroup extends StatelessWidget {
  const _SavedLocationGroup({
    required this.locationName,
    required this.places,
  });

  final String locationName;
  final List<SavedItem> places;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/saved/city/${locationName.hashCode}', extra: {
          'cityName': locationName,
          'placeCount': places.length,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.mapPin,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationName,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${places.length} place${places.length != 1 ? 's' : ''} saved',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedLinkCard extends StatelessWidget {
  const _SavedLinkCard({required this.link});

  final _SavedLinkData link;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening: ${link.title}')),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              link.icon,
              size: 24,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${link.source} \u00b7 ${link.contentType}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.link,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Saved ${link.savedDaysAgo} days ago',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
      ),
    );
  }
}

class _DismissibleCard extends StatelessWidget {
  const _DismissibleCard({
    required this.itemKey,
    required this.itemName,
    required this.onDismissed,
    required this.onUndo,
    required this.child,
  });

  final String itemKey;
  final String itemName;
  final VoidCallback onDismissed;
  final VoidCallback onUndo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(itemKey),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDismissed();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$itemName deleted',
              style: GoogleFonts.dmSans(),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.accent,
              onPressed: onUndo,
            ),
          ),
        );
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
      child: child,
    );
  }
}

class _SavedItineraryData {
  const _SavedItineraryData({
    required this.id,
    required this.title,
    required this.country,
    required this.duration,
    required this.rating,
    required this.saves,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String country;
  final String duration;
  final double rating;
  final String saves;
  final String imageUrl;
}


class _SavedLinkData {
  const _SavedLinkData({
    required this.title,
    required this.source,
    required this.contentType,
    required this.savedDaysAgo,
    required this.icon,
  });

  final String title;
  final String source;
  final String contentType;
  final int savedDaysAgo;
  final IconData icon;
}
