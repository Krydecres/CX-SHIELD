# SCRUM-246 — Test cases: Billing and VNPAY

## Scope
Unit tests for the billing service, controller/security boundary, VNPAY gateway, and callback processing. Cases below reflect the current backend implementation and test suite.

## Billing service
- Plans, current subscription, and billing profile are mapped from repository data; absent subscription/profile returns an empty response.
- Checkout requires an active OWNER membership, configured VNPAY and service role, an existing plan, and an offered billing cycle.
- Amount is calculated from the database plan price with 10% VAT; payment metadata and payment URL use the calculated total.
- Billing profile tax code, company name, and email are validated; new profiles are inserted and existing profiles updated.
- Payment lookup returns status messages for pending, successful, cancelled, and failed outcomes; unknown payment returns not found.

## VNPAY gateway
- Payment URL includes required VNPAY fields, VND amount in minor units, Vietnam timestamps, and a 15-minute expiry.
- HMAC-SHA512 signature matches a known value and verifies generated requests.
- Verification accepts uppercase hashes and ignores hash type/non-VNPAY parameters; tampered or missing hashes and disabled gateway are rejected.

## Callback service
- Valid success confirms payment; cancellation or non-success transaction status marks it failed.
- Invalid signature, unknown/missing transaction, incorrect or malformed amount, duplicate notification, and unexpected repository error return their expected response codes without activating payment.
- Return URL success confirms and redirects to result; invalid signature redirects with invalid=1 and does not expose the transaction code.
- Return URL cancellation marks payment failed and redirects with the transaction code.
- Return URL with incorrect amount redirects to result but does not confirm or mark payment failed.

## Controller and API security
- Controller passes user token, user/business identifiers, checkout client IP, and transaction code to the service.
- VNPAY IPN is public and uses the provider response format; Return responds with a redirect.
- Checkout/plans require login and POST to IPN is not public.
