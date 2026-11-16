package com.cxshield.backend.billing;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.time.format.DateTimeFormatter;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;
import org.springframework.stereotype.Service;

import com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse;

@Service
public class InvoiceExportService {

	private static final DecimalFormat MONEY_FMT = new DecimalFormat("#,###");
	private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

	/**
	 * Xuất file hóa đơn điện tử VAT dưới định dạng PDF chuẩn A4
	 */
	public byte[] exportPdf(InvoiceResponse invoice) throws IOException {
		try (PDDocument document = new PDDocument()) {
			PDPage page = new PDPage(PDRectangle.A4);
			document.addPage(page);

			try (PDPageContentStream content = new PDPageContentStream(document, page)) {
				PDType1Font fontBold = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
				PDType1Font fontRegular = new PDType1Font(Standard14Fonts.FontName.HELVETICA);
				PDType1Font fontItalic = new PDType1Font(Standard14Fonts.FontName.HELVETICA_OBLIQUE);

				float y = 790;

				// Header
				content.beginText();
				content.setFont(fontBold, 18);
				content.newLineAtOffset(50, y);
				content.showText("HOA DON GIA TRI GIA TANG (VAT INVOICE)");
				content.endText();

				y -= 22;
				content.beginText();
				content.setFont(fontItalic, 10);
				content.newLineAtOffset(50, y);
				content.showText("Ban the hien cua hoa don dien tu - Kho ky hieu: CS/26E - Mau so: 01GTKT0/001");
				content.endText();

				y -= 18;
				content.beginText();
				content.setFont(fontBold, 12);
				content.newLineAtOffset(50, y);
				content.showText("So hoa don: " + invoice.invoiceNumber());
				content.endText();

				y -= 16;
				content.beginText();
				content.setFont(fontRegular, 10);
				content.newLineAtOffset(50, y);
				String dateStr = invoice.issuedAt() != null ? invoice.issuedAt().format(DATE_FMT) : "Hom nay";
				content.showText("Ngay lap: " + dateStr + "  |  Ma giao dich: " + invoice.transactionCode());
				content.endText();

				// Line separator
				y -= 12;
				content.moveTo(50, y);
				content.lineTo(545, y);
				content.stroke();

				// Đơn vị bán hàng
				y -= 22;
				content.beginText();
				content.setFont(fontBold, 11);
				content.newLineAtOffset(50, y);
				content.showText("DON VI BAN HANG: CONG TY CO PHAN CONG NGHE CX-SHIELD");
				content.endText();

				y -= 16;
				content.beginText();
				content.setFont(fontRegular, 10);
				content.newLineAtOffset(50, y);
				content.showText("Ma so thue: 0318999888  |  Website: https://cxshield.vn");
				content.endText();

				y -= 16;
				content.beginText();
				content.setFont(fontRegular, 10);
				content.newLineAtOffset(50, y);
				content.showText("Dia chi: Tang 8, Toa nha Saigon Center, 65 Le Loi, Quan 1, TP. Ho Chi Minh");
				content.endText();

				// Line separator
				y -= 12;
				content.moveTo(50, y);
				content.lineTo(545, y);
				content.stroke();

				// Thông tin người mua
				y -= 22;
				content.beginText();
				content.setFont(fontBold, 11);
				content.newLineAtOffset(50, y);
				content.showText("DON VI MUA HANG (KHACH HANG)");
				content.endText();

				y -= 16;
				content.beginText();
				content.setFont(fontRegular, 10);
				content.newLineAtOffset(50, y);
				String comp = invoice.companyName() != null ? invoice.companyName() : (invoice.buyerName() != null ? invoice.buyerName() : "Khach hang ca nhan");
				content.showText("Ten don vi/Nguoi mua: " + sanitizeText(comp));
				content.endText();

				if (invoice.taxCode() != null && !invoice.taxCode().isBlank()) {
					y -= 16;
					content.beginText();
					content.setFont(fontRegular, 10);
					content.newLineAtOffset(50, y);
					content.showText("Ma so thue: " + invoice.taxCode());
					content.endText();
				}

				if (invoice.companyAddress() != null && !invoice.companyAddress().isBlank()) {
					y -= 16;
					content.beginText();
					content.setFont(fontRegular, 10);
					content.newLineAtOffset(50, y);
					content.showText("Dia chi: " + sanitizeText(invoice.companyAddress()));
					content.endText();
				}

				if (invoice.billingEmail() != null && !invoice.billingEmail().isBlank()) {
					y -= 16;
					content.beginText();
					content.setFont(fontRegular, 10);
					content.newLineAtOffset(50, y);
					content.showText("Email nhan hoa don: " + invoice.billingEmail());
					content.endText();
				}

				// Chi tiết dịch vụ
				y -= 25;
				content.moveTo(50, y);
				content.lineTo(545, y);
				content.stroke();

				y -= 18;
				content.beginText();
				content.setFont(fontBold, 10);
				content.newLineAtOffset(50, y);
				content.showText("STT   TEN HANG HOA, DICH VU               SO LUONG    DON GIA (VND)    THANH TIEN (VND)");
				content.endText();

				y -= 8;
				content.moveTo(50, y);
				content.lineTo(545, y);
				content.stroke();

				y -= 18;
				content.beginText();
				content.setFont(fontRegular, 10);
				content.newLineAtOffset(50, y);
				String subtotalStr = MONEY_FMT.format(invoice.subtotal()) + " d";
				content.showText(" 1    Goi thue bao CX-SHIELD (SaaS)           1        " + subtotalStr + "      " + subtotalStr);
				content.endText();

				y -= 14;
				content.moveTo(50, y);
				content.lineTo(545, y);
				content.stroke();

				// Tổng cộng
				y -= 20;
				content.beginText();
				content.setFont(fontRegular, 10);
				content.newLineAtOffset(280, y);
				content.showText("Cong tien dich vu (chua VAT): " + MONEY_FMT.format(invoice.subtotal()) + " VND");
				content.endText();

				y -= 16;
				content.beginText();
				content.setFont(fontRegular, 10);
				content.newLineAtOffset(280, y);
				content.showText("Thue suat GTGT (10%):         " + MONEY_FMT.format(invoice.vatAmount()) + " VND");
				content.endText();

				y -= 18;
				content.beginText();
				content.setFont(fontBold, 11);
				content.newLineAtOffset(280, y);
				content.showText("TONG TIEN THANH TOAN:        " + MONEY_FMT.format(invoice.totalAmount()) + " VND");
				content.endText();

				// Ký số
				y -= 50;
				content.beginText();
				content.setFont(fontItalic, 9);
				content.newLineAtOffset(50, y);
				content.showText("Hoa don dien tu duoc ky boi: CONG TY CO PHAN CONG NGHE CX-SHIELD");
				content.endText();

				y -= 14;
				content.beginText();
				content.setFont(fontRegular, 9);
				content.newLineAtOffset(50, y);
				content.showText("Ngay ky: " + dateStr + " - Chu ky so hop le theo quy dinh cua Tong cuc Thue.");
				content.endText();
			}

			ByteArrayOutputStream out = new ByteArrayOutputStream();
			document.save(out);
			return out.toByteArray();
		}
	}

	/**
	 * Xuất file XML hóa đơn điện tử chuẩn thông tư 78/2021/TT-BTC
	 */
	public byte[] exportXml(InvoiceResponse invoice) {
		String dateStr = invoice.issuedAt() != null
				? invoice.issuedAt().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME)
				: "2026-11-09T00:00:00+07:00";

		String xml = """
				<?xml version="1.0" encoding="UTF-8"?>
				<HDon xmlns="http://laphoadon.gdt.gov.vn/2021/08/invoices">
				  <TTChung>
				    <PBan>2.0.0</PBan>
				    <THDon>Hóa đơn giá trị gia tăng</THDon>
				    <KHMSHDon>1</KHMSHDon>
				    <KHHDon>CS/26E</KHHDon>
				    <SHDon>%s</SHDon>
				    <NLap>%s</NLap>
				    <DVTTe>VND</DVTTe>
				    <TGia>1</TGia>
				  </TTChung>
				  <NDHDon>
				    <NBan>
				      <Ten>CÔNG TY CỔ PHẦN CÔNG NGHỆ CX-SHIELD</Ten>
				      <MST>0318999888</MST>
				      <DChi>Tầng 8, Tòa nhà Saigon Center, 65 Lê Lợi, Quận 1, TP. Hồ Chí Minh</DChi>
				      <SDThoai>1900 6868</SDThoai>
				      <DCTDTu>cskh@cxshield.vn</DCTDTu>
				    </NBan>
				    <NMua>
				      <Ten>%s</Ten>
				      <MST>%s</MST>
				      <DChi>%s</DChi>
				      <DCTDTu>%s</DCTDTu>
				    </NMua>
				    <DSHangHoa>
				      <HHDVu>
				        <STT>1</STT>
				        <THang>Gói thuê bao phần mềm CX-SHIELD (SaaS)</THang>
				        <DVTinh>Gói</DVTinh>
				        <SLuong>1</SLuong>
				        <DGia>%d</DGia>
				        <ThTien>%d</ThTien>
				        <TSuat>10%%</TSuat>
				      </HHDVu>
				    </DSHangHoa>
				    <TToan>
				      <TgTCThue>%d</TgTCThue>
				      <TgTThue>%d</TgTThue>
				      <TgTTTBSo>%d</TgTTTBSo>
				    </TToan>
				  </NDHDon>
				  <DSCKS>
				    <NBan>
				      <Signature>Signed by CX-SHIELD Corp CA</Signature>
				    </NBan>
				  </DSCKS>
				</HDon>
				""".formatted(
				invoice.invoiceNumber(),
				dateStr,
				escapeXml(invoice.companyName() != null ? invoice.companyName() : (invoice.buyerName() != null ? invoice.buyerName() : "Khách hàng")),
				escapeXml(invoice.taxCode() != null ? invoice.taxCode() : ""),
				escapeXml(invoice.companyAddress() != null ? invoice.companyAddress() : ""),
				escapeXml(invoice.billingEmail() != null ? invoice.billingEmail() : ""),
				invoice.subtotal(),
				invoice.subtotal(),
				invoice.subtotal(),
				invoice.vatAmount(),
				invoice.totalAmount()
		);

		return xml.getBytes(StandardCharsets.UTF_8);
	}

	private static String sanitizeText(String text) {
		if (text == null) return "";
		// Bỏ dấu tiếng Việt cho PDF font chuẩn Standard14Fonts nếu cần
		return text.replaceAll("[àáạảãâầấậẩẫăằắặẳẵ]", "a")
				.replaceAll("[èéẹẻẽêềếệểễ]", "e")
				.replaceAll("[ìíịỉĩ]", "i")
				.replaceAll("[òóọỏõôồốộổỗơờớợởỡ]", "o")
				.replaceAll("[ùúụủũưừứựửữ]", "u")
				.replaceAll("[ỳýỵỷỹ]", "y")
				.replaceAll("[đ]", "d")
				.replaceAll("[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]", "A")
				.replaceAll("[ÈÉẸẺẼÊỀẾỆỂỄ]", "E")
				.replaceAll("[ÌÍỊỈĨ]", "I")
				.replaceAll("[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]", "O")
				.replaceAll("[ÙÚỤỦŨƯỪỨỰỬỮ]", "U")
				.replaceAll("[ỲÝỴỶỸ]", "Y")
				.replaceAll("[Đ]", "D");
	}

	private static String escapeXml(String text) {
		if (text == null) return "";
		return text.replace("&", "&amp;")
				.replace("<", "&lt;")
				.replace(">", "&gt;")
				.replace("\"", "&quot;")
				.replace("'", "&apos;");
	}
}
