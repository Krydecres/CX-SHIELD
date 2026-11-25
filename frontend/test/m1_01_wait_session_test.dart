import 'dart:async';
import 'dart:convert';

import 'package:cx_shield/core/services/survey_api_service.dart';
import 'package:cx_shield/screens/m1_01_rating_screen.dart';
import 'package:cx_shield/screens/m1_02_google_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// SCRUM-254: khách bấm sao khi backend chưa trả phiên khảo sát thật
/// thì đánh giá phải gửi kèm đúng mã phiên thật, không gửi mã rỗng.
void main() {
  const realSessionId = '11111111-2222-3333-4444-555555555555';

  testWidgets('Bấm 5 sao trước khi tải xong phiên vẫn gửi đúng sessionId thật', (tester) async {
    final initResponse = Completer<http.Response>();
    final rateBodies = <Map<String, dynamic>>[];

    final apiService = SurveyApiService(
      client: MockClient((request) async {
        if (request.method == 'GET' && request.url.path.contains('/surveys/qr/')) {
          return initResponse.future;
        }
        if (request.method == 'POST' && request.url.path.endsWith('/rate')) {
          rateBodies.add(json.decode(request.body) as Map<String, dynamic>);
          return http.Response(
            json.encode({
              'success': true,
              'data': {
                'sessionId': realSessionId,
                'starRating': 5,
                'sentimentGroup': 'SATISFIED',
                'targetScreen': 'M1-02',
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('{}', 404);
      }),
    );

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(MaterialApp(home: M101RatingScreen(qrCode: 'MC-VIP', apiService: apiService)));

    // Bấm 5 sao ngay, lúc backend chưa trả phiên.
    final star = find.byIcon(Icons.star_outline_rounded).at(4);
    await tester.ensureVisible(star);
    await tester.tap(star);
    await tester.pump();

    expect(find.text('Đang chuyển tiếp...'), findsOneWidget);
    expect(rateBodies, isEmpty, reason: 'Chưa có phiên thật thì chưa được gửi đánh giá');

    // Backend trả phiên thật.
    initResponse.complete(http.Response(
      json.encode({
        'success': true,
        'data': {'sessionId': realSessionId, 'qrCode': 'MC-VIP', 'tableOrAreaCode': 'Bàn VIP 01'},
      }),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    ));
    await tester.pumpAndSettle();

    expect(rateBodies, hasLength(1));
    expect(rateBodies.single['sessionId'], realSessionId);
    expect(rateBodies.single['starRating'], 5);
    expect(find.byType(M102GoogleReviewScreen), findsOneWidget);
  });
}
