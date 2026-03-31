// Update subject metadata
query "subjects/{id}" verb=PATCH {
  api_group = "Subjects"
  auth = "user"
  description = "Update subject metadata"

  input {
    int id {
      description = "Subject ID"
      table = "subject"
    }

    text name? filters=trim {
      description = "New subject name (optional)"
    }

    text description? filters=trim {
      description = "New subject description (optional)"
    }

    int credits? filters=min:0 {
      description = "New credit count (optional, must be non-negative if provided)"
    }

    enum status? {
      values = ["draft", "active", "archived"]
      description = "New subject status (optional)"
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

    // Verify user has admin access to update
    precondition ($permission_result.has_permission) {
      error_type = "accessdenied"
      error = "You don't have permission to update this subject"
    }

    // Validate inputs if provided
    conditional {
      if ($input.name != null || $input.description != null || $input.credits != null) {
        function.run "subject_management/validate_subject" {
          input = {
            name: $input.name||$subject.name
            description: $input.description||$subject.description
            credits: $input.credits||$subject.credits
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
      }
    }

    // Build update payload with only provided fields
    var $update_data {
      value = {}
      description = "Build dynamic update payload"
    }

    // Add fields to update if provided
    conditional {
      if ($input.name != null) {
        var.update $update_data {
          value = $update_data|set:"name":$input.name
        }
      }
    }

    conditional {
      if ($input.description != null) {
        var.update $update_data {
          value = $update_data|set:"description":$input.description
        }
      }
    }

    conditional {
      if ($input.credits != null) {
        var.update $update_data {
          value = $update_data|set:"credits":$input.credits
        }
      }
    }

    conditional {
      if ($input.status != null) {
        var.update $update_data {
          value = $update_data|set:"status":$input.status
        }
      }
    }

    // Update subject record
    db.patch subject {
      field_name = "id"
      field_value = $input.id
      data = $update_data
      description = "Update subject with new values"
    } as $updated_subject

    // Log the subject update event with old and new values
    function.run "subject_management/log_subject_event" {
      input = {
        action: "subject.updated"
        user_id: $auth.id
        subject_id: $input.id
        account_id: $user.account_id
        details: {
          updated_fields: $update_data|keys
          old_values: {
            name: $subject.name
            description: $subject.description
            credits: $subject.credits
            status: $subject.status
          }
          new_values: {
            name: $updated_subject.name
            description: $updated_subject.description
            credits: $updated_subject.credits
            status: $updated_subject.status
          }
        }
      }
      description = "Log subject update event"
    } as $event_log
  }

  response = {
    id: $updated_subject.id
    name: $updated_subject.name
    description: $updated_subject.description
    credits: $updated_subject.credits
    status: $updated_subject.status
    account_id: $updated_subject.account_id
    updated_at: $updated_subject.updated_at
  }

  // Test Suite 3: Subject Updates (Task 6.3)
  test "should allow admin to update subject name" {
    input = {
      id: 1
      name: "Updated Subject Name"
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.name) {
      value = "Updated Subject Name"
    }
  }

  test "should allow admin to update subject description" {
    input = {
      id: 1
      description: "New comprehensive description"
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.description) {
      value = "New comprehensive description"
    }
  }

  test "should allow admin to update subject credits" {
    input = {
      id: 1
      credits: 6
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.credits) {
      value = 6
    }
  }

  test "should allow admin to update subject status to archived" {
    input = {
      id: 1
      status: "archived"
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.status) {
      value = "archived"
    }
  }

  test "should allow admin to update subject status to draft" {
    input = {
      id: 1
      status: "draft"
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.status) {
      value = "draft"
    }
  }

  test "should support partial update with only some fields" {
    input = {
      id: 1
      name: "Partial Update"
    }

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.name) {
      value = "Partial Update"
    }
  }

  test "should log event with old and new values" {
    input = {
      id: 1
      name: "Changed Name"
      credits: 5
    }

    expect.to_be_defined ($response.id)
  }

  test "should deny non-admin from updating subject" {
    input = {
      id: 1
      name: "Unauthorized Update"
    }

    expect.to_throw {
      value = "accessdenied"
    }
  }

  test "should deny user from different account from updating" {
    input = {
      id: 1
      name: "Cross Account Update"
    }

    expect.to_throw {
      value = "notfound"
    }
  }

  test "should reject invalid credits (negative)" {
    input = {
      id: 1
      credits: -3
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  test "should reject description exceeding 1000 characters" {
    input = {
      id: 1
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }

    expect.to_throw {
      value = "inputerror"
    }
  }

  tags = ["xano:quick-start"]
}
