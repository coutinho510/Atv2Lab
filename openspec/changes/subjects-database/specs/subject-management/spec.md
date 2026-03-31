## ADDED Requirements

### Requirement: User can create subjects
Users SHALL be able to create new academic subjects within their account with essential metadata (name, description, credits).

#### Scenario: User creates a subject successfully
- **WHEN** an authenticated user submits a valid subject creation request with name and account_id
- **THEN** the system creates the subject record and returns the created subject with id, timestamps, and ownership

#### Scenario: User cannot create subject without required fields
- **WHEN** an authenticated user submits a subject creation request missing required fields (name or account_id)
- **THEN** the system returns a validation error and does not create the subject

#### Scenario: User is automatically enrolled as subject admin
- **WHEN** a user creates a subject
- **THEN** the system automatically creates a subject_enrollment record for that user with role "admin"

### Requirement: User can enroll other users in subjects
Users with admin role on a subject SHALL be able to add other users from their account to that subject with a specified role.

#### Scenario: Subject admin enrolls a learner
- **WHEN** a subject admin submits an enrollment request with a valid user_id and role (learner, instructor, or admin)
- **THEN** the system creates a subject_enrollment record linking the user to the subject

#### Scenario: User cannot be enrolled twice in the same subject
- **WHEN** attempting to enroll a user who is already enrolled in the subject
- **THEN** the system returns an error and does not create a duplicate enrollment

#### Scenario: Only subject admin can enroll users
- **WHEN** a non-admin user attempts to enroll another user in a subject
- **THEN** the system returns an access denied error

### Requirement: User can view subjects they have access to
Users SHALL be able to view a list of academic subjects they are enrolled in or have administrative access to.

#### Scenario: User retrieves their enrolled subjects
- **WHEN** an authenticated user requests their subject list
- **THEN** the system returns all subjects where the user has an active enrollment, including enrollment role and status

#### Scenario: User cannot view subjects they are not enrolled in
- **WHEN** a user requests a subject they have no enrollment in
- **THEN** the system returns access denied or does not include that subject in their list

### Requirement: User can update subject metadata
Subject administrators SHALL be able to update subject details including name, description, and credits.

#### Scenario: Subject admin updates subject name
- **WHEN** a subject admin submits an update request with new name and subject_id
- **THEN** the system updates the subject and logs the change via the event logging system

#### Scenario: Non-admin cannot update subject
- **WHEN** a non-admin subject user attempts to update the subject
- **THEN** the system returns an access denied error

### Requirement: User can remove users from subjects
Subject administrators SHALL be able to remove enrolled users from their subjects.

#### Scenario: Subject admin removes a learner from subject
- **WHEN** a subject admin submits a removal request (DELETE subject_enrollment) for an enrolled user
- **THEN** the system removes the enrollment record and logs the change

#### Scenario: Admin cannot remove other admins
- **WHEN** an admin attempts to remove another admin user from the subject
- **THEN** the system returns an error (subject must retain at least one admin)

### Requirement: Subject operations are logged
All subject-related operations (create, update, delete, enroll, remove) SHALL be logged via the event logging system for audit purposes.

#### Scenario: Subject creation is logged
- **WHEN** a subject is created
- **THEN** an event_log record is created with action "subject.created", subject_id, and user who performed the action

#### Scenario: User enrollment is logged
- **WHEN** a user is enrolled in a subject
- **THEN** an event_log record is created with action "subject.enrollment.added" including user_id, subject_id, and role

#### Scenario: User removal is logged
- **WHEN** a user is removed from a subject
- **THEN** an event_log record is created with action "subject.enrollment.removed" including user_id and subject_id

### Requirement: Subject management respects account boundaries
Users can only manage subjects and enrollments within their own account.

#### Scenario: User cannot see subjects from other accounts
- **WHEN** querying subjects
- **THEN** the system only returns subjects belonging to the user's account

#### Scenario: User cannot enroll someone from a different account
- **WHEN** attempting to enroll a user from a different account to a subject
- **THEN** the system returns validation error (user not in account)
