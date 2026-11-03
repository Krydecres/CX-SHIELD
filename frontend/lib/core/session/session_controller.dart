import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';
import '../models/account_models.dart';

enum SessionStatus { initializing, signedOut, loadingProfile, ready, profileError }

/// Trạng thái đăng nhập + hồ sơ (cơ sở, chi nhánh đang chọn) dùng chung cho router và khung admin.
class SessionController extends ChangeNotifier {
  SessionController({required this.api, GoTrueClient? auth}) : _auth = auth ?? Supabase.instance.client.auth {
    _subscription = _auth.onAuthStateChange.listen(_onAuthChange);
  }

  final ApiClient api;
  final GoTrueClient _auth;
  late final StreamSubscription<AuthState> _subscription;

  SessionStatus status = SessionStatus.initializing;
  Me? me;
  List<Branch> branches = const [];
  Branch? selectedBranch;
  String? profileError;

  Membership? get membership => me == null || me!.memberships.isEmpty ? null : me!.memberships.first;
  Business? get business => membership?.business;
  bool get isOnboarded => me?.onboarded ?? false;
  User? get user => _auth.currentUser;

  void _onAuthChange(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
        if (state.session == null) {
          _clear();
        } else if (status != SessionStatus.ready || me?.userId != state.session!.user.id) {
          unawaited(reloadProfile());
        }
      case AuthChangeEvent.signedOut:
        _clear();
      default:
        break;
    }
  }

  Future<void> reloadProfile() async {
    status = SessionStatus.loadingProfile;
    profileError = null;
    notifyListeners();
    try {
      final loaded = Me.fromJson(await api.get('/me') as Map<String, dynamic>);
      var loadedBranches = const <Branch>[];
      if (loaded.memberships.isNotEmpty) {
        final list = await api.get('/businesses/${loaded.memberships.first.business.id}/branches') as List<dynamic>;
        loadedBranches = list.map((b) => Branch.fromJson(b as Map<String, dynamic>)).toList();
      }
      me = loaded;
      branches = loadedBranches;
      selectedBranch = loadedBranches.where((b) => b.id == selectedBranch?.id).firstOrNull ?? loadedBranches.firstOrNull;
      status = SessionStatus.ready;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await signOut();
        return;
      }
      profileError = e.message;
      status = SessionStatus.profileError;
    }
    notifyListeners();
  }

  void selectBranch(Branch branch) {
    selectedBranch = branch;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _clear();
  }

  void _clear() {
    me = null;
    branches = const [];
    selectedBranch = null;
    profileError = null;
    status = SessionStatus.signedOut;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
