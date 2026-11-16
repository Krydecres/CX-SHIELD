package com.cxshield.backend.billing;

import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.cxshield.backend.billing.dto.BillingDtos.VnpayIpnResponse;

@SpringBootTest
@AutoConfigureMockMvc
class BillingApiSecurityTest {

	@Autowired
	private MockMvc mockMvc;

	@MockitoBean
	private VnpayCallbackService callbackService;

	@Test
	void ipnIsPublicAndUsesVnpayResponseFormat() throws Exception {
		when(callbackService.handleIpn(anyMap())).thenReturn(new VnpayIpnResponse("97", "Invalid Checksum"));

		mockMvc.perform(get("/api/v1/payments/vnpay/ipn").param("vnp_TxnRef", "CX1"))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.RspCode").value("97"))
			.andExpect(jsonPath("$.Message").value("Invalid Checksum"));
	}

	@Test
	void returnRedirectsBrowser() throws Exception {
		when(callbackService.handleReturn(anyMap())).thenReturn("http://localhost:3000/#/billing/plans/result?code=CX1");

		mockMvc.perform(get("/api/v1/payments/vnpay/return").param("vnp_TxnRef", "CX1"))
			.andExpect(status().isFound())
			.andExpect(header().string("Location", "http://localhost:3000/#/billing/plans/result?code=CX1"));
	}

	@Test
	void checkoutNeedsLogin() throws Exception {
		mockMvc.perform(post("/api/v1/businesses/" + UUID.randomUUID() + "/checkouts")).andExpect(status().isUnauthorized());
	}

	@Test
	void plansNeedLogin() throws Exception {
		mockMvc.perform(get("/api/v1/plans")).andExpect(status().isUnauthorized());
	}

	@Test
	void postToCallbackIsNotPublic() throws Exception {
		mockMvc.perform(post("/api/v1/payments/vnpay/ipn")).andExpect(status().isUnauthorized());
	}

}
