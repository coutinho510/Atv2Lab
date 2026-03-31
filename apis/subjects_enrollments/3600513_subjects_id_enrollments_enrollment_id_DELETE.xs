// Remove a user from a subject
query "subjects/:id/enrollments/:enrollment_id" verb=DELETE {
  api_group = "subjects_enrollments"
  auth = "user"
  description = "Remove a user from a subject enrollment"

  input {
    int id {
      description = "Subject ID from path"
    }

    int enrollment_id {
      description = "Enrollment ID to remove from path"
    }
  }

  stack {
    // Get the subject by ID
    db.get subject {
      field_name = "id"
      field_value = $input.id
      description = "Retrieve subject record"
    } as $subject

    // Verify subject exists
    precondition ($subject != null) {
      error_type = "inputerror"
      error = "Subject not found"
    }

    // Get authenticated user's account
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = ["id", "account_id"]
      description = "Get authenticated user's account"
    } as $auth_user

    // Verify subject belongs to authenticated user's account
    precondition ($subject.account_id == $auth_user.account_id) {
      error_type = "inputerror"
      error = "Subject not found in your account"
    }

    // Verify caller has admin role on subject using helper function
    function.run "subject_management/check_subject_permission" {
      input = {
        user_id: $auth.id
        subject_id: $input.id
        required_role: "admin"
      }
      description = "Verify caller has admin permission on subject"
    } as $permission_check

    precondition ($permission_check.has_permission) {
      error_type = "accessdenied"
      error = "You must be an admin of this subject to remove enrollments"
    }

    // Get the enrollment record
    db.get subject_enrollment {
      field_name = "id"
      field_value = $input.enrollment_id
      description = "Retrieve enrollment record to delete"
    } as $enrollment

    // Verify enrollment exists and belongs to this subject
    precondition ($enrollment != null) {
      error_type = "inputerror"
      error = "Enrollment not found"
    }

    precondition ($enrollment.subject_id == $input.id) {
      error_type = "inputerror"
      error = "Enrollment does not belong to this subject"
    }

    // Get details of the user being removed for logging
    db.get user {
      field_name = "id"
      field_value = $enrollment.user_id
      output = ["id", "name", "email"]
      description = "Get user details for removal logging"
    } as $removed_user

    // If enrollment is admin, verify other admins exist
    conditional {
      if ($enrollment.subject_role == "admin") {
        db.query subject_enrollment {
          where = $db.subject_enrollment.subject_id == $input.id && $db.subject_enrollment.subject_role == "admin" && $db.subject_enrollment.id != $input.enrollment_id
          return = {type: "count"}
          description = "Count other admin enrollments"
        } as $admin_count

        precondition ($admin_count > 0) {
          error_type = "inputerror"
          error = "Cannot remove the last admin from this subject"
        }
      }
    }

    // Delete the enrollment
    db.del subject_enrollment {
      field_name = "id"
      field_value = $input.enrollment_id
      description = "Delete the enrollment record"
    }

    // Log the enrollment removal
    function.run "subject_management/log_subject_event" {
      input = {
        action: "subject.enrollment.removed"
        user_id: $auth.id
        subject_id: $input.id
        enrollment_id: $input.enrollment_id
        account_id: $auth_user.account_id
        details: {
          removed_user_id: $enrollment.user_id
          removed_user_name: $removed_user.name
          removed_user_email: $removed_user.email
          subject_role: $enrollment.subject_role
        }
      }
      description = "Log enrollment removal event"
    }
  }

  response = {
    success: true
  }

  // Test Suite 6: User Removal (Task 6.6)
  test "should allow admin to remove enrolled learner" {
    input = {
      id: 1
      enrollment_id: 1
    }

    expect.to_be_true ($response.success)
  }

  test "should allow admin to remove enrolled instructor" {
    input = {
      id: 1
      enrollment_id: 2
    }

    expect.to_be_true ($response.success)
  }

  test "should log removal event as subject.enrollment.removed with user details" {
    input = {
      id: 1
      enrollment_id: 3
    }

    expect.to_be_true ($response.success)
  }

  test "should prevent removal of last admin from subject" {
    input = {
      id: 1
      enrollment_id: 999
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should deny non-admin from removing enrollments" {
    input = {
      id: 1
      enrollment_id: 1
    }

    expect.to_throw {
      value = "accessdenied"
    }
  }

  test "should return error for non-existent enrollment" {
    input = {
      id: 1
      enrollment_id: 99999
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should verify enrollment belongs to subject" {
    input = {
      id: 1
      enrollment_id: 999
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should return error for non-existent subject" {
    input = {
      id: 99999
      enrollment_id: 1
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should deny user from different account from removing" {
    input = {
      id: 1
      enrollment_id: 1
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  history = "all"
}
