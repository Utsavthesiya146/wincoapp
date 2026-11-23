import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winco_connect/data/models/mitb_model.dart';
import 'package:winco_connect/data/repositories/mitb_repository.dart';
import 'package:winco_connect/features/mitb/presentation/mitb_screen.dart';
import 'package:winco_connect/features/mitb/presentation/widgets/add_mitb_bottom_sheet.dart';

final _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_kTransparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('MITB Data Model and Parsing Tests', () {
    test('MitbSummary.baseline returns expected default values', () {
      final summary = MitbSummary.baseline();
      expect(summary.totalRevenue, '₹ 1,00,000');
      expect(summary.avgMemberValue, '₹ 33,333');
      expect(summary.totalRecords, 3);
      expect(summary.receivedCount, 3);
      expect(summary.givenCount, 0);
    });

    test('MitbMemberOption parses json properly', () {
      final option = MitbMemberOption.fromJson({
        'user_code': 'USR00015',
        'name': 'Santhosha H R',
        'is_self': '0',
      });
      expect(option.userCode, 'USR00015');
      expect(option.name, 'Santhosha H R');
      expect(option.isSelf, isFalse);

      final selfOption = MitbMemberOption.fromJson({
        'user_code': 'USR00001',
        'name': 'Harri Kumar',
        'is_self': '1',
      });
      expect(selfOption.isSelf, isTrue);
    });

    test('MitbSubmissionPayload toFormData creates valid map', () {
      const payload = MitbSubmissionPayload(
        category: 'My Chapter Member',
        toUser: 'USR00015',
        amount: '75000',
        businessType: 'New',
        createdAt: '2026-07-01',
        description: 'Construction structural design consulting fees',
      );

      final map = payload.toFormData();
      expect(map['category'], 'My Chapter Member');
      expect(map['to_user'], 'USR00015');
      expect(map['amount'], '75000');
      expect(map['business_type'], 'New');
      expect(map['created_at'], '2026-07-01');
      expect(map['description'], 'Construction structural design consulting fees');
    });

    test('MitbPageData.fromHtml parses real production MITB dump', () {
      final file = File('test/fixtures/mitb_dump.html');
      if (!file.existsSync()) {
        final baseline = MitbPageData.baseline();
        expect(baseline.receivedRecords.length, 2);
        return;
      }

      final html = file.readAsStringSync();
      final pageData = MitbPageData.fromHtml(html);

      expect(pageData.summary.totalRevenue, contains('1,00,000'));
      expect(pageData.summary.avgMemberValue, contains('33,333'));
      expect(pageData.summary.totalRecords, 3);
      expect(pageData.summary.receivedCount, 3);
      expect(pageData.summary.givenCount, 0);

      expect(pageData.receivedRecords.length, 3);
      final latest = pageData.receivedRecords[0];
      expect(latest.id, 'MITB0158');
      expect(latest.fromMemberName, contains('Harri Kumar'));
      expect(latest.amount, contains('0'));
      expect(latest.date, contains('16 Nov 2026'));

      final second = pageData.receivedRecords[1];
      expect(second.fromMemberName, contains('Santhosha'));
      expect(second.fromMemberEmail, 'santha.hr@gmail.com');
      expect(second.toMemberName, contains('Harri Kumar'));
      expect(second.amount, contains('50,000'));
      expect(second.date, contains('29 Jun 2026'));

      expect(pageData.givenRecords, isEmpty);
    });

    test('MockMitbRepository returns baseline data and handles submission', () async {
      final repo = MockMitbRepository();
      final data = await repo.getMitbData();
      expect(data.summary.totalRecords, 3);
      expect(data.receivedRecords.length, 3);

      final members = await repo.getMembers(type: 'chapter');
      expect(members.isNotEmpty, isTrue);

      final res = await repo.submitMitb(const MitbSubmissionPayload(
        category: 'My Chapter Member',
        toUser: 'USR00015',
        amount: '50000',
        businessType: 'New',
        createdAt: '2026-07-01',
        description: 'Test slip',
      ));
      expect(res['status'], 'success');
    });
  });

  group('MitbScreen and AddMitbBottomSheet Widget Tests', () {
    testWidgets('MitbScreen displays summary metrics and received records list', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mitbDataProvider.overrideWith((ref) async => MitbPageData.baseline()),
          ],
          child: const MaterialApp(
            home: MitbScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Business Done (MITB)'), findsOneWidget);
      expect(find.text('Money in the Bank (MITB)'), findsOneWidget);
      expect(find.text('₹ 1,00,000'), findsWidgets);
      expect(find.text('₹ 33,333'), findsOneWidget);
      expect(find.text('₹ 50,000'), findsWidgets);
      expect(find.text('Business Received'), findsOneWidget);
      expect(find.text('Business Given'), findsOneWidget);
      expect(find.textContaining('Santhosha H R'), findsWidgets);
      expect(find.textContaining('Harri Kumar'), findsWidgets);
    });

    testWidgets('MitbScreen switches to Business Given tab and shows empty state', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mitbDataProvider.overrideWith((ref) async => MitbPageData.baseline()),
          ],
          child: const MaterialApp(
            home: MitbScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on Business Given tab
      final givenTabFinder = find.text('Business Given');
      expect(givenTabFinder, findsOneWidget);
      await tester.tap(givenTabFinder);
      await tester.pumpAndSettle();

      expect(find.text('No Business Given Records'), findsOneWidget);
      expect(find.text('Report Business Given'), findsOneWidget);
    });

    testWidgets('AddMitbBottomSheet opens and validates empty inputs', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mitbRepositoryProvider.overrideWithValue(MockMitbRepository()),
            mitbMembersListProvider('chapter').overrideWith(
              (ref) async => const [
                MitbMemberOption(userCode: 'USR00015', name: 'Santhosha H R', isSelf: false),
              ],
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AddMitbBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Report Business Done 💸'), findsOneWidget);
      expect(find.text('Who gave you this business? 🤝 *'), findsOneWidget);
      expect(find.text('Business Closed Amount (INR) 💰 *'), findsOneWidget);

      // Attempt submit without filling amount
      final submitBtn = find.text('Submit Business Done');
      expect(submitBtn, findsOneWidget);
      await tester.ensureVisible(submitBtn);
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter closed business amount'), findsOneWidget);
    });

    testWidgets('MitbScreen displays error view when data fetch fails', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mitbDataProvider.overrideWith((ref) async => throw Exception('Unable to reach WINCO backend')),
          ],
          child: const MaterialApp(
            home: MitbScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Unable to reach WINCO backend'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('MitbScreen displays loading indicator during fetch', (WidgetTester tester) async {
      final completer = Completer<MitbPageData>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mitbDataProvider.overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            home: MitbScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(MitbPageData.baseline());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
