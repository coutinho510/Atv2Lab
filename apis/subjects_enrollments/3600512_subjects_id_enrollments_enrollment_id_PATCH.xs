// Update a user's role in a subject
query "subjects/:id/enrollments/:enrollment_id" verb=PATCH {
  api_group = "subjects_enrollments"
  auth = "user"
  description = "Update a user's role assignment in a subject"

  input {
    int id {
      description = "Subject ID from path"
    }

    int enrollment_id {
      description = "Enrollment ID to update from path"
    }

    enum subject_role {
      values = ["learner", "instructor", "admin"]
      description = "New role to assign"
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
      error = "You must be an admin of this subject to update enrollments"
    }

    // Get the enrollment record
    db.get subject_enrollment {
      field_name = "id"
      field_value = $input.enrollment_id
      description = "Retrieve enrollment record"
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

    // Store old role for logging
    var $old_role {
      value = $enrollment.subject_role
      description = "Store the previous role for audit logging"
    }

    // If changing from admin to non-admin, verify other admins exist
    conditional {
      if ($old_role == "admin" && $input.subject_role != "admin") {
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

    // Update the enrollment with new role
    db.edit subject_enrollment {
      field_name = "id"
      field_value = $input.enrollment_id
      data = {
        subject_role: $input.subject_role
      }
      description = "Update enrollment role"
    } as $updated_enrollment

    // Log the enrollment update
    function.run "subject_management/log_subject_event" {
      input = {
        action: "subject.enrollment.updated"
        user_id: $auth.id
        subject_id: $input.id
        enrollment_id: $input.enrollment_id
        account_id: $auth_user.account_id
        details: {
          enrolled_user_id: $enrollment.user_id
          old_role: $old_role
          new_role: $input.subject_role
        }
      }
      description = "Log enrollment update event"
    }
  }

  response = {
    id: $updated_enrollment.id
    subject_id: $updated_enrollment.subject_id
    user_id: $updated_enrollment.user_id
    subject_role: $updated_enrollment.subject_role
    updated_at: $updated_enrollment.updated_at
  }

  history = "all"
}
