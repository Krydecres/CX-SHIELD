import 'dart:convert';

import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d4_01_alert_channels/alert_channel_api.dart';
import 'package:cx_shield/features/d4_01_alert_channels/alert_channel_models.dart';
import 'package:cx_shield/features/d4_01_alert_channels/alert_channels_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const botToken = '123456789:AAEabcdefghijklmnopqrstuvwxyz_12345';

  group('đọc dữ liệu API', () {
    test('mã loại kênh', () {
      expect(AlertChannelKind.fromApi('TELEGRAM'), AlertChannelKind.telegram);
      expect(AlertChannelKind.fromApi('ZALO'), AlertChannelKind.zalo);
      expect(AlertChannelKind.fromApi('EMAIL'), AlertChannelKind.email);
    });

    test('cấu hình chi nhánh', () {
      final config = AlertChannelsConfig.fromJson({
        'branchId': 'b1',
        'branchName': 'Quận 1',
        'thresholdStar': 3,
        'channels': [
          {
            'type': 'TELEGRAM',
            'configured': true,
            'enabled': true,
            'maskedBotToken': '••••••2345',
            'chatId': '-100',
            'lastTestedAt': '2026-11-06T03:00:00Z',
          },
        ],
      });

      expect(config.thresholdStar, 3);
      final telegram = config.channel(AlertChannelKind.telegram);
      expect(telegram.maskedBotToken, '••••••2345');
      expect(telegram.lastTestedAt, DateTime.utc(2026, 11, 6, 3).toLocal());
      expect(config.channel(AlertChannelKind.zalo).configured, isFalse);
    });

    test('ngưỡng mặc định là 4 sao', () {
      expect(AlertChannelsConfig.fromJson({'branchId': 'b1'}).thresholdStar, 4);
    });

    test('kết quả gửi thử lỗi', () {
      final result = AlertTestResult.fromJson({'success': false, 'message': 'Sai token'});

      expect(result.success, isFalse);
      expect(result.message, 'Sai token');
      expect(result.lastTestedAt, isNull);
    });
  });

  group('kiểm tra nhập liệu', () {
    test('Bot Token', () {
      expect(validateBotToken(botToken, hasSavedToken: false), isNull);
      expect(validateBotToken('', hasSavedToken: true), isNull);
      expect(validateBotToken('', hasSavedToken: false), isNotNull);
      expect(validateBotToken('sai', hasSavedToken: true), isNotNull);
    });

    test('Chat ID', () {
      expect(validateChatId('-1001234'), isNull);
      expect(validateChatId('@maison_alerts'), isNull);
      expect(validateChatId(''), isNotNull);
      expect(validateChatId('chat id'), isNotNull);
    });

    test('Webhook URL', () {
      expect(validateWebhookUrl('https://hook.example.com/a', hasSavedUrl: false), isNull);
      expect(validateWebhookUrl('', hasSavedUrl: true), isNull);
      expect(validateWebhookUrl('', hasSavedUrl: false), isNotNull);
      expect(validateWebhookUrl('http://hook.example.com', hasSavedUrl: true), isNotNull);
    });

    test('Email', () {
      expect(validateAlertEmail('quanly@maison.vn'), isNull);
      expect(validateAlertEmail(''), isNotNull);
      expect(validateAlertEmail('a@b'), isNotNull);
    });

    test('định dạng ngày giờ', () {
      expect(formatDateTime(DateTime(2026, 11, 6, 9, 5)), '06/11/2026 09:05');
    });
  });

  group('gọi API', () {
    late http.Request captured;

    AlertChannelApi api(Map<String, dynamic> response) => AlertChannelApi(ApiClient(
          baseUrl: 'http://api',
          accessToken: () => 'token',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response.bytes(utf8.encode(jsonEncode(response)), 200);
          }),
        ));

    test('lưu kênh theo loại', () async {
      await api({'type': 'TELEGRAM', 'configured': true, 'enabled': true})
          .save('b1', AlertChannelKind.telegram, enabled: true, botToken: botToken, chatId: '-100');

      expect(captured.method, 'PUT');
      expect(captured.url.path, '/api/v1/branches/b1/alert-channels/TELEGRAM');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['botToken'], botToken);
      expect(body['enabled'], isTrue);
    });

    test('gửi thử', () async {
      final result = await api({'success': true, 'message': 'OK'}).sendTest('b1', AlertChannelKind.zalo);

      expect(captured.url.path, '/api/v1/branches/b1/alert-channels/ZALO/tests');
      expect(result.success, isTrue);
    });
  });

  group('thẻ kênh', () {
    Widget card(
      AlertChannel channel, {
      bool canEdit = true,
      SaveAlertChannel? onSave,
      Future<AlertTestResult> Function()? onTest,
    }) =>
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AlertChannelCard(
                channel: channel,
                canEdit: canEdit,
                onSave: onSave ??
                    ({required enabled, botToken, chatId, webhookUrl, email}) async =>
                        AlertChannel(kind: channel.kind, configured: true, enabled: enabled),
                onTest: onTest ?? () async => const AlertTestResult(success: true, message: 'Đã gửi'),
              ),
            ),
          ),
        );

    testWidgets('kênh mới chưa gửi thử được và báo thiếu thông tin', (tester) async {
      await tester.pumpWidget(card(const AlertChannel(kind: AlertChannelKind.telegram, configured: false, enabled: false)));

      expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed, isNull);
      await tester.tap(find.text('Lưu'));
      await tester.pump();

      expect(find.text('Vui lòng nhập Bot Token.'), findsOneWidget);
      expect(find.text('Vui lòng nhập Chat ID.'), findsOneWidget);
    });

    testWidgets('lưu xong xoá token khỏi ô nhập và hiện thông báo', (tester) async {
      String? sentToken;
      await tester.pumpWidget(card(
        const AlertChannel(kind: AlertChannelKind.telegram, configured: false, enabled: false),
        onSave: ({required enabled, botToken, chatId, webhookUrl, email}) async {
          sentToken = botToken;
          return AlertChannel(
            kind: AlertChannelKind.telegram,
            configured: true,
            enabled: enabled,
            maskedBotToken: '••••••2345',
            chatId: chatId,
          );
        },
      ));

      await tester.enterText(find.byType(TextFormField).first, botToken);
      await tester.enterText(find.byType(TextFormField).last, '-100');
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(sentToken, botToken);
      expect(find.text('Đã lưu cấu hình kênh.'), findsOneWidget);
      expect(find.text('Đã lưu và được che. Để trống nếu không đổi.'), findsOneWidget);
      expect(tester.widget<TextFormField>(find.byType(TextFormField).first).controller!.text, isEmpty);
    });

    testWidgets('gửi thử hiện lý do lỗi', (tester) async {
      await tester.pumpWidget(card(
        const AlertChannel(kind: AlertChannelKind.email, configured: true, enabled: true, email: 'a@b.vn'),
        onTest: () async => const AlertTestResult(success: false, message: 'Hệ thống chưa cấu hình máy chủ gửi email.'),
      ));

      await tester.tap(find.text('Gửi thử'));
      await tester.pumpAndSettle();

      expect(find.text('Hệ thống chưa cấu hình máy chủ gửi email.'), findsOneWidget);
    });

    testWidgets('gửi thử thành công cập nhật thời gian', (tester) async {
      await tester.pumpWidget(card(
        const AlertChannel(kind: AlertChannelKind.email, configured: true, enabled: true, email: 'a@b.vn'),
        onTest: () async => AlertTestResult(success: true, message: 'Đã gửi', lastTestedAt: DateTime(2026, 11, 6, 9, 5)),
      ));
      expect(find.text('Chưa gửi thử'), findsOneWidget);

      await tester.tap(find.text('Gửi thử'));
      await tester.pumpAndSettle();

      expect(find.text('Gửi thử gần nhất: 06/11/2026 09:05'), findsOneWidget);
    });

    testWidgets('lỗi API hiện trên thẻ', (tester) async {
      await tester.pumpWidget(card(
        const AlertChannel(kind: AlertChannelKind.email, configured: true, enabled: true, email: 'a@b.vn'),
        onSave: ({required enabled, botToken, chatId, webhookUrl, email}) async =>
            throw ApiException(statusCode: 403, code: 'FORBIDDEN', message: 'Không có quyền'),
      ));

      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Không có quyền'), findsOneWidget);
    });

    testWidgets('người không có quyền chỉ xem', (tester) async {
      await tester.pumpWidget(card(
        const AlertChannel(kind: AlertChannelKind.zalo, configured: true, enabled: true, maskedWebhookUrl: 'https://a/••'),
        canEdit: false,
      ));

      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed, isNull);
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    });
  });
}
