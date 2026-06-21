// Delete activity_grades record.
query "activity_grades/{activity_grades_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int activity_grades_id? filters=min:1
  }

  stack {
    db.del activity_grades {
      field_name = "id"
      field_value = $input.activity_grades_id
    }
  }

  response = null
}