// Query all activity_grades records
query activity_grades verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query activity_grades {
      return = {type: "list"}
    } as $activity_grades
  }

  response = $activity_grades
}