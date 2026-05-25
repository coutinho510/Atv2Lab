# Tasks - feature-notas-atividades (Activity Grading System)

## Phase 1: Data Schema Design
- [ ] Create `academic_activity` table with fields: id, subject_id (FK), name, description, due_date, status (draft/published/closed), created_by (FK to user), account_id, created_at, updated_at
- [ ] Create `activity_grade` table with fields: id, activity_id (FK), student_id (FK to user), grade (0-100), feedback (text), rubric (JSON), graded_by (FK to user), account_id, created_at, updated_at
- [ ] Add unique constraint on (activity_id, student_id) for activity_grade
- [ ] Create indices on frequently-queried fields (subject_id, student_id, account_id) for both tables

## Phase 2: Backend Functions & Utilities
- [ ] Create validation function `validate_activity` (name required, subject_id exists, user is instructor/admin in subject)
- [ ] Create permission function `check_grading_permission` (verify instructor/admin role on subject)
- [ ] Create helper function `get_student_grades_for_activity` (returns grades with student info)
- [ ] Create audit function `log_grading_event` (logs grade creation/update to event_log)

## Phase 3: Activity Management APIs
- [ ] Create POST `/subjects/{id}/activities` — Create activity (instructor/admin only)
- [ ] Create GET `/subjects/{id}/activities` — List activities in subject (enrolled users)
- [ ] Create GET `/subjects/{id}/activities/{activity_id}` — View activity detail (enrolled users)
- [ ] Create PATCH `/subjects/{id}/activities/{activity_id}` — Update activity (instructor/admin only)
- [ ] Create DELETE `/subjects/{id}/activities/{activity_id}` — Archive activity (instructor/admin only)

## Phase 4: Grading APIs
- [ ] Create POST `/subjects/{id}/activities/{activity_id}/grades` — Create/submit grade for student (instructor/admin only)
- [ ] Create GET `/subjects/{id}/activities/{activity_id}/grades` — List grades (instructor/admin sees all; learner sees only own)
- [ ] Create PATCH `/subjects/{id}/activities/{activity_id}/grades/{student_id}` — Update grade + feedback (instructor/admin only)

## Phase 5: Documentation & Validation
- [ ] Review proposal.md for completeness
- [ ] Validate spec.md files against OpenSpec guidelines
- [ ] Prepare implementation summary

---

**Status:** ✅ ARCHIVED - OpenSpec Spec-Driven phase completed (2026-05-20)
