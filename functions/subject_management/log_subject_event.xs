// Wrapper to standardize event logging for subject operations
// Handles optional fields gracefully and builds consistent event records
// Log standardized subject-related events to event_log table
function "subject_management/log_subject_event" {
  input {
    // Action being logged (e.g., 'subject.created', 'subject.enrollment.added')
    text action
  
    // User who performed the action
    int user_id {
      table = "user"
    }
  
    // Subject ID associated with the event (optional)
    int subject_id?
  
    // Enrollment ID associated with the event (optional)
    int enrollment_id?
  
    // Additional event context data
    json details?
  
    // Account ID for event association (optional)
    int account_id?
  }

  stack {
    // Tracks whether logging succeeded
    var $success {
      value = false
    }
  
    // ID of created event_log record
    var $event_id {
      value = null
    }
  
    // Error message if logging fails
    var $error {
      value = null
    }
  
    // Build metadata object with subject/enrollment IDs and additional details
    // Event metadata containing subject and enrollment info
    var $metadata {
      value = {}
    }
  
    // Add subject_id if provided
    conditional {
      if ($input.subject_id != null) {
        // Include subject_id in metadata
        var.update $metadata {
          value = $metadata
            |set:"subject_id":$input.subject_id
        }
      }
    }
  
    // Add enrollment_id if provided
    conditional {
      if ($input.enrollment_id != null) {
        // Include enrollment_id in metadata
        var.update $metadata {
          value = $metadata
            |set:"enrollment_id":$input.enrollment_id
        }
      }
    }
  
    // Merge in any additional details provided
    conditional {
      if ($input.details != null) {
        // Merge additional details into metadata
        var.update $metadata {
          value = $metadata|merge_recursive:$input.details
        }
      }
    }
  
    try_catch {
      try {
        // Create event_log record
        // Create event_log record for subject event
        db.add event_log {
          data = {
            created_at: "now"
            user_id   : $input.user_id
            account_id: $input.account_id
            action    : $input.action
            metadata  : $metadata
          }
        } as $new_event
      
        // Store created event ID
        var.update $event_id {
          value = $new_event.id
        }
      
        // Mark logging as successful
        var.update $success {
          value = true
        }
      }
    
      catch {
        // Mark logging as failed
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

  response = {success: $success, event_id: $event_id, error: $[""]}
  tags = ["xano:quick-start"]
}