# Subject Management API Documentation

## Overview

The Subject Management API enables users to create, manage, and organize academic subjects within their accounts. All endpoints require authentication and enforce role-based access control at the subject level.

---

## Authentication & Authorization

### Authentication
All endpoints require a valid JWT token in the `Authorization` header:
```
Authorization: Bearer {jwt_token}
```

### Authorization
- **Subject Creation**: Any authenticated user can create subjects
- **Subject Viewing**: Users can only view subjects they're enrolled in
- **Subject Management**: Only users with "admin" role on a subject can modify it
- **Subject Enrollment**: Only "admin" users can enroll/remove users from subjects

---

## Base URL
```
/api/subjects
```

---

## Subject Endpoints

### 1. Create Subject
**POST** `/api/subjects`

Creates a new academic subject and auto-enrolls the creator as an admin.

**Request Body:**
```json
{
  "name": "Mathematics 101",
  "description": "Introduction to calculus",
  "credits": 3
}
```

**Request Fields:**
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `name` | string | Yes | Non-empty, trimmed |
| `description` | string | No | Max 1000 characters |
| `credits` | integer | No | >= 0 |

**Response (201 Created):**
```json
{
  "id": 753414,
  "name": "Mathematics 101",
  "description": "Introduction to calculus",
  "credits": 3,
  "status": "active",
  "account_id": 1001,
  "created_at": "2026-03-25T10:30:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - Validation failed (missing name, negative credits, etc.)
- `401 Unauthorized` - No valid authentication token

**Events Logged:**
- `subject.created` - Event with subject_id and creator user_id

---

### 2. List User's Subjects
**GET** `/api/subjects`

Retrieves all subjects the authenticated user is enrolled in.

**Query Parameters:** None (future: filtering by status, role)

**Response (200 OK):**
```json
[
  {
    "id": 753414,
    "name": "Mathematics 101",
    "description": "Introduction to calculus",
    "credits": 3,
    "status": "active",
    "account_id": 1001,
    "subject_role": "admin",
    "created_at": "2026-03-25T10:30:00Z"
  },
  {
    "id": 753415,
    "name": "Physics 102",
    "description": null,
    "credits": 4,
    "status": "active",
    "account_id": 1001,
    "subject_role": "learner",
    "created_at": "2026-03-25T11:00:00Z"
  }
]
```

**Error Responses:**
- `401 Unauthorized` - No valid authentication token

---

### 3. Get Subject Details
**GET** `/api/subjects/:id`

Retrieves details of a specific subject the user is enrolled in.

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Subject ID |

**Response (200 OK):**
```json
{
  "id": 753414,
  "name": "Mathematics 101",
  "description": "Introduction to calculus",
  "credits": 3,
  "status": "active",
  "account_id": 1001,
  "subject_role": "admin",
  "created_at": "2026-03-25T10:30:00Z",
  "updated_at": "2026-03-25T10:30:00Z"
}
```

**Error Responses:**
- `401 Unauthorized` - No valid authentication token
- `403 Forbidden` - User not enrolled in this subject
- `404 Not Found` - Subject does not exist

---

### 4. Update Subject
**PATCH** `/api/subjects/:id`

Updates subject metadata. Only users with "admin" role can update.

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Subject ID |

**Request Body (all fields optional):**
```json
{
  "name": "Advanced Mathematics",
  "description": "Advanced calculus course",
  "credits": 4,
  "status": "archived"
}
```

**Request Fields:**
| Field | Type | Constraints |
|-------|------|-------------|
| `name` | string | Non-empty, trimmed |
| `description` | string | Max 1000 characters |
| `credits` | integer | >= 0 |
| `status` | enum | "draft", "active", "archived" |

**Response (200 OK):**
```json
{
  "id": 753414,
  "name": "Advanced Mathematics",
  "description": "Advanced calculus course",
  "credits": 4,
  "status": "archived",
  "account_id": 1001,
  "updated_at": "2026-03-25T12:00:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - Validation failed
- `401 Unauthorized` - No valid authentication token
- `403 Forbidden` - User is not an admin of this subject
- `404 Not Found` - Subject does not exist

**Events Logged:**
- `subject.updated` - Event with old/new values in metadata

---

### 5. Delete Subject
**DELETE** `/api/subjects/:id`

Deletes a subject. Only users with "admin" role can delete.

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Subject ID |

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `soft_delete` | boolean | true | If true, archives subject; if false, permanently deletes |

**Response (200 OK):**
```json
{
  "success": true
}
```

**Error Responses:**
- `401 Unauthorized` - No valid authentication token
- `403 Forbidden` - User is not an admin of this subject
- `404 Not Found` - Subject does not exist

**Events Logged:**
- `subject.deleted` - Event with subject_id in metadata

**Cascade Behavior:**
- **Soft Delete** (default): Subject status set to "archived"; enrollments remain
- **Hard Delete**: Subject deleted; all related enrollments removed

---

## Enrollment Endpoints

### 6. Enroll User in Subject
**POST** `/api/subjects/:id/enrollments`

Enrolls a user in a subject with specified role. Only admin can perform.

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Subject ID |

**Request Body:**
```json
{
  "user_id": 1005,
  "subject_role": "learner"
}
```

**Request Fields:**
| Field | Type | Required | Values |
|-------|------|----------|--------|
| `user_id` | integer | Yes | Valid user ID in same account |
| `subject_role` | enum | Yes | "learner", "instructor", "admin" |

**Response (201 Created):**
```json
{
  "id": 110001,
  "subject_id": 753414,
  "user_id": 1005,
  "subject_role": "learner",
  "created_at": "2026-03-25T13:00:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - User already enrolled, invalid role, or user not in same account
- `401 Unauthorized` - No valid authentication token
- `403 Forbidden` - User is not an admin of this subject
- `404 Not Found` - Subject or user does not exist

**Events Logged:**
- `subject.enrollment.added` - Event with user_id, subject_id, and role

---

### 7. List Subject Enrollments
**GET** `/api/subjects/:id/enrollments`

Lists all users enrolled in a subject.

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Subject ID |

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `role` | enum | Optional: filter by role ("learner", "instructor", "admin") |

**Response (200 OK):**
```json
[
  {
    "enrollment_id": 110001,
    "user_id": 1001,
    "user_name": "John Doe",
    "user_email": "john@example.com",
    "subject_role": "admin",
    "created_at": "2026-03-25T10:30:00Z"
  },
  {
    "enrollment_id": 110002,
    "user_id": 1005,
    "user_name": "Jane Smith",
    "user_email": "jane@example.com",
    "subject_role": "learner",
    "created_at": "2026-03-25T13:00:00Z"
  }
]
```

**Error Responses:**
- `401 Unauthorized` - No valid authentication token
- `403 Forbidden` - User not enrolled in this subject
- `404 Not Found` - Subject does not exist

---

### 8. Update User Role
**PATCH** `/api/subjects/:id/enrollments/:enrollment_id`

Updates a user's role in a subject. Only admin can perform.

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Subject ID |
| `enrollment_id` | integer | Enrollment ID |

**Request Body:**
```json
{
  "subject_role": "instructor"
}
```

**Request Fields:**
| Field | Type | Values |
|-------|------|--------|
| `subject_role` | enum | "learner", "instructor", "admin" |

**Response (200 OK):**
```json
{
  "id": 110001,
  "subject_id": 753414,
  "user_id": 1005,
  "subject_role": "instructor",
  "updated_at": "2026-03-25T14:00:00Z"
}
```

**Error Responses:**
- `400 Bad Request` - Cannot remove last admin
- `401 Unauthorized` - No valid authentication token
- `403 Forbidden` - User is not an admin of this subject
- `404 Not Found` - Subject or enrollment does not exist

**Events Logged:**
- `subject.enrollment.updated` - Event with old/new role in metadata

---

### 9. Remove User from Subject
**DELETE** `/api/subjects/:id/enrollments/:enrollment_id`

Removes a user's enrollment in a subject. Only admin can perform.

**Path Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | Subject ID |
| `enrollment_id` | integer | Enrollment ID |

**Response (200 OK):**
```json
{
  "success": true
}
```

**Error Responses:**
- `400 Bad Request` - Cannot remove last admin
- `401 Unauthorized` - No valid authentication token
- `403 Forbidden` - User is not an admin of this subject
- `404 Not Found` - Subject or enrollment does not exist

**Events Logged:**
- `subject.enrollment.removed` - Event with removed user details

---

## Data Models

### Subject
```json
{
  "id": "integer",
  "name": "string (required, max 255)",
  "description": "string (optional, max 1000)",
  "credits": "integer (optional, >= 0)",
  "status": "enum: 'draft' | 'active' | 'archived'",
  "account_id": "integer (required)",
  "created_at": "ISO 8601 timestamp",
  "updated_at": "ISO 8601 timestamp"
}
```

### SubjectEnrollment
```json
{
  "id": "integer",
  "subject_id": "integer (required)",
  "user_id": "integer (required)",
  "subject_role": "enum: 'learner' | 'instructor' | 'admin'",
  "account_id": "integer (required)",
  "created_at": "ISO 8601 timestamp"
}
```

---

## Error Responses

All error responses follow a standard format:

```json
{
  "error": "error_type",
  "message": "Human readable error message",
  "details": {
    "field": "field_name (if applicable)"
  }
}
```

**Common Error Types:**
- `BadRequest` (400) - Validation error or business rule violation
- `Unauthorized` (401) - Missing or invalid authentication
- `AccessDenied` (403) - Insufficient permissions
- `NotFound` (404) - Resource not found
- `InternalError` (500) - Server error

---

## Rate Limiting

Currently no rate limiting is enforced. Subject endpoints are limited by account-level permissions.

---

## Changelog

### v1.0 (2026-03-25)
- Initial release
- Subject CRUD endpoints
- User enrollment management
- Event logging integration
- 67 comprehensive test cases
