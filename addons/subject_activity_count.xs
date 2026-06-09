addon "subject_activity_count" {
  description = "Count total activities for a subject"
  
  input {
    int subject_id {
      description = "Subject ID to count activities for"
    }
  }

  stack {
    db.query "academic_activity" {
      where = $db.academic_activity.subject_id == $input.subject_id
      return = {type: "count"}
    } as $count
  }

  response = $count
}
