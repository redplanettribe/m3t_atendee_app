# Run Tests and Fix Failures

## Overview

Run the full test suite for this Flutter app and its packages, then systematically fix any failures. Use the testing skill and rules (bloc_test, mocktail, test layout, buildBloc, assertions).

## Steps

1. **Run tests**
   - From the project root: `flutter test` to run app tests under `test/`.
   - For packages: `dart test` (or `flutter test`) in each of `packages/domain`, `packages/auth_repository`, `packages/m3t_api` if they have tests.
   - Capture the output and list every failing test (file and test name).

2. **Analyze failures**
   - Classify each failure: assertion error, compile error, missing mock, wrong expectation, or flaky.
   - If failures might be from recent edits, focus on those first. Otherwise start with the first failing test.

3. **Fix one failure at a time**
   - Fix the test or the production code so the test passes. Follow project conventions: private mocks (`_MockX`), `buildBloc()` for bloc_test, matchers in `expect`, no shared mutable state between tests.
   - Re-run the full suite (or at least the affected file) after each fix to avoid regressions.

4. **Re-run full suite**
   - Run `flutter test` (and package tests) again and confirm all tests pass.

## Checklist

- [ ] All tests run without compile errors
- [ ] Every failing test identified and fixed or skipped with a clear reason
- [ ] No shared mutable state or wrong mock setup in tests
- [ ] Full suite passes
