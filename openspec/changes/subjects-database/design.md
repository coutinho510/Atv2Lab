## Context

The EduTrack-ai platform currently supports user authentication, account management, and role-based access control (admin/member roles). The existing database includes `user`, `account`, `event_log`, and `agent_conversation` tables. Users are organized within accounts, and all actions are logged via the event logging system.

The new subject management feature must integrate with this existing architecture, leveraging the current authentication and access control mechanisms.

## Goals / Non-Goals

**Goals:**
- Enable users to create, manage, and organize academic subjects within their accounts
- Implement role-based access control so users can only access subjects they're authorized to work with
- Provide proper audit trails by logging all subject-related operations through the existing event logging system
- Design the schema to support future features like attendance tracking, grades, and course-based reporting
- Support multiple user types interacting with subjects (learners, instructors, administrators)

**Non-Goals:**
- Implementing attendance or grade tracking in this change
- Building the API endpoints (that's part of implementation tasks)
- Creating the frontend UI (separate change)
- Migrating existing course data (no legacy data to migrate)

## Decisions

**Decision 1: Subject-User Relationship**
- **Choice**: Create a junction table `subject_enrollment` for many-to-many relationships between subjects and users
- **Rationale**: Supports multiple user types (learner, instructor, administrator) for each subject, enables flexible role assignment per subject, and allows users to be enrolled in multiple subjects simultaneously
- **Alternatives Considered**: 
  - Direct foreign key (subject.instructor_id) - too rigid, doesn't support multiple roles per user
  - Store user array in subject - poor query performance and normalization

**Decision 2: Access Control Model**
- **Choice**: Use subject-level enrollment roles (`subject_role`: learner, instructor, admin) separate from account-level roles
- **Rationale**: Allows fine-grained permissions (e.g., a member at account level can be an instructor for a specific subject); integrates cleanly with existing `role_based_access_control` function
- **Alternatives Considered**:
  - Only use account-level roles - too restrictive, doesn't support instructor/student separation
  - Create complex permissions table - over-engineered for initial scope

**Decision 3: Data Ownership**
- **Choice**: Subjects belong to accounts (not individual users) to support team collaboration
- **Rationale**: Multiple users within an account can manage the same subjects; aligns with existing account-based organization; enables proper access control at account level
- **Alternatives Considered**:
  - Subjects belong to individual users - breaks collaboration within teams

## Risks / Trade-offs

**[Risk]** Many-to-many complexity → **[Mitigation]** Use junction table pattern which is standard and well-supported; create helper functions/addons for common queries

**[Risk]** Access control edge cases (e.g., user loses access but records still reference them) → **[Mitigation]** Establish clear deletion/revocation policies; log all role changes via event system

**[Risk]** Performance as subject-user relationships grow → **[Mitigation]** Create appropriate indexes on junction table; use addons for efficient data loading; review query performance during testing

## Migration Plan

This is a greenfield feature with no existing data to migrate. Deployment involves:
1. Create `subject` table in Xano
2. Create `subject_enrollment` junction table
3. Create API endpoints for subject management
4. Add unit tests for validation
5. Document API for frontend developers

Rollback: Delete the new tables (no data dependencies from existing tables).

## Open Questions

- Should subjects have a status field (draft, active, archived)? *Recommend: yes, for future automation*
- Who can create subjects? (Only admins or all members?) *Recommend: allow members, log via event system*
- Should there be a default subject_role when enrolling a user? *Recommend: use the account role (admin/member) as default*
