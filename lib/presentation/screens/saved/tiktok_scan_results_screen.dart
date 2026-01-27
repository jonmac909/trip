import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import 'package:trippified/core/constants/app_colors.dart';
import 'package:trippified/core/constants/app_spacing.dart';
import 'package:trippified/core/errors/exceptions.dart';
import 'package:trippified/core/services/content_scan_service.dart';
import 'package:trippified/domain/models/scanned_place.dart';
import 'package:trippified/presentation/providers/saved_provider.dart';

/// Screen showing places found from a TikTok/Instagram scan
class TiktokScanResultsScreen extends ConsumerStatefulWidget {
  const TiktokScanResultsScreen({
    super.key,
    this.url,
    this.mediaBytes,
    this.mediaType,
  });

  final String? url;
  final List<Uint8List>? mediaBytes;
  final String? mediaType; // 'images' or 'video'

  @override
  ConsumerState<TiktokScanResultsScreen> createState() =>
      _TiktokScanResultsScreenState();
}

class _TiktokScanResultsScreenState
    extends ConsumerState<TiktokScanResultsScreen>
    with SingleTickerProviderStateMixin {
  final _scanService = ContentScanService();

  ScanResult? _scanResult;
  bool _isLoading = true;
  String? _errorMessage;
  List<bool> _selections = [];

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startScan();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      ScanResult result;

      if (widget.url != null) {
        result = await _scanService.scanUrl(widget.url!);
      } else if (widget.mediaBytes != null && widget.mediaType == 'video') {
        result = await _scanService.scanVideo(widget.mediaBytes!.first);
      } else if (widget.mediaBytes != null) {
        result = await _scanService.scanImages(widget.mediaBytes!);
      } else {
        throw const ValidationException('No URL or media provided');
      }

      if (!mounted) return;
      setState(() {
        _scanResult = result;
        _selections = List.filled(result.places.length, true);
        _isLoading = false;
      });
    } on TrippifiedException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  int get selectedCount => _selections.where((s) => s).length;

  void _toggleSelection(int index) {
    setState(() {
      _selections[index] = !_selections[index];
    });
  }

  Future<void> _savePlaces() async {
    final selected = <ScannedPlace>[];
    final places = _scanResult?.places ?? [];
    for (var i = 0; i < places.length; i++) {
      if (_selections[i]) {
        selected.add(places[i]);
      }
    }

    if (selected.isEmpty) return;

    final notifier = ref.read(savedItemsNotifierProvider.notifier);
    final saved = await notifier.saveScanResults(
      places: selected,
      sourceUrl: _scanResult?.sourceUrl,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved ${saved.length} places')),
    );
    context.pop();
  }

  void _createTrip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating trip from saved places...')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _buildResultsState(),
            ),
            if (!_isLoading &&
                _errorMessage == null &&
                _scanResult != null &&
                _scanResult!.places.isNotEmpty)
              _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading state
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildLoadingHeader(),
        const Spacer(),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Opacity(opacity: _pulseAnimation.value, child: child);
          },
          child: const Icon(
            LucideIcons.scan,
            size: 48,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Scanning for places...',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Analyzing content with AI',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildLoadingHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 56,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Scanning...',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 56,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Scan Complete',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------

  Widget _buildErrorState() {
    return Column(
      children: [
        _buildLoadingHeader(),
        const Spacer(),
        const Icon(
          LucideIcons.alertCircle,
          size: 48,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _startScan,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Results state
  // ---------------------------------------------------------------------------

  Widget _buildResultsState() {
    final places = _scanResult!.places;

    if (places.isEmpty) {
      return Column(
        children: [
          _buildEmptyHeader(),
          const Spacer(),
          const Icon(
            LucideIcons.searchX,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No places found',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different URL or upload screenshots',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(flex: 2),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(
        top: 56,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildSourcePreview(),
        const SizedBox(height: 20),
        ...places.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlaceItem(
              place: entry.value,
              isSelected: _selections[entry.key],
              onToggle: () => _toggleSelection(entry.key),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeader() {
    final places = _scanResult!.places;
    final sourceLabel = _scanResult!.sourceLabel ?? 'social media';

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.arrowLeft,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found ${places.length} Place${places.length != 1 ? 's' : ''}',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'From $sourceLabel',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourcePreview() {
    final inputType = _scanResult!.inputType;
    final label = _scanResult!.sourceLabel ?? '';

    IconData icon;
    switch (inputType) {
      case ScanInputType.url:
        icon = LucideIcons.video;
      case ScanInputType.images:
        icon = LucideIcons.image;
      case ScanInputType.video:
        icon = LucideIcons.video;
    }

    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(
        top: 16,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: 40,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Save Places button
          GestureDetector(
            onTap: _savePlaces,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  selectedCount > 0
                      ? 'Save $selectedCount Places'
                      : 'Save Places',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Create a Trip button
          GestureDetector(
            onTap: _createTrip,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.sparkles,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Create a Trip',
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
    );
  }
}

class _PlaceItem extends StatelessWidget {
  const _PlaceItem({
    required this.place,
    required this.isSelected,
    required this.onToggle,
  });

  final ScannedPlace place;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.border, width: 1.5),
              ),
              child: isSelected
                  ? const Icon(
                      LucideIcons.check,
                      size: 14,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Info
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
                    '${place.category} \u00b7 ${place.location}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Confidence indicator
            _ConfidenceDot(confidence: place.confidence),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceDot extends StatelessWidget {
  const _ConfidenceDot({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (confidence >= 0.7) {
      color = const Color(0xFF4CAF50);
    } else if (confidence >= 0.4) {
      color = const Color(0xFFFFC107);
    } else {
      color = const Color(0xFFFF5722);
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
