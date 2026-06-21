// Delete a subject
// Removes a record from the subject table by its ID.
// Delete a subject
query "delete/{subject_id}" verb=DELETE {
  api_group = "Subject CRUD"
  auth = "user"

  input {
    // Subject ID to delete
    int subject_id
  }

  stack {
    // First, verify the subject exists
    db.get subject {
      field_name = "id"
      field_value = $input.subject_id
    } as $existing
  
    precondition ($auth.id == $existing.user_id) {
      error_type = "accessdenied"
      error = "Its not your user"
    }
  
    precondition ($existing != null) {
      error_type = "notfound"
      error = "Subject not found"
    }
  
    db.del subject {
      field_name = "id"
      field_value = $input.subject_id
    }
  }

  response = {
    message: "Subject deleted successfully"
    id     : $input.subject_id
  }
}