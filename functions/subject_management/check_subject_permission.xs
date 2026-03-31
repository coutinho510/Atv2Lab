// Checks if a user has the required role on a subject
// Supports hierarchical role checking: admin > instructor > learner
// Check if user has required role on subject with hierarchy support
function "subject_management/check_subject_permission" {
  input {
    // User ID to check
    int user_id {
      table = "user"
    }
  
    // Subject ID to check permission on
    int subject_id {
      table = "subject"
    }
  
    // Required role. 'any' = any enrollment, specific role = hierarchical check
    enum required_role?=any {
      values = ["learner", "instructor", "admin", "any"]
    }
  }

  stack {
    // Query for user enrollment in the subject
    // Find user's enrollment in the subject
    db.query subject_enrollment {
      where = $db.subject_enrollment.subject_id == $input.subject_id && $db.subject_enrollment.user_id == $input.user_id
      return = {type: "single"}
    } as $enrollment
  
    // Tracks permission result
    var $has_permission {
      value = false
    }
  
    // The user's actual role on the subject
    var $user_role {
      value = null
    }
  
    // If no enrollment exists, permission is denied
    conditional {
      if ($enrollment == null) {
        // No enrollment found
        var.update $has_permission {
          value = false
        }
      
        // User has no role
        var.update $user_role {
          value = null
        }
      }
    
      else {
        // User is enrolled - update user_role
        // Set the user's role from enrollment record
        var.update $user_role {
          value = $enrollment.subject_role
        }
      
        // Check permission based on required_role
        conditional {
          // If "any" role required, user has permission
          if ($input.required_role == "any") {
            // User has any enrollment = permission granted
            var.update $has_permission {
              value = true
            }
          }
        
          // If specific role required, check hierarchy
          elseif ($input.required_role == "admin") {
            // Admin role check
            var.update $has_permission {
              value = $enrollment.subject_role == "admin"
            }
          }
        
          elseif ($input.required_role == "instructor") {
            // instructor or admin qualifies
            // Instructor or admin check
            var.update $has_permission {
              value = $enrollment.subject_role == "instructor" || $enrollment.subject_role == "admin"
            }
          }
        
          elseif ($input.required_role == "learner") {
            // Any role qualifies as learner (everyone can view)
            // Learner role check (all enrolled users)
            var.update $has_permission {
              value = true
            }
          }
        }
      }
    }
  }

  response = {has_permission: $has_permission, user_role: $user_role}
  tags = ["xano:quick-start"]
}