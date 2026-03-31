## 1. Database Schema

- [x] 1.1 Create `subject` table with fields: id, name, description, credits, status, account_id, created_at, updated_at, and required indexes
- [x] 1.2 Create `subject_enrollment` junction table with fields: id, subject_id, user_id, subject_role, created_at, account_id, and required indexes
- [x] 1.3 Verify table relationships and permissions via Xano backend

## 2. Core Functions

- [x] 2.1 Create `validate_subject` function to validate subject input (name required, credits >= 0, etc.)
- [x] 2.2 Create `auto_enroll_subject_creator` function to automatically enroll a user as subject admin when creating a subject
- [x] 2.3 Create `check_subject_permission` function to verify user has required role on a subject (learner, instructor, admin)
- [x] 2.4 Create `log_subject_event` function wrapper to standardize event logging for subject operations

## 3. Subject CRUD APIs

- [x] 3.1 Create POST `/api/subjects` - create new subject (auto-enroll creator as admin, log event)
- [x] 3.2 Create GET `/api/subjects` - list user's enrolled subjects (filter by account, include enrollment role)
- [x] 3.3 Create GET `/api/subjects/:id` - get subject details (verify user has access, include enrollment info)
- [x] 3.4 Create PATCH `/api/subjects/:id` - update subject metadata (admin only, log changes)
- [x] 3.5 Create DELETE `/api/subjects/:id` - soft delete subject or hard delete (admin only, handle cascade)

## 4. Subject Enrollment APIs

- [x] 4.1 Create POST `/api/subjects/:id/enrollments` - enroll user in subject (admin only, log event, prevent duplicates)
- [x] 4.2 Create GET `/api/subjects/:id/enrollments` - list enrolled users for a subject (admin can view all, members see partial)
- [x] 4.3 Create PATCH `/api/subjects/:id/enrollments/:enrollment_id` - update user's subject role (admin only)
- [x] 4.4 Create DELETE `/api/subjects/:id/enrollments/:enrollment_id` - remove user from subject (admin only, prevent removing all admins, log event)

## 5. Helper Functions & Addons

- [x] 5.1 Create addon to fetch enrollment count for a subject
- [x] 5.2 Create addon to fetch enrolled users summary (names and roles) for a subject
- [x] 5.3 Create `get_user_subjects` helper function for efficient subject list retrieval with enrollment details

## 6. Testing

- [x] 6.1 Write tests for subject creation (valid/invalid inputs, auto-enrollment, logging)
- [x] 6.2 Write tests for subject retrieval (access control, filters, returned fields)
- [x] 6.3 Write tests for subject updates (permission checks, validation, logging)
- [x] 6.4 Write tests for subject deletion (cascading, logging, state cleanup)
- [x] 6.5 Write tests for user enrollment (duplicates, role assignment, validation, logging)
- [x] 6.6 Write tests for user removal (cascade, admin-only check, event logging)
- [x] 6.7 Write tests for access control (account boundary, unauthorized access, role-based permissions)

## 7. Integration & Documentation

- [x] 7.1 Verify event logging integration (check event_log table records all subject operations)
- [x] 7.2 Test with existing role_based_access_control function to ensure compatibility
- [x] 7.3 Generate API documentation for subject endpoints (input/output schemas, authentication requirements)
- [x] 7.4 Create developer guide for extending subject management (e.g., grades, attendance)
- [x] 7.5 Push all changes to Xano backend and verify synchronization
