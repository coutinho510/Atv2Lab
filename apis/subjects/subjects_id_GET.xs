query "subjects/{id}" verb=GET {
  api_group = "subjects"
  description = "Retrieve a specific subject by ID with activity count"
  auth = "user"

  input {
    int id {
      description = "Subject ID"
    }
  }

  stack {
    // Fetch the subject
    db.query "subject" {
      where = $db.subject.id == $input.id && $db.subject.user_id == $auth.id
      return = {type: "single"}
    } as $subject

    // Validate that subject exists and belongs to authenticated user
    precondition ($subject != null) {
      description = "Subject not found or unauthorized access"
      error_type = "accessdenied"
      error = "Subject not found or you don't have permission to view it"
    }

    // Count activities for this subject
    db.query "academic_activity" {
      where = $db.academic_activity.subject_id == $input.id
      return = {type: "count"}
    } as $activity_count

    // Count overdue activities
    db.query "academic_activity" {
      where = $db.academic_activity.subject_id == $input.id && $db.academic_activity.due_date < now
      return = {type: "count"}
    } as $overdue_count

    debug.log {
      value = {
        event: "subject_retrieved",
        subject_id: $input.id,
        user_id: $auth.id
      }
    }
  }

  response = {
    id: $subject.id
    name: $subject.name
    teacher_name: $subject.teacher_name
    hours: $subject.hours
    activity_count: $activity_count
    overdue_count: $overdue_count
    created_at: $subject.created_at
    updated_at: $subject.updated_at
  }

  history = 100

  test "retrieve subject successfully" {
    input = {
      id: 1
    }
    expect.to_have_key ($response) {
      value = "name"
    }
  }

  test "return 404 for non-existent subject" {
    input = {
      id: 99999
    }
    expect.to_equal ($response) {
      value = null
    }
  }
}
