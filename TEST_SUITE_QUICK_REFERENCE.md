# Subject Management Test Suite - Quick Reference

## Test Execution Checklist

### Pre-Test Setup
- [ ] Database schema verified (user, account, subject, subject_enrollment, event_log)
- [ ] Foreign key relationships configured
- [ ] Test database seeded with fixture data
- [ ] Auth context mocking enabled
- [ ] Helper functions available (validate_subject, check_subject_permission, etc.)

### Test Files & Count

| File | Tests | Status |
|------|-------|--------|
| 3600505_subjects_POST.xs | 8 | ✓ Added |
| 3600506_subjects_GET.xs | 7 | ✓ Added |
| 3600507_subjects_id_GET.xs | 6 | ✓ Added |
| 3600508_subjects_id_PATCH.xs | 11 | ✓ Added |
| 3600509_subjects_id_DELETE.xs | 8 | ✓ Added |
| 3600510_subjects_id_enrollments_POST.xs | 9 | ✓ Added |
| 3600513_subjects_id_enrollments_enrollment_id_DELETE.xs | 10 | ✓ Added |
| test_access_control.xs | 8 | ✓ Created |
| **TOTAL** | **67** | **Ready** |

---

## Test Coverage Snapshot

### Subject Creation (8 tests)
```
✓ Valid: Required fields only          ✓ Error: Missing name
✓ Valid: All fields                     ✓ Error: Negative credits
✓ Auto-enroll creator as admin          ✓ Error: Description >1000 chars
✓ Event logging                         ✓ Verify account assignment
```

### Subject Retrieval (13 tests)
```
GET /subjects (7 tests):
✓ Get all enrolled subjects             ✓ Include subject_role
✓ Filter by account                     ✓ Required fields present
✓ Empty list when no enrollments        ✓ Exclude other accounts
✓ Exclude non-enrolled subjects

GET /subjects/{id} (6 tests):
✓ Get single subject by ID              ✓ Error: Not enrolled
✓ All fields in response                ✓ Error: Different account
✓ Error: Non-existent subject           ✓ Correct subject_role
```

### Subject Updates (11 tests)
```
✓ Update name                           ✓ Error: Non-admin
✓ Update description                    ✓ Error: Different account
✓ Update credits                        ✓ Error: Negative credits
✓ Update status (draft/active/archived) ✓ Error: Description too long
✓ Partial updates                       ✓ Error: Non-existent subject
✓ Event logging (old/new values)
```

### Subject Deletion (8 tests)
```
✓ Soft delete (default)                 ✓ Hard delete (cascade)
✓ Soft delete (explicit param)          ✓ Event logging
✓ Error: Non-admin                      ✓ Error: Different account
✓ Error: Non-existent subject
```

### User Enrollment (9 tests)
```
✓ Enroll as "learner"                   ✓ Enroll as "admin"
✓ Enroll as "instructor"                ✓ Event logging
✓ Error: Duplicate enrollment           ✓ Error: Non-existent user
✓ Error: Non-admin                      ✓ Error: Different account
✓ Error: Non-existent subject
```

### User Removal (10 tests)
```
✓ Remove learner                        ✓ Error: Non-existent enrollment
✓ Remove instructor                     ✓ Verify enrollment belongs to subject
✓ Event logging with details            ✓ Error: Different account
✓ Error: Last admin protection          ✓ Error: Non-existent subject
✓ Error: Non-admin
```

### Access Control (8 tests)
```
✓ Account boundary (subjects)           ✓ Role-based updates only
✓ Account boundary (enrollment)         ✓ Role-based enrollment only
✓ Role hierarchy (admin>inst>learner)  ✓ Learners: view not modify
✓ Cross-account prevention              ✓ Enrollment required for access
```

---

## Test Execution Order (Recommended)

### Phase 1: Foundation (15 minutes)
1. Subject Creation (8 tests) - Create test subjects
2. Subject List Retrieval (7 tests) - Verify creation worked

### Phase 2: CRUD Operations (10 minutes)
3. Subject Single Retrieval (6 tests)
4. Subject Updates (11 tests)
5. Subject Deletion (8 tests)

### Phase 3: User Management (8 minutes)
6. User Enrollment (9 tests)
7. User Removal (10 tests)

### Phase 4: Security (5 minutes)
8. Access Control (8 tests)

**Total Execution Time**: ~40 minutes for full test suite

---

## Common Test Failures & Solutions

### Failure: "Test requires mock"
**Solution**: Verify mock data is defined in db.query/db.get statements

### Failure: "User record not found"
**Solution**: Ensure test user exists in fixture data with proper account_id

### Failure: "Unauthorized: User record not found"
**Solution**: Check @auth.id is being injected properly by test framework

### Failure: "Subject not found"
**Solution**: Verify cross-account boundary check - ensure test subject in same account

### Failure: "Access denied" when expecting success
**Solution**: Verify test user has correct enrollment role in subject

### Failure: "Duplicate enrollment"
**Solution**: Ensure test users are different for each enrollment test

---

## Assertion Quick Reference

```xs
// Existence checks
expect.to_be_defined ($response.field)
expect.to_not_be_null ($response.field)
expect.to_be_null ($response.field)

// Equality checks
expect.to_equal ($response.field) { value = "expected" }
expect.to_not_equal ($response.field) { value = "unexpected" }

// Boolean checks
expect.to_be_true ($response.success)
expect.to_be_false ($response.is_archived)

// Error checks
expect.to_throw { value = "errorType" }
expect.to_throw  // any error
```

---

## Test Data Template

For manual testing, use this fixture data:

```
Test Accounts:
- account_id: 1 (Account A)
- account_id: 2 (Account B)

Test Users:
- user_id: 1, account_id: 1 (Admin User A)
- user_id: 2, account_id: 1 (Regular User A)
- user_id: 3, account_id: 1 (Instructor User A)
- user_id: 4, account_id: 1 (Learner User A)
- user_id: 100, account_id: 2 (User B - different account)

Test Subjects:
- subject_id: 1, account_id: 1, name: "Test Subject"
- subject_id: 2, account_id: 1, name: "Another Subject"

Test Enrollments:
- subject_id: 1, user_id: 1, subject_role: "admin"
- subject_id: 1, user_id: 2, subject_role: "learner"
- subject_id: 1, user_id: 3, subject_role: "instructor"
- subject_id: 2, user_id: 2, subject_role: "admin"
```

---

## Performance Notes

Expected execution times per test: **<100ms**

Total suite execution: **~40 minutes** (includes database operations)

For faster iteration during development:
- Test creation first
- Build on existing data
- Mock external calls
- Parallelize independent tests

---

## Validation Checklist

Before declaring tests as "production-ready":

### Functionality
- [ ] All 67 tests execute without errors
- [ ] Happy path tests confirm expected behavior
- [ ] Error tests trigger correct error types
- [ ] Response structures match API specs

### Performance
- [ ] No test exceeds 500ms execution time
- [ ] Cascade operations complete successfully
- [ ] Event logging doesn't impact performance
- [ ] Multi-user scenarios work correctly

### Security
- [ ] Account boundaries properly enforced
- [ ] Role-based access works as expected
- [ ] Cross-account access is blocked
- [ ] Enrollment validation prevents unauthorized access

### Data Integrity
- [ ] Soft deletes preserve data
- [ ] Hard deletes cascade properly
- [ ] Partial updates don't corrupt other fields
- [ ] Event logs capture all mutations

---

## Test Maintenance

### When to Update Tests
- API response structure changes
- New validation rules added
- Error messages modified
- New roles or statuses introduced
- Database schema changes
- Business logic updates

### How to Add New Tests
1. Locate appropriate test suite file
2. Add new `test "name" { ... }` block
3. Follow existing patterns for setup/assert
4. Use descriptive test names
5. Document what's being tested
6. Run full suite to ensure no regressions

### Documentation Updates
- Update this quick reference if test files change
- Add comments to complex test scenarios
- Document any special mocking requirements
- Keep expected test count current

---

## Support & Troubleshooting

### Key Files Location
- API endpoints: `apis/*/` (with test blocks)
- Helper functions: `functions/subject_management/`
- Access control tests: `functions/subject_management/test_access_control.xs`
- Documentation: `TEST_SUITES_DOCUMENTATION.md`

### Getting Help
1. Check test failure message for specific error
2. Review corresponding endpoint implementation
3. Verify test database has required fixture data
4. Check helper function definitions
5. Review assertion syntax and expected values

---

## Success Indicators

✓ All 67 tests passing  
✓ Code coverage >99%  
✓ All CRUD operations validated  
✓ Security boundaries enforced  
✓ Error handling comprehensive  
✓ Event logging working  
✓ Cascade operations verified  
✓ Performance acceptable  

**Target Status**: Ready for production deployment once all above indicators are met.

---

*Last Updated: March 25, 2026*  
*Test Suite Version: 1.0*  
*Status: Complete & Ready for Execution*
