// Efficiently retrieve all subjects a user is enrolled in with enrollment details
function "subject_management/get_user_subjects" {
  input {
    int user_id
    int account_id?
    bool include_details?=true
  }

  stack {
    // Validate user_id
    precondition ($input.user_id > 0) {
      error_type = "inputerror"
      error = "user_id must be a positive integer"
    }
  
    // Fetch account_id if not provided
    var $account_id {
      value = $input.account_id
    }
  
    conditional {
      if ($account_id == null) {
        db.get user {
          field_name = "id"
          field_value = $input.user_id
        } as $user
      
        precondition ($user != null) {
          error_type = "notfound"
          error = "User not found"
        }
      
        var.update $account_id {
          value = $user.account_id
        }
      }
    }
  
    precondition ($account_id != null) {
      error_type = "inputerror"
      error = "account_id could not be determined"
    }
  
    // Query enrollments with subject details
    db.query subject_enrollment {
      join = {
        subject: {
          table: "subject"
          where: $db.subject_enrollment.subject_id == $db.subject.id
        }
      }
    
      where = $db.subject_enrollment.user_id == $input.user_id && $db.subject_enrollment.account_id == $account_id
      sort = {subject_enrollment.created_at: "desc"}
      eval = {
        subject_name       : $db.subject.name
        subject_description: $db.subject.description
        subject_credits    : $db.subject.credits
        subject_status     : $db.subject.status
      }
    
      return = {type: "list"}
    } as $enrollments
  
    var $results {
      value = []
    }
  
    foreach ($enrollments) {
      each as $enrollment {
        var $result_item {
          value = ```
            (
                        $input.include_details == true
                        ? {
                          subject_id: $enrollment.subject_id
                          subject_name: $enrollment.subject_name
                          description: $enrollment.subject_description
                          credits: $enrollment.subject_credits
                          status: $enrollment.subject_status
                          subject_role: $enrollment.subject_role
                          enrolled_at: $enrollment.created_at
                        }
                        : {
                          subject_id: $enrollment.subject_id
                          subject_role: $enrollment.subject_role
                          enrolled_at: $enrollment.created_at
                        }
                      )
            ```
        }
      
        array.push $results {
          value = $result_item
        }
      }
    }
  }

  response = {subjects: $results, count: $results|count}

  test "should retrieve subjects with full details" {
    input = {user_id: 1, include_details: true}
  
    expect.to_be_defined ($response.subjects)
  }

  test "should retrieve subjects with minimal details" {
    input = {user_id: 1, include_details: false}
  
    expect.to_be_defined ($response.subjects)
  }
}