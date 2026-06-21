// Add activity_grades record
query activity_grades verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "activity_grades"
    }
  }

  stack {
    db.add activity_grades {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $activity_grades
  }

  response = $activity_grades
}