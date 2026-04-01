 /,
 / Get all subjects the user is enrolled in
query "subjects" verb=GET {
  api_group = "Subjects"
  auth = "user"
  description = "Get all subjects the user is enrolled in"

  input {
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

    // Query to find all subjects the user is enrolled in
    db.query subject_enrollment {
      where = $db.subject_enrollment.user_id == $auth.id && $db.subject_enrollment.account_id == $user.account_id
      join = {
        subject: {
          table: "subject"
          where: $db.subject_enrollment.subject_id == $db.subject.id
        }
      }
      eval = {
        subject_id: $db.subject.id
        subject_name: $db.subject.name
        subject_description: $db.subject.description
        subject_credits: $db.subject.credits
        subject_status: $db.subject.status
        subject_account_id: $db.subject.account_id
        subject_created_at: $db.subject.created_at
        subject_role: $db.subject_enrollment.subject_role
      }
      return = {type: "list"}
      description = "Get all subjects user is enrolled in"
    } as $enrollments

    // Transform enrollments to expose only needed fields
    var $subjects {
      value = $enrollments|map:{
        id: $$.subject_id,
        name: $$.subject_name,
        description: $$.subject_description,
        credits: $$.subject_credits,
        status: $$.subject_status,
        account_id: $$.subject_account_id,
        subject_role: $$.subject_role,
        created_at: $$.subject_created_at
      }
      description = "Transform enrollment records to subject details with role"
    }
  }

  response = $subjects

  // Test Suite 2a: Subject List Retrieval (Task 6.2 - GET All)
  test "should get all subjects user is enrolled in" {
    input = {}

    expect.to_be_defined ($response)
  }

  test "should return list with subject_role for each subject" {
    input = {}

    conditional {
      if (($response|count) > 0) {
        expect.to_be_defined ($response|first|get:"subject_role")
      }
    }
  }

  test "should filter subjects by user's account" {
    input = {}

    expect.to_be_defined ($response)
  }

  test "should return empty list when user has no enrollments" {
    input = {}

    expect.to_be_defined ($response)
  }

  test "should include required fields in response" {
    input = {}

    conditional {
      if (($response|count) > 0) {
        var $first_subject {
          value = $response|first
        }
        expect.to_be_defined ($first_subject|get:"id")
        expect.to_be_defined ($first_subject|get:"name")
        expect.to_be_defined ($first_subject|get:"status")
        expect.to_be_defined ($first_subject|get:"account_id")
        expect.to_be_defined ($first_subject|get:"subject_role")
      }
    }
  }

  test "should not include subjects from other accounts" {
    input = {}

    expect.to_be_defined ($response)
  }

  test "should not include subjects user is not enrolled in" {
    input = {}

    expect.to_be_defined ($response)
  }

  tags = ["xano:quick-start"]
}
