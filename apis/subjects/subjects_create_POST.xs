query "subjects/create" verb=POST {
  api_group = "subjects"
  description = "Create a new subject with validation for duplicates and user authorization"
  auth = "user"

  input {
    text name filters=trim {
      description = "Subject name"
    }
    text teacher_name filters=trim {
      description = "Teacher name for the subject"
    }
    int hours? {
      description = "Course hours (optional)"
    }
  }

  stack {
    // Validate input is not empty
    precondition (($input.name|strlen) > 0) {
      description = "Subject name is required and cannot be empty"
      error_type = "inputerror"
      error = "Subject name must not be empty"
    }

    precondition (($input.teacher_name|strlen) > 0) {
      description = "Teacher name is required and cannot be empty"
      error_type = "inputerror"
      error = "Teacher name must not be empty"
    }

    // Check for duplicate subjects
    db.query "subject" {
      where = $db.subject.name == $input.name && $db.subject.teacher_name == $input.teacher_name && $db.subject.user_id == $auth.id
      return = {type: "exists"}
    } as $duplicate_exists

    precondition ($duplicate_exists == false) {
      description = "Prevent duplicate subject registration"
      error_type = "inputerror"
      error = "A subject with the same name and teacher already exists"
    }

    // Create the new subject
    db.add "subject" {
      data = {
        name: $input.name
        teacher_name: $input.teacher_name
        hours: $input.hours
        user_id: $auth.id
        created_at: now
        updated_at: now
      }
    } as $new_subject

    debug.log {
      value = {
        event: "subject_created",
        subject_id: $new_subject.id,
        user_id: $auth.id,
        subject_name: $new_subject.name
      }
    }
  }

  response = {
    id: $new_subject.id
    name: $new_subject.name
    teacher_name: $new_subject.teacher_name
    hours: $new_subject.hours
    created_at: $new_subject.created_at
  }

  history = 1000

  test "create subject successfully" {
    input = {
      name: "Mathematics"
      teacher_name: "Prof. Smith"
      hours: 60
    }
    expect.to_have_key ($response) {
      value = "id"
    }
  }

  test "prevent duplicate subject" {
    input = {
      name: "Mathematics"
      teacher_name: "Prof. Smith"
      hours: 60
    }
    expect.to_have_property ($response) {
      property = "error"
    }
  }
}
