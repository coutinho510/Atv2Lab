// Get details of a specific subject
query "subjects/{id}" verb=GET {
  api_group = "Subjects"
  auth = "user"
  description = "Get details of a specific subject"

  input {
    int id {
      description = "Subject ID"
      table = "subject"
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

    // Check user's permission on this subject (any enrollment)
    function.run "subject_management/check_subject_permission" {
      input = {
        user_id: $auth.id
        subject_id: $input.id
        required_role: "any"
      }
      description = "Check if user has any enrollment in subject"
    } as $permission_result

    // Verify user has access to this subject
    precondition ($permission_result.has_permission) {
      error_type = "accessdenied"
      error = "You don't have access to this subject"
    }
  }

  response = {
    id: $subject.id
    name: $subject.name
    description: $subject.description
    credits: $subject.credits
    status: $subject.status
    account_id: $subject.account_id
    subject_role: $permission_result.user_role
    created_at: $subject.created_at
    updated_at: $subject.updated_at
  }

  // Test Suite 2b: Subject Single Retrieval (Task 6.2 - GET Single)
  test "should get single subject by ID for enrolled user" {
    input = {id: 1}

    expect.to_be_defined ($response.id)
    expect.to_equal ($response.id) {
      value = 1
    }
  }

  test "should include all required fields in response" {
    input = {id: 1}

    expect.to_be_defined ($response.id)
    expect.to_be_defined ($response.name)
    expect.to_be_defined ($response.description)
    expect.to_be_defined ($response.credits)
    expect.to_be_defined ($response.status)
    expect.to_be_defined ($response.account_id)
    expect.to_be_defined ($response.subject_role)
    expect.to_be_defined ($response.created_at)
  }

  test "should return not found for non-existent subject" {
    input = {id: 99999}

    expect.to_throw {
      value = "notfound"
    }
  }

  test "should deny access when user not enrolled in subject" {
    input = {id: 1}

    expect.to_throw {
      value = "accessdenied"
    }
  }

  test "should deny access to subjects from different account" {
    input = {id: 1}

    expect.to_throw {
      value = "notfound"
    }
  }

  test "should return correct subject_role for user" {
    input = {id: 1}

    expect.to_not_be_null ($response.subject_role)
  }

  tags = ["xano:quick-start"]
}
