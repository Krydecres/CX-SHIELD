package com.cxshield.backend.alert;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;
import com.cxshield.backend.config.CxShieldProperties;

/**
 * Gửi tin qua SMTP. Chỉ hoạt động khi đã cấu hình MAIL_HOST và MAIL_FROM.
 */
@Component
public class EmailAlertSender implements AlertSender {

	private final ObjectProvider<JavaMailSender> mailSender;
	private final CxShieldProperties.Mail mail;

	public EmailAlertSender(ObjectProvider<JavaMailSender> mailSender, CxShieldProperties properties) {
		this.mailSender = mailSender;
		this.mail = properties.mail();
	}

	@Override
	public AlertChannelType type() {
		return AlertChannelType.EMAIL;
	}

	@Override
	public void send(AlertChannelRow channel, String subject, String text) {
		JavaMailSender sender = mailSender.getIfAvailable();
		if (sender == null || mail == null || !mail.enabled()) {
			throw new AlertSendException("Hệ thống chưa cấu hình máy chủ gửi email.");
		}
		SimpleMailMessage message = new SimpleMailMessage();
		message.setFrom(mail.from());
		message.setTo(channel.email());
		message.setSubject(subject);
		message.setText(text);
		try {
			sender.send(message);
		}
		catch (MailException ex) {
			throw new AlertSendException("Không gửi được email, kiểm tra lại địa chỉ nhận.");
		}
	}

	@Override
	public String recipient(AlertChannelRow channel) {
		return channel.email();
	}

}
