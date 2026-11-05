import 'dart:convert';

import 'package:cx_shield/core/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  ApiClient clientWith(MockClientHandler handler, {String? token = 'token'}) =>
      ApiClient(httpClient: MockClient(handler), baseUrl: 'http://api.test', accessToken: () => token);

  http.Response json(Object body, int status) => http.Response.bytes(
        utf8.encode(jsonEncode(body)),
        status,
        headers: {'content-type': 'application/json'},
      );

  test('gửi access token và đường dẫn /api/v1', () async {
    late http.Request sent;
    final client = clientWith((request) async {
      sent = request;
      return json({'ok': true}, 200);
    });

    final result = await client.get('/me');

    expect(result, {'ok': true});
    expect(sent.method, 'GET');
    expect(sent.url.toString(), 'http://api.test/api/v1/me');
    expect(sent.headers['Authorization'], 'Bearer token');
  });

  test('không gửi Authorization khi chưa đăng nhập', () async {
    late http.Request sent;
    final client = clientWith((request) async {
      sent = request;
      return json({}, 200);
    }, token: null);

    await client.get('/me');

    expect(sent.headers.containsKey('Authorization'), isFalse);
  });

  test('POST và PUT gửi body JSON', () async {
    final sent = <http.Request>[];
    final client = clientWith((request) async {
      sent.add(request);
      return json({}, 200);
    });

    await client.post('/onboarding', {'brandName': 'Maison'});
    await client.put('/branches/1/google-place', {'placeId': 'abc'});

    expect(sent.map((r) => r.method), ['POST', 'PUT']);
    expect(sent.first.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(sent.first.body), {'brandName': 'Maison'});
    expect(jsonDecode(sent.last.body), {'placeId': 'abc'});
  });

  test('đọc đúng tiếng Việt trong phản hồi', () async {
    final client = clientWith((_) async => json({'name': 'Chi nhánh Quận 1'}, 200));

    expect(await client.get('/me'), {'name': 'Chi nhánh Quận 1'});
  });

  test('phản hồi rỗng trả về null', () async {
    final client = clientWith((_) async => http.Response('', 204));

    expect(await client.get('/me'), isNull);
  });

  test('lỗi nghiệp vụ giữ mã lỗi và lỗi từng trường', () async {
    final client = clientWith((_) async => json({
          'code': 'VALIDATION_ERROR',
          'message': 'Dữ liệu chưa hợp lệ.',
          'fieldErrors': {'phone': 'Số điện thoại không hợp lệ.'},
        }, 400));

    await expectLater(
      client.post('/onboarding', {}),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 400)
          .having((e) => e.code, 'code', 'VALIDATION_ERROR')
          .having((e) => e.toString(), 'toString', 'Dữ liệu chưa hợp lệ.')
          .having((e) => e.fieldErrors['phone'], 'phone', 'Số điện thoại không hợp lệ.')),
    );
  });

  test('401 không có body báo hết phiên đăng nhập', () async {
    final client = clientWith((_) async => http.Response('', 401));

    await expectLater(
      client.get('/me'),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', 'UNAUTHORIZED')
          .having((e) => e.message, 'message', contains('hết hạn'))),
    );
  });

  test('lỗi khác không có body vẫn có thông báo', () async {
    final client = clientWith((_) async => http.Response('', 503));

    await expectLater(
      client.get('/me'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('503'))),
    );
  });

  test('mất mạng báo NETWORK_ERROR', () async {
    final client = clientWith((_) async => throw http.ClientException('offline'));

    await expectLater(
      client.get('/me'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 0)
          .having((e) => e.code, 'code', 'NETWORK_ERROR')),
    );
  });
}
