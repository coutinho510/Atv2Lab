// Get a single subject by ID
// Returns a single record from the subject table by its ID.
// Get a subject by ID
query "get/{subject_id}" verb=GET {
  api_group = "Subject CRUD"
  auth = "user"

  input {
    // Subject ID
    int subject_id
  }

  stack {
    db.get subject {
      field_name = "id"
      field_value = $input.subject_id
    } as $subject

    precondition ($subject != null && $subject.user_id == $auth.id) {
      error_type = "notfound"
      error = "Subject not found OR Not your subject"
    }
  }

  response = $subject
}
