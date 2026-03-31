# Developer Guide: Subject Management

This guide explains the architecture, patterns, and how to extend the Subject Management feature for EduTrack-ai.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Database Schema](#database-schema)
3. [Core Functions](#core-functions)
4. [API Patterns](#api-patterns)
5. [Event Logging](#event-logging)
6. [Extending Subject Management](#extending-subject-management)
7. [Common Tasks](#common-tasks)
8. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

The Subject Management feature is built on a layered architecture:

```
┌─────────────────────────────────────────┐
│         REST API Layer                  │
│  (CRUD endpoints + Enrollments)        │
└──────────────────┬──────────────────────┘
                   ▼
┌─────────────────────────────────────────┐
│      Core Functions Layer               │
│  (validation, permissions, logging)    │
└──────────────────┬──────────────────────┘
                   ▼
┌─────────────────────────────────────────┐
│    Database Layer (Tables + Indexes)    │
│  (subject, subject_enrollment)         │
└─────────────────────────────────────────┘
```

### Design Principles

1. **Separation of Concerns**: API layer calls core functions; functions perform business logic
2. **Account Isolation**: All data filtered by account_id; users can only access their account's subjects
3. **Role Hierarchy**: subject_role defines permissions (admin > instructor > learner)
4. **Audit Trail**: All mutations logged to event_log table with metadata
<!-- 5. **Reusable Functions**: Core functions callable from APIs, tasks, or other functions -->

---

## Database Schema

### Subject Table
```xanoscript
table subject {
  schema {
    int id                              // Primary key
    text name filters=trim              // Subject name (required)
    text description?                   // Optional description
    int credits?                        // Optional credit hours
    enum status?                        // "draft", "active", "archived"
    int account_id                      // Foreign key to account
    timestamp created_at = now()        // Auto-populated
    timestamp updated_at?               // Auto-updated
  }

  index = [
    {type: "primary", field: [{name: "id"}]},
    {type: "btree", field: [{name: "account_id"}]},
    {type: "unique", field: [{name: "account_id"}, {name: "name"}]},
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}
```

**Key Points:**
- `account_id` is required; subjects always belong to an account
- Unique constraint on (account_id, name) prevents duplicate subject names per account
- `status` field enables soft deletes and future state management

### SubjectEnrollment Table
```xanoscript
table subject_enrollment {
  schema {
    int id                              // Primary key
    int subject_id                      // Foreign key to subject
    int user_id                         // Foreign key to user
    enum subject_role                   // "learner", "instructor", "admin"
    int account_id                      // De-normalized for filtering/auditing
    timestamp created_at = now()        // Auto-populated
  }

  index = [
    {type: "primary", field: [{name: "id"}]},
    {type: "unique", field: [{name: "subject_id"}, {name: "user_id"}]},
    {type: "btree", field: [{name: "account_id"}]},
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}
```

**Key Points:**
- Unique constraint on (subject_id, user_id) prevents duplicate enrollments
- `account_id` de-normalized for efficient filtering
- Created_at timestamp enables timeline queries (new students first)

---

## Core Functions

All business logic is centralized in reusable functions in `/functions/subject_management/`:

### 1. validate_subject(name, description, credits)
Validates subject input before creation/updates.

**Usage:**
```xanoscript
function.run "subject_management/validate_subject" {
  name = $input.name
  description = $input.description
  credits = $input.credits
} as $validation

if (!$validation.is_valid) {
  error {
    error_type = "inputerror"
    error = $validation.errors|first
  }
}
```

**Returns:**
```json
{
  "is_valid": true/false,
  "errors": ["error1", "error2"]
}
```

### 2. check_subject_permission(user_id, subject_id, required_role)
Checks if user has required role on a subject. Supports hierarchical role checking.

**Usage:**
```xanoscript
function.run "subject_management/check_subject_permission" {
  user_id = @auth.id
  subject_id = $path.id
  required_role = "admin"  // Can be "learner", "instructor", "admin", or "any"
} as $permission

if (!$permission.has_permission) {
  error {
    error_type = "accesserror"
    error = "You do not have permission to perform this action"
  }
}
```

**Returns:**
```json
{
  "has_permission": true/false,
  "user_role": "admin"  // null if not enrolled
}
```

### 3. auto_enroll_subject_creator(subject_id, user_id, account_id)
Automatically enrolls the subject creator as an admin. Called when creating new subject.

**Usage:**
```xanoscript
function.run "subject_management/auto_enroll_subject_creator" {
  subject_id = $output.id
  user_id = @auth.id
  account_id = @auth.account_id
} as $enrollment

if (!$enrollment.success) {
  error {
    error_type = "databaseerror"
    error = $enrollment.error
  }
}
```

**Returns:**
```json
{
  "success": true/false,
  "enrollment_id": 110001,
  "error": null
}
```

### 4. log_subject_event(action, user_id, subject_id, enrollment_id, details)
Standardized event logging for all subject operations.

**Usage:**
```xanoscript
function.run "subject_management/log_subject_event" {
  action = "subject.created"
  user_id = @auth.id
  subject_id = $output.id
  details = {
    name = $input.name,
    credits = $input.credits
  }
} as $event

// Optionally verify logging succeeded
if (!$event.success) {
  log.warning ("Failed to log subject event: " ~ $event.error)
}
```

**Returns:**
```json
{
  "success": true/false,
  "event_id": 50001,
  "error": null
}
```

---

## API Patterns

All APIs follow consistent patterns:

### Authentication
```xanoscript
api "/api/subjects" {
  auth = "user"  // Requires authenticated user
}
```

### Account Boundary Checking
Always verify user's account matches resource's account:

```xanoscript
db.get subject { ... } as $subject

precondition ($subject.account_id == @auth.account_id) {
  error_type = "accesserror"
  error = "Subject not found"  // Don't reveal account isolation
}
```

### Input Validation
Use the validate_subject function for all subject inputs:

```xanoscript
function.run "subject_management/validate_subject" {
  name = $input.name
  description = $input.description
  credits = $input.credits
} as $validation

precondition ($validation.is_valid) {
  error_type = "inputerror"
  error = $validation.errors|first
}
```

### Permission Checking
Use check_subject_permission for role-based access:

```xanoscript
function.run "subject_management/check_subject_permission" {
  user_id = @auth.id
  subject_id = $path.id
  required_role = "admin"
} as $permission

precondition ($permission.has_permission) {
  error_type = "accesserror"
  error = "Insufficient permissions"
}
```

### Event Logging
Log all mutations (create, update, delete, enroll, remove):

```xanoscript
function.run "subject_management/log_subject_event" {
  action = "subject.created"
  user_id = @auth.id
  subject_id = $output.id
  details = {created_name = $input.name}
}
```

---

## Event Logging

All subject operations are logged to the `event_log` table for audit trails.

### Event Actions

| Action | Trigger | Metadata Content |
|--------|---------|------------------|
| `subject.created` | New subject created | subject_id, name, credits |
| `subject.updated` | Subject modified | subject_id, old_values, new_values |
| `subject.deleted` | Subject deleted | subject_id, hard_delete (bool) |
| `subject.enrollment.added` | User enrolled | subject_id, user_id, subject_role |
| `subject.enrollment.updated` | Role changed | subject_id, user_id, old_role, new_role |
| `subject.enrollment.removed` | User removed | subject_id, user_id, was_role |

### Event Metadata Structure

```json
{
  "subject_id": 753414,
  "user_id": 1001,
  "enrollment_id": null,
  "old_values": { "name": "Old Name" },
  "new_values": { "name": "New Name" },
  "extra": "any other relevant data"
}
```

### Querying Events

```xanoscript
// Get all subject operations for an account
db.query event_log {
  where = {
    account_id = 1001,
    action = ["subject.created", "subject.updated", "subject.deleted"]|contains:$row.action
  }
  order_by = {field: "created_at", direction: "desc"}
} as $events

// Get all enrollment changes for a subject
db.query event_log {
  where = {
    account_id = 1001,
    metadata->>'subject_id' = "753414",
    action = ["subject.enrollment.added", "subject.enrollment.removed"]|contains:$row.action
  }
} as $enrollment_history
```

---

## Extending Subject Management

### Adding Subject Grades

To add grade tracking to subjects:

1. **Create new table**: `subject_grade`
   ```xanoscript
   table subject_grade {
     schema {
       int id
       int subject_id              // FK to subject
       int user_id                 // FK to user
       int enrollment_id           // FK to subject_enrollment
       float grade                 // 0.0 - 100.0
       text letter_grade?          // A, B, C, etc.
       timestamp recorded_at = now()
     }
   }
   ```

2. **Create API endpoint**: `POST /api/subjects/:id/grades`
   - Require instructor or admin role
   - Log event: `subject.grade.recorded`
   - Validate grade range

3. **Update enrollment API**: Add `grades` field to enrollment response using addon

### Adding Attendance Tracking

To add attendance to subjects:

1. **Create new tables**:
   - `subject_attendance_session`: class sessions
   - `subject_attendance_record`: who attended

2. **Create API endpoints**:
   - `POST /api/subjects/:id/attendance-sessions`
   - `POST /api/subjects/:id/attendance-sessions/:session_id/attendance`

3. **Create task**: Auto-generate absent records for students

### Adding Assignment Management

1. **Create table**: `subject_assignment` with deadline, description
2. **Create API endpoints**: CRUD for assignments, submit assignment
3. **Create task**: Auto-mark past-due assignments

### Adding Discussion Forums

1. **Create table**: `subject_discussion` (threads + posts)
2. **Create API endpoints**: Post/reply/search discussions
3. **Add moderation**: Admin-only approval for sensitive discussions

---

## Common Tasks

### Task 1: Create Subject (by Teacher)

**API Call:**
```bash
curl -X POST http://api/api/subjects \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Biology 101",
    "description": "Introduction to Biology",
    "credits": 4
  }'
```

**Behind the scenes:**
1. validate_subject() checks inputs
2. Create subject record
3. auto_enroll_subject_creator() adds creator as admin
4. log_subject_event() records "subject.created"

### Task 2: Enroll Students (by Teacher)

**API Call:**
```bash
curl -X POST http://api/api/subjects/753414/enrollments \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1005,
    "subject_role": "learner"
  }'
```

**Behind the scenes:**
1. check_subject_permission() verifies caller is admin
2. Validate user is in same account
3. Prevent duplicates
4. Create subject_enrollment record
5. log_subject_event() records "subject.enrollment.added"

### Task 3: Student Views Their Courses

**API Call:**
```bash
curl -X GET http://api/api/subjects \
  -H "Authorization: Bearer {token}"
```

**Behind the scenes:**
1. get_user_subjects() queries efficient single query
2. Join subject with subject_enrollment
3. Filter by user_id and account_id
4. Return subjects with student's role

---

## Troubleshooting

### Issue: User can't see a subject they're enrolled in

**Causes:**
1. Subject marked as "archived" (soft deleted)
2. Enrollment record doesn't exist
3. User in different account
4. Database index issue

**Debug:**
```xanoscript
// Check subject exists and is active
db.get subject {
  field_name = "id"
  field_value = 753414
} as $subject
log("Subject status: " ~ $subject.status)

// Check enrollment exists
db.query subject_enrollment {
  where = {subject_id = 753414, user_id = @auth.id}
} as $enrollments
log("Enrollments found: " ~ $enrollments|count)

// Verify accounts match
log("User account: " ~ @auth.account_id)
log("Subject account: " ~ $subject.account_id)
```

### Issue: Permission denied on subject update

**Causes:**
1. User not enrolled as admin
2. Using wrong subject_id
3. User from different account

**Debug:**
```xanoscript
function.run "subject_management/check_subject_permission" {
  user_id = @auth.id
  subject_id = $path.id
  required_role = "admin"
} as $perm
log("Has permission: " ~ $perm.has_permission)
log("User role: " ~ $perm.user_role)
```

### Issue: Can't remove last admin from subject

**Expected behavior**: This is intentional - prevents orphaning subjects. Every subject must have at least one admin.

**Solution**: First promote another member to admin, then remove the original admin.

### Issue: Event not logged

**Causes:**
1. log_subject_event() function failed silently
2. event_log table permissions issue
3. Metadata too large (JSON size limit)

**Debug:**
```xanoscript
function.run "subject_management/log_subject_event" {
  action = "subject.created"
  user_id = @auth.id
  subject_id = $output.id
} as $event

if (!$event.success) {
  log.error ("Logging failed: " ~ $event.error)
}
```

---

## Performance Considerations

### Indexes

The feature uses strategic indexes for efficiency:

1. **subject**: Account + name index for quick lookups within account
2. **subject_enrollment**: Composite index on (subject_id, user_id) for fast enrollment check
3. **event_log**: jsonb index on metadata for event queries

### Optimization Tips

- Use `get_user_subjects()` helper instead of manual joins
- Leverage addon queries for counts and summaries
- Filter by account_id early in queries
- Use status enum for soft deletes instead of hard deletes

---

## Future Enhancements

1. **Bulk Enrollment**: Import student lists (CSV)
2. **Role Templates**: Preset role configurations
3. **Permissions Matrix**: Granular permission control
4. **Webhooks**: Notify external systems of subject changes
5. **Search/Filter**: Advanced subject filtering
6. **Rate Limiting**: Per-account API rate limits

---

## References

- [Subject Management API Documentation](./API_DOCUMENTATION.md)
- [Database Schema](../../../tables/)
- [Core Functions](../../../functions/subject_management/)
- [API Implementation](../../../apis/)
- [Test Suite Documentation](../../../tests/)

---

Last Updated: 2026-03-25  
Version: 1.0
