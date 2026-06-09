query "subjects/{id}/delete" verb=DELETE {
  api_group = "subjects"
  description = "Delete a subject and all associated activities"
  auth = "user"

  input {
    int id {
      description = "Subject ID to delete"
    }
  }

  stack {
    // Fetch the subject to verify ownership
    db.get "subject" {
      field_name = "id"
      field_value = $input.id
    } as $subject

    precondition ($subject != null) {
      description = "Subject not found"
      error_type = "inputerror"
      error = "Subject not found"
    }

    precondition ($subject.user_id == $auth.id) {
      description = "User is not authorized to delete this subject"
      error_type = "accessdenied"
      error = "You don't have permission to delete this subject"
    }

    // Get all activities for this subject before deletion
    db.query "academic_activity" {
      where = $db.academic_activity.subject_id == $input.id
      return = {type: "list"}
    } as $activities_to_delete

    var $activity_count {
      value = ($activities_to_delete|count)
    }

    // Delete all activities associated with this subject
    conditional {
      if ($activity_count > 0) {
        foreach ($activities_to_delete) {
          each as $activity {
            db.del "academic_activity" {
              field_name = "id"
              field_value = $activity.id
            }
          }
        }
      }
    }

    // Delete the subject
    db.del "subject" {
      field_name = "id"
      field_value = $input.id
    }

    debug.log {
      value = {
        event: "subject_deleted",
        subject_id: $input.id,
        user_id: $auth.id,
        activities_deleted: $activity_count,
        subject_name: $subject.name
      }
    }
  }

  response = {
    success: true
    message: "Subject and associated activities deleted successfully"
    subject_id: $input.id
    activities_deleted: $activity_count
  }

  history = 1000

  test "delete subject successfully" {
    input = {
      id: 1
    }
    expect.to_have_key ($response) {
      value = "success"
    }
  }

  test "prevent deletion of non-existent subject" {
    input = {
      id: 99999
    }
    expect.to_have_property ($response) {
      property = "error"
    }
  }
}
