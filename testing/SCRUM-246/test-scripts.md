# SCRUM-246 — Test scripts

## Preconditions
Run from the repository root on branch feature/D4-01-D5-11-canh-bao-dashboard-thanh-toan. Java and Maven Wrapper prerequisites must be available.

## Focused billing tests
    cd D:\Learn\CX-SHIELD\backend
    .\mvnw.cmd "-Dtest=BillingApiSecurityTest,BillingControllerTest,BillingServiceTest,VnpayCallbackServiceTest,VnpayGatewayTest" test

## Full backend test suite
    cd D:\Learn\CX-SHIELD\backend
    .\mvnw.cmd test

Record the actual Maven test counts and build result in testing/SCRUM-246/test-report.md. Do not mark a test as passed unless the run completed successfully.
