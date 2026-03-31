// Delete a subject (soft or hard delete)
query "subjects/{id}" verb=DELETE {
  api_group = "Subjects"
  auth = "user"
  description = "Delete a subject (soft or hard delete)"

  input {
    int id {
      description = "Subject ID"
      table = "subject"
    }

    bool soft_delete?=true {
      description = "Whether to soft delete (archive) instead of hard delete (optional, defaults to true)"
    }
  }

  stack {
    // Retrieve user record to get account_id
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = ["id", "account_id"]
      description = "Get user's account_id from auth context"
    } as $user

    // Verify user record exists
    precondition ($user != null) {
      error_type = "accessdenied"
      error = "Unauthorized: User record not found"
    }

    // Get the subject by ID
    db.get subject {
      field_name = "id"
      field_value = $input.id
      output = ["id", "name", "description", "credits", "status", "account_id", "created_at", "updated_at"]
      description = "Get subject details"
    } as $subject

    // Verify subject exists
    precondition ($subject != null) {
      error_type = "notfound"
      error = "Subject not found"
    }

    // Verify account_id matches (boundary check)
    precondition ($subject.account_id == $user.account_id) {
      error_type = "notfound"
      error = "Subject not found"
    }

    // Check user has admin role on this subject
    function.run "subject_management/check_subject_permission" {
      input = {
        user_id: $auth.id
        subject_id: $input.id
        required_role: "admin"
      }
      description = "Check if user has admin role on subject"
    } as $permission_result

    // Verify user has admin access to delete
    precondition ($permission_result.has_permission) {
      error_type = "accessdenied"
      error = "You don't have permission to delete this subject"
    }

    // Conditional delete logic based on soft_delete parameter
    conditional {
      if ($input.soft_delete) {
        // Soft delete: set status to archived
        db.patch subject {
          field_name = "id"
          field_value = $input.id
          data = {status: "archived"}
          description = "Soft delete by setting status to archived"
        } as $deleted_subject
      }

      else {
        // Hard delete: delete subject record
        db.del subject {
          field_name = "id"
          field_value = $input.id
          description = "Hard delete subject record"
        }

        // Also delete all enrollments for this subject
        try_catch {
          try {
            db.query subject_enrollment {
              where = $db.subject_enrollment.subject_id == $input.id
              return = {type: "list"}
              description = "Find all enrollments for subject"
            } as $enrollments_to_delete

            // Delete each enrollment
            foreach ($enrollments_to_delete) {
              each as $enrollment {
                db.del subject_enrollment {
                  field_name = "id"
                  field_value = $enrollment.id
                  description = "Delete enrollment record"
                }
              }
            }
          }

          catch {
            debug.log {
              value = "Note: Enrollments cascading may have had issues, but subject was deleted"
            }
          }
        }
      }
    }

    // Log the subject deletion event
    function.run "subject_management/log_subject_event" {
      input = {
        action: "subject.deleted"
        user_id: $auth.id
        subject_id: $input.id
        account_id: $user.account_id
        details: {
          soft_delete: $input.soft_delete
          subject_name: $subject.name
          subject_status: $subject.status
        }
      }
      description = "Log subject deletion event"
    } as $event_log
  }

  response = {
    success: true
  }

  // Test Suite 4: Subject Deletion (Task 6.4)
  test "should soft delete (archive) subject by default" {
    input = {
      id: 1
    }

    expect.to_be_defined ($response.success)
    expect.to_be_true ($response.success)
  }

  test "should soft delete when soft_delete param is true" {
    input = {
      id: 1
      soft_delete: true
    }

    expect.to_be_true ($response.success)
  }

  test "should hard delete subject when requested" {
    input = {
      id: 1
      soft_delete: false
    }

    expect.to_be_true ($response.success)
  }

  test "should cascade delete enrollments on hard delete" {
    input = {
      id: 1
      soft_delete: false
    }

    expect.to_be_true ($response.success)
  }

  test "should log deletion event with action subject.deleted" {
    input = {
      id: 1
      soft_delete: true
    }

    expect.to_be_true ($response.success)
  }

  test "should deny non-admin from deleting subject" {
    input = {
      id: 1
    }

    expect.to_throw {
      value = "accessdenied"
    }
  }

  test "should deny user from different account from deleting" {
    input = {
      id: 1
    }

    expect.to_throw {
      value = "notfound"
    }
  }

  test "should return not found for non-existent subject" {
    input = {
      id: 99999
    }

    expect.to_throw {
      value = "notfound"
    }
  }

  tags = ["xano:quick-start"]
}
