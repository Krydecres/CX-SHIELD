import 'dart:async';
import 'dart:convert';

import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/models/account_models.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuth extends Fake implements GoTrueClient {
  final events = StreamController<AuthState>.broadcast();
  int signOutCount = 0;

  @override
  Stream<AuthState> get onAuthStateChange => events.stream;

  @override
  User? get currentUser => null;

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) async => signOutCount++;
}

void main() {
  const business = {'id': 'b1', 'brandName': 'Maison'};
  const me = {
    'userId': 'u1',
    'email': 'chu@example.com',
    'onboarded': true,
    'memberships': [
      {'membershipId': 'm1', 'role': 'OWNER', 'business': business},
    ],
  };
  const branches = [
    {'id': 'c1', 'businessId': 'b1', 'code': 'CN01', 'name': 'Quận 1'},
    {'id': 'c2', 'businessId': 'b1', 'code': 'CN02', 'name': 'Quận 3'},
  ];

  late FakeAuth auth;
  late Map<String, http.Response Function()> routes;
  late SessionController session;

  http.Response ok(Object body) => http.Response.bytes(utf8.encode(jsonEncode(body)), 200);

  setUp(() {
    auth = FakeAuth();
    routes = {
      '/api/v1/me': () => ok(me),
      '/api/v1/businesses/b1/branches': () => ok(branches),
    };
    final api = ApiClient(
      baseUrl: 'http://api.test',
      accessToken: () => 'token',
      httpClient: MockClient((request) async => routes[request.url.path]!()),
    );
    session = SessionController(api: api, auth: auth);
  });

  tearDown(() {
    session.dispose();
    auth.events.close();
  });

  Session userSession(String id) => Session(
        accessToken: 'token',
        tokenType: 'bearer',
        user: User(id: id, appMetadata: const {}, userMetadata: const {}, aud: 'authenticated', createdAt: ''),
      );

  test('tải hồ sơ, cơ sở và chọn chi nhánh đầu tiên', () async {
    await session.reloadProfile();

    expect(session.status, SessionStatus.ready);
    expect(session.isOnboarded, isTrue);
    expect(session.membership?.role, 'OWNER');
    expect(session.business?.brandName, 'Maison');
    expect(session.branches, hasLength(2));
    expect(session.selectedBranch?.id, 'c1');
  });

  test('tải lại vẫn giữ chi nhánh đang chọn', () async {
    await session.reloadProfile();
    session.selectBranch(session.branches.last);

    await session.reloadProfile();

    expect(session.selectedBranch?.id, 'c2');
  });

  test('chưa có cơ sở thì không gọi danh sách chi nhánh', () async {
    routes['/api/v1/me'] = () => ok({'userId': 'u1', 'onboarded': false, 'memberships': <Object>[]});
    routes.remove('/api/v1/businesses/b1/branches');

    await session.reloadProfile();

    expect(session.status, SessionStatus.ready);
    expect(session.isOnboarded, isFalse);
    expect(session.membership, isNull);
    expect(session.selectedBranch, isNull);
  });

  test('lỗi máy chủ chuyển sang profileError', () async {
    routes['/api/v1/me'] = () => http.Response.bytes(
          utf8.encode(jsonEncode({'code': 'UPSTREAM_ERROR', 'message': 'Không kết nối được.'})),
          502,
        );

    await session.reloadProfile();

    expect(session.status, SessionStatus.profileError);
    expect(session.profileError, 'Không kết nối được.');
  });

  test('token hết hạn thì tự đăng xuất', () async {
    routes['/api/v1/me'] = () => http.Response('', 401);

    await session.reloadProfile();

    expect(auth.signOutCount, 1);
    expect(session.status, SessionStatus.signedOut);
  });

  test('chọn chi nhánh báo cho giao diện cập nhật', () async {
    await session.reloadProfile();
    var notified = 0;
    session.addListener(() => notified++);

    session.selectBranch(const Branch(id: 'c2', businessId: 'b1', code: 'CN02', name: 'Quận 3'));

    expect(session.selectedBranch?.id, 'c2');
    expect(notified, 1);
  });

  test('đăng xuất xoá toàn bộ hồ sơ', () async {
    await session.reloadProfile();

    await session.signOut();

    expect(auth.signOutCount, 1);
    expect(session.status, SessionStatus.signedOut);
    expect(session.me, isNull);
    expect(session.branches, isEmpty);
    expect(session.selectedBranch, isNull);
  });

  test('không có phiên lúc mở app thì về trạng thái chưa đăng nhập', () async {
    auth.events.add(const AuthState(AuthChangeEvent.initialSession, null));
    await pumpEventQueue();

    expect(session.status, SessionStatus.signedOut);
  });

  test('sự kiện đăng nhập tải hồ sơ', () async {
    auth.events.add(AuthState(AuthChangeEvent.signedIn, userSession('u1')));
    await pumpEventQueue();

    expect(session.status, SessionStatus.ready);
    expect(session.me?.userId, 'u1');
  });

  test('sự kiện đăng nhập lặp lại của cùng người dùng không tải lại', () async {
    await session.reloadProfile();
    var notified = 0;
    session.addListener(() => notified++);

    auth.events.add(AuthState(AuthChangeEvent.signedIn, userSession('u1')));
    await pumpEventQueue();

    expect(notified, 0);
  });

  test('sự kiện đăng xuất từ Supabase xoá hồ sơ', () async {
    await session.reloadProfile();

    auth.events.add(const AuthState(AuthChangeEvent.signedOut, null));
    await pumpEventQueue();

    expect(session.status, SessionStatus.signedOut);
    expect(session.me, isNull);
  });
}
