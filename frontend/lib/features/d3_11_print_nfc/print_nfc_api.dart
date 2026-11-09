import '../../core/api/api_client.dart';
import '../../core/config/app_config.dart';
import 'print_nfc_models.dart';

class PrintNfcApi {
  PrintNfcApi(this._api);

  final ApiClient _api;

  /// Lấy danh sách thiết kế ấn phẩm của cơ sở
  Future<List<PrintDesignDto>> getDesigns({String? businessId}) async {
    final query = businessId != null ? '?businessId=$businessId' : '';
    final res = await _api.get('/print-designs$query') as Map<String, dynamic>;
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => PrintDesignDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Lấy chi tiết một thiết kế
  Future<PrintDesignDto> getDesignById(String id) async {
    final res = await _api.get('/print-designs/$id') as Map<String, dynamic>;
    return PrintDesignDto.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Tạo hoặc cập nhật thiết kế ấn phẩm
  Future<PrintDesignDto> saveDesign(PrintDesignDto design) async {
    final res = await _api.post('/print-designs', design.toJson()) as Map<String, dynamic>;
    return PrintDesignDto.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Xóa thiết kế ấn phẩm
  Future<void> deleteDesign(String id) async {
    await _api.delete('/print-designs/$id');
  }

  /// E5.1: Lấy danh sách mã QR của chi nhánh
  Future<List<QrCodeDto>> getQrCodes({String? branchId}) async {
    final query = branchId != null ? '?branchId=$branchId' : '';
    final res = await _api.get('/qr-codes$query') as Map<String, dynamic>;
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => QrCodeDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// E5.1: Tạo mã QR mới cho chi nhánh
  Future<QrCodeDto> createQrCode(QrCodeCreateRequest request) async {
    final res = await _api.post('/qr-codes', request.toJson()) as Map<String, dynamic>;
    return QrCodeDto.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// E5.1: Đảm bảo chi nhánh có ít nhất 1 mã QR mặc định (Tạo nếu chưa có)
  Future<QrCodeDto> ensureDefaultQrCode({required String branchId}) async {
    final res = await _api.post('/qr-codes/ensure-default?branchId=$branchId', {}) as Map<String, dynamic>;
    return QrCodeDto.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Đường dẫn tải file in ấn chất lượng cao (≥ 300 DPI)
  String getExportUrl({required String designId, String format = 'pdf', int dpi = 300}) {
    return '${AppConfig.apiBaseUrl}/api/v1/print-designs/$designId/export?format=$format&dpi=$dpi';
  }

  /// Gửi đơn đặt mua phôi thẻ NFC vật lý
  Future<NfcOrderDto> createNfcOrder(NfcOrderCreateRequest request) async {
    final res = await _api.post('/nfc-orders', request.toJson()) as Map<String, dynamic>;
    return NfcOrderDto.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Lấy danh sách đơn đặt phôi thẻ NFC
  Future<List<NfcOrderDto>> getNfcOrders({String? businessId}) async {
    final query = businessId != null ? '?businessId=$businessId' : '';
    final res = await _api.get('/nfc-orders$query') as Map<String, dynamic>;
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => NfcOrderDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}

