// Edit activity_grades record
query "activity_grades/{activity_grades_id}" verb=PATCH {
  api_group = "Authentication"

  input {
    int activity_grades_id? filters=min:1
    dblink {
      table = "activity_grades"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch activity_grades {
      field_name = "id"
      field_value = $input.activity_grades_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $activity_grades
  }

  response = $activity_grades
}