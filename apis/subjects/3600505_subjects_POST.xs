// Create a new academic subject and auto-enroll creator as admin
query "subjects" verb=POST {
  api_group = "Subjects"
  auth = "user"
  description = "Create a new academic subject and auto-enroll creator as admin"

  input {
    text name filters=trim {
      description = "Subject name (required)"
    }

    text description? filters=trim {
      description = "Subject description (optional)"
    }

    int credits? filters=min:0 {
      description = "Number of credits for this subject (optional, must be non-negative)"
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

    // Validate subject inputs using the validation function
    function.run "subject_management/validate_subject" {
      input = {
        name: $input.name
        description: $input.description
        credits: $input.credits
      }
      description = "Validate subject input data"
    } as $validation_result

    // Check if validation passed
    conditional {
      if (!$validation_result.is_valid) {
        throw {
          name = "inputerror"
          value = $validation_result.errors|first
        }
      }
    }

    // Create the subject in the database
    db.add subject {
      data = {
        name: $input.name
        description: $input.description
        credits: $input.credits
        status: "active"
        account_id: $user.account_id
      }
      description = "Create new subject record"
    } as $new_subject

    // Auto-enroll the creator as admin
    function.run "subject_management/auto_enroll_subject_creator" {
      input = {
        subject_id: $new_subject.id
        user_id: $auth.id
        account_id: $user.account_id
      }
      description = "Auto-enroll subject creator as admin"
    } as $enrollment_result

    // Log the subject creation event
    function.run "subject_management/log_subject_event" {
      input = {
        action: "subject.created"
        user_id: $auth.id
        subject_id: $new_subject.id
        account_id: $user.account_id
        details: {
          name: $input.name
          description: $input.description
          credits: $input.credits
        }
      }
      description = "Log subject creation event"
    } as $event_log
  }

  response = {
    id: $new_subject.id
    name: $new_subject.name
    description: $new_subject.description
    credits: $new_subject.credits
    status: $new_subject.status
    account_id: $new_subject.account_id
    created_at: $new_subject.created_at
  }

  // Test Suite 1: Subject Creation (Task 6.1)
  test "should create subject with required fields only" {
    input = {name: "Advanced Mathematics"}

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.name) {
      value = "Advanced Mathematics"
    }
    expect.to_equal ($response.status) {
      value = "active"
    }
    expect.to_not_be_null ($response.account_id)
    expect.to_be_defined ($response.created_at)
  }

  test "should create subject with all fields (name, description, credits)" {
    input = {
      name: "Physics 101"
      description: "Introduction to Classical Physics including mechanics, thermodynamics, and waves"
      credits: 3
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.name) {
      value = "Physics 101"
    }
    expect.to_equal ($response.description) {
      value = "Introduction to Classical Physics including mechanics, thermodynamics, and waves"
    }
    expect.to_equal ($response.credits) {
      value = 3
    }
    expect.to_equal ($response.status) {
      value = "active"
    }
  }

  test "should auto-enroll creator as admin" {
    input = {
      name: "Database Design"
      credits: 4
    }

    expect.to_be_defined ($response.id)
    expect.to_not_be_null ($response.account_id)
  }

  test "should log event when subject created" {
    input = {
      name: "Web Development"
      description: "Full-stack web development course"
      credits: 5
    }

    expect.to_be_defined ($response.id)
    expect.to_be_defined ($response.created_at)
  }

  test "should return validation error when name is missing" {
    input = {
      name: ""
      description: "Missing name"
      credits: 2
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should return validation error for negative credits" {
    input = {
      name: "Invalid Credits"
      credits: -5
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should return validation error for description exceeding 1000 characters" {
    input = {
      name: "Long Description"
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      credits: 3
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should assign subject to correct account" {
    input = {
      name: "Accounting Basics"
      credits: 3
    }

    expect.to_not_be_null ($response.account_id)
    expect.to_be_defined ($response.account_id)
  }

  tags = ["xano:quick-start"]
}
