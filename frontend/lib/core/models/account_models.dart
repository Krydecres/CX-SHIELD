class Business {
  const Business({
    required this.id,
    required this.brandName,
    this.displayName,
    this.industry,
    this.phone,
    this.logoUrl,
    this.primaryColor,
  });

  factory Business.fromJson(Map<String, dynamic> json) => Business(
        id: json['id'] as String,
        brandName: json['brandName'] as String,
        displayName: json['displayName'] as String?,
        industry: json['industry'] as String?,
        phone: json['phone'] as String?,
        logoUrl: json['logoUrl'] as String?,
        primaryColor: json['primaryColor'] as String?,
      );

  final String id;
  final String brandName;
  final String? displayName;
  final String? industry;
  final String? phone;
  final String? logoUrl;
  final String? primaryColor;
}

class Membership {
  const Membership({required this.id, required this.role, required this.business});

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
        id: json['membershipId'] as String,
        role: json['role'] as String? ?? '',
        business: Business.fromJson(json['business'] as Map<String, dynamic>),
      );

  final String id;
  final String role;
  final Business business;

  bool get canManageFunnel => role == 'OWNER' || role == 'BRANCH_MANAGER';
}

class Me {
  const Me({
    required this.userId,
    this.email,
    this.fullName,
    required this.onboarded,
    required this.memberships,
  });

  factory Me.fromJson(Map<String, dynamic> json) => Me(
        userId: json['userId'] as String,
        email: json['email'] as String?,
        fullName: json['fullName'] as String?,
        onboarded: json['onboarded'] as bool? ?? false,
        memberships: (json['memberships'] as List<dynamic>? ?? [])
            .map((m) => Membership.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  final String userId;
  final String? email;
  final String? fullName;
  final bool onboarded;
  final List<Membership> memberships;

  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) return fullName!;
    return email ?? 'Người dùng';
  }
}

class Branch {
  const Branch({required this.id, required this.businessId, required this.code, required this.name, this.status});

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json['id'] as String,
        businessId: json['businessId'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        status: json['status'] as String?,
      );

  final String id;
  final String businessId;
  final String code;
  final String name;
  final String? status;
}

/// Nhãn vai trò theo sheet Thuật ngữ.
String roleLabel(String role, {int branchCount = 1}) => switch (role) {
      'OWNER' => branchCount > 1 ? 'Chủ chuỗi' : 'Chủ cơ sở',
      'BRANCH_MANAGER' => 'Quản lý chi nhánh',
      'SHIFT_MANAGER' => 'Quản lý ca',
      'CS_STAFF' => 'Nhân viên CSKH',
      'CASHIER' => 'Thu ngân',
      'SERVER' => 'Nhân viên phục vụ',
      _ => role,
    };
