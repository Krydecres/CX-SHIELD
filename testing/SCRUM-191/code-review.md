# SCRUM-191 – Authentication, Authorization and Onboarding Code Review

## 1. Review Scope

Reviewed the source code related to:

- Spring Security configuration.
- JWT authentication configuration.
- API security and request validation.
- Business onboarding service.
- Existing backend unit and API tests.

## 2. Review Results

### 2.1 SecurityConfig.java

**Reviewed findings:**

- The application uses stateless session management.
- API endpoints require authentication by default.
- OPTIONS requests are permitted.
- Survey and feedback API paths are configured as public endpoints.
- JWT validation is configured with Supabase issuer, JWKS endpoint, ES256 algorithm and authenticated audience.
- CORS allowed origins are configurable.

**Items requiring further verification:**

- Confirm that public survey and feedback endpoints expose only intended operations.
- Verify actual JWT signature, issuer, audience and expiration validation.
- Verify OWNER authorization and data isolation in service, repository and database RLS policies.

### 2.2 ApiSecurityTest.java

Reviewed existing tests:

- Request without token is rejected.
- Invalid onboarding input returns HTTP 400.
- Invalid Google Place ID is rejected before database access.

**Coverage gaps:**

- Actual Supabase JWT decoder validation is not demonstrated by mocked JWT tests.
- OWNER authorization and cross-business data isolation are not verified by these tests.
- Public endpoint access and deny-all behavior need additional coverage.

### 2.3 OnboardingService.java

Reviewed logic:

- Business and branch names are normalized.
- Default branch name and primary color are applied.
- Logo URL is restricted to the current user's storage folder.
- Existing membership is checked before onboarding.
- Business creation retries on unique constraint violations.
- The first branch is created with code CN01.

**Potential risks requiring further testing:**

- Multiple memberships and membership ordering.
- Partial failure when business creation succeeds but branch creation fails.
- Retry behavior for unique constraint violations unrelated to public slug.
- Concurrent onboarding requests.
- Null or invalid input handling at the API validation layer.

### 2.4 OnboardingServiceTest.java

Reviewed existing scenarios:

- Creates business owner and first branch.
- Uses brand name when branch name is blank.
- Retries when public slug already exists.
- Rejects users who already have a business with branches.
- Resumes onboarding when an owner business has no branch.
- Rejects a logo outside the user's storage folder.
- Accepts a logo inside the user's storage folder.

## 3. Automated Test Results

| Test suite                     |     Result |
| ------------------------------ | ---------: |
| Selected backend tests         |  25 passed |
| Full backend verification      | 123 passed |
| Auth/onboarding frontend tests |  18 passed |
| Full frontend tests            |  91 passed |
| Backend failures/errors        |          0 |
| Frontend analyze               |  1 warning |

Flutter warning:
`_MissingConfigApp` is declared but not referenced in `frontend/lib/main.dart:113`.

Note: Auth/onboarding tests are included in the full frontend test count. Do not add 18 and 91 together.

## 4. Overall Assessment

The reviewed source code has a basic authentication and onboarding security structure. Existing backend and frontend automated test suites completed successfully.

However, OWNER authorization, actual Supabase JWT validation and cross-business data isolation have not been fully verified by the reviewed tests.

These items should be verified during functional testing under SCRUM-192 and supplemented with automated tests under SCRUM-193.

## 5. Status

**Code review: Completed for the files listed above.**

**Outstanding verification:**

- OWNER authorization.
- Cross-business data isolation.
- Actual Supabase authentication flows, including email/password and Google OAuth.

No confirmed security defect was established from the reviewed files. The outstanding items are verification gaps, not confirmed bugs.
