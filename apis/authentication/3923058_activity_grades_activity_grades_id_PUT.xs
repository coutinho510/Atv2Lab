// Update activity_grades record
query "activity_grades/{activity_grades_id}" verb=PUT {
  api_group = "Authentication"

  input {
    int activity_grades_id? filters=min:1
    dblink {
      table = "activity_grades"
    }
  }

  stack {
    db.edit activity_grades {
      field_name = "id"
      field_value = $input.activity_grades_id
      enforce_hidden_fields = false
      data = {
        academic_tasks_id: $input.academic_tasks_id
        grade            : $input.grade
      }
    } as $model
  }

  response = $model
}