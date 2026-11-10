package com.cxshield.backend.alert;

import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

/**
 * Nội dung tin cảnh báo theo mẫu X4-02.
 */
final class AlertMessages {

	static final String TEST_SUBJECT = "Tin thử từ Review Funnel";

	private static final ZoneId VIETNAM = ZoneId.of("Asia/Ho_Chi_Minh");
	private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy").withZone(VIETNAM);

	private AlertMessages() {
	}

	static String testMessage(String branchName) {
		return "Đây là tin thử từ Review Funnel. Kênh cảnh báo của chi nhánh " + branchName + " đã kết nối thành công.";
	}

	static String subject(boolean urgent, String branchName) {
		return (urgent ? "[KHẨN] " : "") + "Cảnh báo góp ý mới tại " + branchName;
	}

	/**
	 * @param phone chỉ truyền khi khách đồng ý liên hệ, null thì tin không có dòng SĐT
	 */
	static String feedbackMessage(boolean urgent, String branchName, String tableCode, int starRating, String comment,
			Instant time, String phone) {
		StringBuilder text = new StringBuilder(urgent ? "[KHẨN] CẢNH BÁO GÓP Ý MỚI\n" : "CẢNH BÁO GÓP Ý MỚI\n");
		text.append("Chi nhánh: ").append(branchName).append('\n');
		if (tableCode != null && !tableCode.isBlank()) {
			text.append("Bàn: ").append(tableCode).append('\n');
		}
		text.append("Đánh giá: ").append(starRating).append("/5 sao\n");
		if (comment != null && !comment.isBlank()) {
			text.append("Góp ý: ").append(comment).append('\n');
		}
		text.append("Thời gian: ").append(TIME_FORMAT.format(time));
		if (phone != null) {
			text.append("\nSĐT khách: ").append(phone);
		}
		return text.toString();
	}

}
