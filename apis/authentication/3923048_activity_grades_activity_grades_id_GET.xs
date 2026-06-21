// Get activity_grades record
query "activity_grades/{activity_grades_id}" verb=GET {
  api_group = "Authentication"

  input {
    int activity_grades_id? filters=min:1
  }

  stack {
    db.get activity_grades {
      field_name = "id"
      field_value = $input.activity_grades_id
    } as $activity_grades
  
    precondition ($activity_grades != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $activity_grades
}