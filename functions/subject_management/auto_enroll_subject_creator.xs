// Automatically enrolls the creator as "admin" when a subject is created
// Prevents duplicate enrollments if the creator is already enrolled
// Auto-enroll subject creator as admin and prevent duplicates
function "subject_management/auto_enroll_subject_creator" {
  input {
    // Subject ID to enroll user in
    int subject_id {
      table = "subject"
    }
  
    // User ID being enrolled (the creator)
    int user_id {
      table = "user"
    }
  
    // Account ID for auditing purposes
    int account_id {
      table = "account"
    }
  }

  stack {
    // Tracks whether enrollment succeeded
    var $success {
      value = false
    }
  
    // ID of created or existing enrollment
    var $enrollment_id {
      value = null
    }
  
    // Error message if operation fails
    var $error {
      value = null
    }
  
    try_catch {
      try {
        // Check for existing enrollment
        // Query for existing enrollment
        db.get subject_enrollment {
          field_name = "subject_id"
          field_value = $input.subject_id
        } as $existing_enrollment
      
        // If enrollment doesn't exist, create it
        conditional {
          if ($existing_enrollment == null) {
            // Create admin enrollment for creator
            db.add subject_enrollment {
              data = {
                subject_id  : $input.subject_id
                user_id     : $input.user_id
                subject_role: "admin"
                account_id  : $input.account_id
              }
            } as $new_enrollment
          
            // Store newly created enrollment ID
            var.update $enrollment_id {
              value = $new_enrollment.id
            }
          
            // Mark operation as successful
            var.update $success {
              value = true
            }
          }
        
          else {
            // Enrollment already exists - reuse it
            // Store existing enrollment ID
            var.update $enrollment_id {
              value = $existing_enrollment.id
            }
          
            // Mark operation as successful (existing enrollment)
            var.update $success {
              value = true
            }
          }
        }
      }
    
      catch {
        // Mark as failed on error
        var.update $success {
          value = false
        }
      
        // Capture error message
        var.update $error {
          value = $error[""]
        }
      }
    }
  }

  response = {
    success      : $success
    enrollment_id: $enrollment_id
    error        : $[""]
  }

  tags = ["xano:quick-start"]
}