import 'package:flutter_test/flutter_test.dart';
import 'package:trippified/core/services/content_scan_service.dart';

void main() {
  test('excludes cities, only returns venues', () async {
    final service = ContentScanService();

    final result = await service.scanUrl(
      'https://www.tiktok.com/@myguidetotheworld/video/7572252209665068310',
    );

    expect(result.places, isNotEmpty);

    // Verify no cities/countries in results
    final names = result.places.map((p) => p.name.toLowerCase()).toList();
    expect(names, isNot(contains('phuket')));
    expect(names, isNot(contains('thailand')));
    expect(names, isNot(contains('bangkok')));

    // ignore: avoid_print
    print('Found ${result.places.length} places:');
    for (final place in result.places) {
      // ignore: avoid_print
      print(
        '  - ${place.name} (${place.category}) '
        '@ ${place.location} [${place.confidence}]',
      );
    }
  }, timeout: const Timeout(Duration(seconds: 45)));

  test('scans vt.tiktok.com short link', () async {
    final service = ContentScanService();

    final result = await service.scanUrl(
      'https://vt.tiktok.com/ZSaAr3pxP/',
    );

    // ignore: avoid_print
    print('Found ${result.places.length} places:');
    for (final place in result.places) {
      // ignore: avoid_print
      print(
        '  - ${place.name} (${place.category}) '
        '@ ${place.location} [${place.confidence}]',
      );
    }
  }, timeout: const Timeout(Duration(seconds: 45)));
}
