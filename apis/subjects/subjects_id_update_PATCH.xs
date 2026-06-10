query "subjects/{id}/update" verb=PATCH {
  api_group = "subjects"
  description = "Update an existing subject with duplicate validation"
  auth = "user"

  input {
    int id {
      description = "Subject ID to update"
    }
    text name? filters=trim {
      description = "New subject name (optional)"
    }
    text teacher_name? filters=trim {
      description = "New teacher name (optional)"
    }
    int hours? {
      description = "New course hours (optional)"
    }
  }

  stack {
    // Fetch the subject to verify ownership
    db.get "subject" {
      field_name = "id"
      field_value = $input.id
    } as $existing_subject

    precondition ($existing_subject != null) {
      description = "Subject not found"
      error_type = "inputerror"
      error = "Subject not found"
    }

    precondition ($existing_subject.user_id == $auth.id) {
      description = "User is not authorized to update this subject"
      error_type = "accessdenied"
      error = "You don't have permission to update this subject"
    }

    // Prepare update data
    var $update_data {
      value = {}
    }

    // Add fields to update if provided
    conditional {
      if ($input.name != null && ($input.name|strlen) > 0) {
        var.update $update_data {
          value = $update_data|set:"name":$input.name
        }
      }
    }

    conditional {
      if ($input.teacher_name != null && ($input.teacher_name|strlen) > 0) {
        var.update $update_data {
          value = $update_data|set:"teacher_name":$input.teacher_name
        }
      }
    }

    conditional {
      if ($input.hours != null) {
        var.update $update_data {
          value = $update_data|set:"hours":$input.hours
        }
      }
    }

    // Check for duplicates if name or teacher_name is being changed
    conditional {
      if (($input.name != null || $input.teacher_name != null) && ($update_data|count) > 0) {
        var $final_name {
          value = $input.name || $existing_subject.name
        }
        var $final_teacher {
          value = $input.teacher_name || $existing_subject.teacher_name
        }

        db.query "subject" {
          where = $db.subject.name == $final_name && $db.subject.teacher_name == $final_teacher && $db.subject.user_id == $auth.id && $db.subject.id != $input.id
          return = {type: "exists"}
        } as $duplicate_exists

        precondition ($duplicate_exists == false) {
          description = "Another subject with the same name and teacher already exists"
          error_type = "inputerror"
          error = "A subject with this name and teacher already exists"
        }
      }
    }

    // Always update the updated_at timestamp
    var.update $update_data {
      value = $update_data|set:"updated_at":now
    }

    // Update the subject
    db.edit "subject" {
      field_name = "id"
      field_value = $input.id
      data = $update_data
    } as $updated_subject

    debug.log {
      value = {
        event: "subject_updated",
        subject_id: $input.id,
        user_id: $auth.id,
        updated_fields: $update_data|keys
      }
    }
  }

  response = {
    id: $updated_subject.id
    name: $updated_subject.name
    teacher_name: $updated_subject.teacher_name
    hours: $updated_subject.hours
    updated_at: $updated_subject.updated_at
  }

  history = 1000

  test "update subject name successfully" {
    input = {
      id: 1
      name: "Advanced Mathematics"
    }
    expect.to_have_key ($response) {
      value = "id"
    }
  }

  test "prevent duplicate on update" {
    input = {
      id: 1
      name: "Existing Subject"
      teacher_name: "Prof. Jones"
    }
    expect.to_have_property ($response) {
      property = "error"
    }
  }
}
