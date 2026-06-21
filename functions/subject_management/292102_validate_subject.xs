// Validates subject input during creation and updates
// Checks for required fields, valid ranges, and data constraints
// Validate subject input data (name, description, credits)
function "subject_management/validate_subject" {
  input {
    // Subject name - must be provided and non-empty
    text name filters=trim
  
    // Optional subject description
    text description? filters=trim
  
    // Optional credit hours - must be non-negative if provided
    int credits? filters=min:0
  }

  stack {
    // Initialize error collection array
    // Array to collect all validation errors
    var $errors {
      value = []
    }
  
    // Validate: name is required and not empty
    conditional {
      if ($input.name == null || ($input.name|strlen) == 0) {
        // Check if name is empty
        array.push $errors {
          value = "Name is required"
        }
      }
    }
  
    // Validate: credits must be non-negative (if provided)
    conditional {
      if ($input.credits != null && $input.credits < 0) {
        // Check credits constraint
        array.push $errors {
          value = "Credits must be >= 0"
        }
      }
    }
  
    // Validate: description should not exceed 1000 characters (if provided)
    conditional {
      if ($input.description != null && ($input.description|strlen) > 1000) {
        // Check description length
        array.push $errors {
          value = "Description must not exceed 1000 characters"
        }
      }
    }
  
    // Determine if input is valid
    // Valid if no errors collected
    var $is_valid {
      value = ($errors|count) == 0
    }
  }

  response = {is_valid: $is_valid, errors: $errors}
  tags = ["xano:quick-start"]
}