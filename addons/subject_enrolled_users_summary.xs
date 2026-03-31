// Fetch summary list of enrolled users in a subject with their roles
// Joins subject_enrollment with user table to include user details
// Returns user information and enrollment metadata
// Usage: Load this in queries to display subject member rosters or enrollment lists
addon subject_enrolled_users_summary {
  input {
    // ID of the subject to fetch enrolled users for
    int subject_id? {
      table = "subject"
    }
  }

  stack {
    db.query subject_enrollment {
      join = {
        user: {
          table: "user"
          where: $db.subject_enrollment.user_id == $db.user.id
        }
      }
    
      where = $db.subject_enrollment.subject_id == $input.subject_id
      sort = {subject_enrollment.created_at: "desc"}
      eval = {name: $db.user.name, email: $db.user.email}
      return = {type: "list"}
    }
  }
}