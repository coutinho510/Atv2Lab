function "subject_management/get_user_subjects" {
  description = "Efficiently retrieve all subjects a user is enrolled in with enrollment details. Uses optimized joins and evals to minimize queries."

  input {
    int user_id {
      description = "The user whose subjects to fetch"
    }

    int account_id? {
      description = "Filter by specific account. If not provided, fetches from user table"
    }

    bool include_details?=true {
      description = "Include full subject details (name, description, credits, status) or just IDs and roles. Default: true"
    }
  }

  stack {
    // Validate user_id
    precondition ($input.user_id > 0) {
      error_type = "inputerror"
      error = "user_id must be a positive integer"
      description = "Ensure user_id is valid"
    }

    var $account_id {
      value = $input.account_id
      description = "Account ID to filter enrollments by"
    }

    // If account_id not provided, fetch from user table
    conditional {
      if ($account_id == null) {
        try_catch {
          try {
            db.get "user" {
              field_name = "id"
              field_value = $input.user_id
              description = "Fetch user to get account_id"
            } as $user

            precondition ($user != null) {
              error_type = "notfound"
              error = "User not found"
              description = "User with given ID does not exist"
            }

            var.update $account_id {
              value = $user.account_id
              description = "Extract account_id from user record"
            }
          }

          catch {
            throw {
              name = "UserLookupError"
              value = "Failed to retrieve user account information: " ~ $error
            }
          }
        }
      }
    }

    // Validate account_id was obtained
    precondition ($account_id != null) {
      error_type = "inputerror"
      error = "account_id could not be determined for the user"
      description = "Ensure account_id is available"
    }

    var $results {
      value = []
      description = "Array to store formatted subject enrollment results"
    }

    var $error_message {
      value = null
      description = "Error message if query fails"
    }

    try_catch {
      try {
        // Query subject enrollments with joined subject details
        // Uses efficient join and eval to get all needed data in one query
        db.query "subject_enrollment" {
          where = $db.subject_enrollment.user_id == $input.user_id && $db.subject_enrollment.account_id == $account_id
          
          join = {
            subject: {
              table: "subject"
              type: "inner"
              where: $db.subject_enrollment.subject_id == $db.subject.id
              description = "Join with subject table to get subject details"
            }
          }

          eval = {
            subject_name: $db.subject.name
            subject_description: $db.subject.description
            subject_credits: $db.subject.credits
            subject_status: $db.subject.status
            description = "Eval subject fields for easier access in response"
          }

          sort = {subject_enrollment.created_at: "desc"}
          return = {type: "list"}
          description = "Fetch enrollments sorted by most recent first"
        } as $enrollments

        // Build results array based on include_details flag
        foreach ($enrollments) {
          each as $enrollment {
            var $result_item {
              value = null
              description = "Result item for current enrollment"
            }

            conditional {
              if ($input.include_details == true) {
                // Full details response
                var.update $result_item {
                  value = {
                    subject_id: $enrollment.subject_id
                    subject_name: $enrollment.subject_name
                    description: $enrollment.subject_description
                    credits: $enrollment.subject_credits
                    status: $enrollment.subject_status
                    subject_role: $enrollment.subject_role
                    enrolled_at: $enrollment.created_at
                    subject_account_id: $enrollment.account_id
                  }
                  description = "Full enrollment details with subject information"
                }
              }

              else {
                // Minimal details response
                var.update $result_item {
                  value = {
                    subject_id: $enrollment.subject_id
                    subject_role: $enrollment.subject_role
                    enrolled_at: $enrollment.created_at
                  }
                  description = "Minimal enrollment details (ID, role, date)"
                }
              }
            }

            array.push $results {
              value = $result_item
              description = "Add formatted enrollment to results"
            }
          }
        }
      }

      catch {
        var.update $error_message {
          value = "Failed to retrieve user subjects: " ~ $error
          description = "Capture database query error"
        }
      }
    }
  }

  response = {
    subjects: $results
    count: ($results|count)
    error: $error_message
  }

  test "should retrieve user subjects with full details" {
    input = {
      user_id: 1
      include_details: true
    }

    expect.to_be_defined ($response.subjects)
    expect.to_be_defined ($response.count)
    expect.to_equal ($response.error) {
      value = null
    }
  }

  test "should retrieve user subjects with minimal details" {
    input = {
      user_id: 1
      include_details: false
    }

    expect.to_be_defined ($response.subjects)
    expect.to_equal ($response.error) {
      value = null
    }
  }

  test "should load user account if not provided" {
    input = {
      user_id: 1
      include_details: true
    }

    expect.to_be_defined ($response.count)
  }

  test "should return error for invalid user_id" {
    input = {
      user_id: -1
    }

    expect.to_throw {
      value = "user_id must be a positive integer"
    }
  }
}
