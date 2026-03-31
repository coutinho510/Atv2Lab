// List all users enrolled in a subject
query "subjects/:id/enrollments" verb=GET {
  api_group = "subjects_enrollments"
  auth = "user"
  description = "List all users enrolled in a subject with optional role filtering"

  input {
    int id {
      description = "Subject ID from path"
    }

    enum role? {
      values = ["learner", "instructor", "admin"]
      description = "Optional: filter enrollments by role"
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

    // Verify caller has any enrollment in subject using helper function
    function.run "subject_management/check_subject_permission" {
      input = {
        user_id: $auth.id
        subject_id: $input.id
        required_role: "any"
      }
      description = "Verify caller has any enrollment in subject"
    } as $permission_check

    precondition ($permission_check.has_permission) {
      error_type = "accessdenied"
      error = "You must be enrolled in this subject to view enrollments"
    }

    // Query enrollments with optional role filter
    conditional {
      if ($input.role != null) {
        db.query subject_enrollment {
          where = $db.subject_enrollment.subject_id == $input.id && $db.subject_enrollment.subject_role == $input.role
          join = {
            user: {
              table: "user"
              where: $db.subject_enrollment.user_id == $db.user.id
            }
          }
          sort = {subject_enrollment.created_at: "asc"}
          return = {type: "list"}
          eval = {
            enrollment_id: $db.subject_enrollment.id
            user_name: $db.user.name
            user_email: $db.user.email
          }
          description = "Query enrollments filtered by role"
        } as $enrollments_data
      }

      else {
        db.query subject_enrollment {
          where = $db.subject_enrollment.subject_id == $input.id
          join = {
            user: {
              table: "user"
              where: $db.subject_enrollment.user_id == $db.user.id
            }
          }
          sort = {subject_enrollment.created_at: "asc"}
          return = {type: "list"}
          eval = {
            enrollment_id: $db.subject_enrollment.id
            user_name: $db.user.name
            user_email: $db.user.email
          }
          description = "Query all enrollments"
        } as $enrollments_data
      }
    }

    // Transform response to exclude unnecessary fields
    var $response_enrollments {
      value = $enrollments_data|map:{
        enrollment_id: $$.id
        user_id: $$.user_id
        user_name: $$.user_name
        user_email: $$.user_email
        subject_role: $$.subject_role
        created_at: $$.created_at
      }
      description = "Transform enrollments for response"
    }
  }

  response = $response_enrollments

  history = "all"
}
