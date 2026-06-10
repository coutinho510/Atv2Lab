addon "subject_overdue_count" {
  description = "Count overdue activities for a subject"
  
  input {
    int subject_id {
      description = "Subject ID to count overdue activities for"
    }
  }

  stack {
    db.query "academic_activity" {
      where = $db.academic_activity.subject_id == $input.subject_id && $db.academic_activity.due_date < now && $db.academic_activity.status != "completed"
      return = {type: "count"}
    } as $overdue_count
  }

  response = $overdue_count
}
