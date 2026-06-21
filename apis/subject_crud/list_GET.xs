// List all subjects
// Returns all records from the subject table.
// Get all subjects
query list verb=GET {
  api_group = "Subject CRUD"
  auth = "user"

  input {
  }

  stack {
    db.query subject {
      where = $auth.id == $db.subject.user_id
      return = {type: "list"}
    } as $subjects
  }

  response = $subjects
}
