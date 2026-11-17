# SCRUM-248 — Test cases automation thanh toán và kích hoạt thuê bao

## Phạm vi

Automation backend cho tạo checkout, lưu hồ sơ hóa đơn, xử lý VNPAY callback/IPN, chống xử lý lặp và gọi RPC xác nhận/kích hoạt. Toàn bộ kiểm thử dùng mock; không gọi cổng thanh toán hoặc cơ sở dữ liệu thật.

| ID | Test case | Kiểm tra chính | Kết quả mong đợi | Kết quả chạy |
|---|---|---|---|---|
| TC-01 | Tạo lệnh thanh toán theo gói và chu kỳ | `BillingServiceTest.checkoutCalculatesAmountFromPlanWithVat` | Lưu payment PENDING đúng số tiền, gói, business, chu kỳ; trả payment URL | PASS |
| TC-02 | Lưu mới thông tin xuất hóa đơn | `BillingServiceTest.savesNewBillingProfile` | Lưu mã số thuế, tên công ty, email và business | PASS |
| TC-03 | Cập nhật hồ sơ hóa đơn đã có | `BillingServiceTest.updatesExistingBillingProfile` | Cập nhật hồ sơ hiện hữu, không tạo bản ghi mới | PASS |
| TC-04 | Dữ liệu hóa đơn không hợp lệ | `BillingServiceTest.validatesBillingProfile` | Mã số thuế, tên công ty hoặc email sai bị từ chối; không tạo payment | PASS |
| TC-05 | Webhook thành công | `VnpayCallbackServiceTest.successfulPaymentActivatesSubscription` | Gọi xác nhận thành công với transaction/gateway code; không đánh dấu lỗi | PASS — RPC mock |
| TC-06 | Webhook báo thanh toán thất bại | `VnpayCallbackServiceTest.failedPaymentDoesNotActivate` | Đánh dấu FAILED; không gọi RPC thành công | PASS |
| TC-07 | Người dùng hủy thanh toán | `VnpayCallbackServiceTest.cancelledPaymentDoesNotActivate` | Đánh dấu FAILED với mã hủy; không gọi RPC thành công | PASS |
| TC-08 | Callback báo thành công nhưng transaction status lỗi | `VnpayCallbackServiceTest.successResponseCodeWithFailedTransactionStatusDoesNotActivate` | Không kích hoạt; ghi nhận lỗi | PASS |
| TC-09 | Gửi lặp webhook sau lần thành công | `VnpayCallbackServiceTest.notificationRepeatedAfterSuccessOnlyActivatesOnce` | Lần đầu xác nhận; lần lặp không gọi RPC lần hai | PASS — mock trạng thái |
| TC-10 | Chữ ký callback sai | `VnpayCallbackServiceTest.invalidSignatureChangesNothing` | Trả mã chữ ký sai; không tra cứu/ghi payment và không kích hoạt | PASS |
| TC-11 | Số tiền callback không khớp | `VnpayCallbackServiceTest.wrongAmountDoesNotActivate` | Từ chối callback; không gọi RPC xác nhận | PASS |
| TC-12 | Ánh xạ thông tin xác nhận sang RPC kích hoạt | `PaymentAdminRepositoryTest.confirmSuccessCallsAtomicActivationRpcWithGatewayDetails` | Gọi `confirm_payment_success` với transaction code, gateway ID, response code chính xác | PASS — RPC mock |

## Giới hạn

Các test callback và repository sử dụng mock, nên xác minh luồng backend gọi RPC đúng nhưng không chạy hàm PostgreSQL trên database thật. Chưa chạy giao dịch sandbox E2E. Test dùng dữ liệu tổng hợp; không chứa thông tin xác thực hay secret.
