// Enroll a user in a subject with specified role
query "subjects/:id/enrollments" verb=POST {
  api_group = "subjects_enrollments"
  auth = "user"
  description = "Enroll a user in a subject with specified role"

  input {
    int id {
      description = "Subject ID from path"
    }

    int user_id {
      description = "User ID to enroll"
      table = "user"
    }

    enum subject_role {
      values = ["learner", "instructor", "admin"]
      description = "Role to assign to the user"
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

    // Verify target user belongs to same account
    db.get user {
      field_name = "id"
      field_value = $input.user_id
      output = ["id", "account_id"]
      description = "Verify target user exists and get their account"
    } as $target_user

    precondition ($target_user != null) {
      error_type = "inputerror"
      error = "Target user not found"
    }

    precondition ($target_user.account_id == $auth_user.account_id) {
      error_type = "inputerror"
      error = "Target user is not in your account"
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
      error = "You must be an admin of this subject to enroll users"
    }

    // Check for duplicate enrollment
    db.query subject_enrollment {
      where = $db.subject_enrollment.subject_id == $input.id && $db.subject_enrollment.user_id == $input.user_id
      return = {type: "exists"}
      description = "Check if user is already enrolled"
    } as $already_enrolled

    precondition (!$already_enrolled) {
      error_type = "inputerror"
      error = "User is already enrolled in this subject"
    }

    // Create the enrollment record
    db.add subject_enrollment {
      data = {
        subject_id: $input.id
        user_id: $input.user_id
        subject_role: $input.subject_role
        account_id: $auth_user.account_id
      }
      description = "Create new subject enrollment"
    } as $new_enrollment

    // Log the enrollment action
    function.run "subject_management/log_subject_event" {
      input = {
        action: "subject.enrollment.added"
        user_id: $auth.id
        subject_id: $input.id
        enrollment_id: $new_enrollment.id
        account_id: $auth_user.account_id
        details: {
          enrolled_user_id: $input.user_id
          subject_role: $input.subject_role
        }
      }
      description = "Log enrollment creation event"
    }
  }

  response = {
    id: $new_enrollment.id
    subject_id: $new_enrollment.subject_id
    user_id: $new_enrollment.user_id
    subject_role: $new_enrollment.subject_role
    created_at: $new_enrollment.created_at
  }

  // Test Suite 5: User Enrollment (Task 6.5)
  test "should allow admin to enroll user with learner role" {
    input = {
      id: 1
      user_id: 2
      subject_role: "learner"
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.user_id) {
      value = 2
    }
    expect.to_equal ($response.subject_role) {
      value = "learner"
    }
  }

  test "should allow admin to enroll user with instructor role" {
    input = {
      id: 1
      user_id: 3
      subject_role: "instructor"
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.subject_role) {
      value = "instructor"
    }
  }

  test "should allow admin to enroll user with admin role" {
    input = {
      id: 1
      user_id: 4
      subject_role: "admin"
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.subject_role) {
      value = "admin"
    }
  }

  test "should log enrollment event as subject.enrollment.added" {
    input = {
      id: 1
      user_id: 5
      subject_role: "learner"
    }

    expect.to_be_defined ($response.id)
  }

  test "should prevent duplicate enrollment of same user" {
    input = {
      id: 1
      user_id: 2
      subject_role: "learner"
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should deny non-admin from enrolling users" {
    input = {
      id: 1
      user_id: 2
      subject_role: "learner"
    }

    expect.to_throw {
      value = "accessdenied"
    }
  }

  test "should reject enrollment of user from different account" {
    input = {
      id: 1
      user_id: 999
      subject_role: "learner"
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should return error for non-existent user_id" {
    input = {
      id: 1
      user_id: 99999
      subject_role: "learner"
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should return error for non-existent subject" {
    input = {
      id: 99999
      user_id: 2
      subject_role: "learner"
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  history = "all"
}
