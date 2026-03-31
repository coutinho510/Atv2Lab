// Count total enrollments in a subject
// Optionally filters by subject_role to count specific role types
// Usage: Load this in queries to quickly fetch enrollment totals for dashboards
addon subject_enrollment_count {
  input {
    // ID of the subject to count enrollments for
    int subject_id? {
      table = "subject"
    }
  
    // Optional role filter - only count enrollments with this specific role
    enum subject_role? {
      values = ["learner", "instructor", "admin"]
    }
  }

  stack {
    db.query subject_enrollment {
      where = $db.subject_enrollment.subject_id == $input.subject_id && $db.subject_enrollment.subject_role ==? $input.subject_role
      return = {type: "count"}
    }
  }
}