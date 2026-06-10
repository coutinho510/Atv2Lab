query "subjects/list" verb=GET {
  api_group = "subjects"
  description = "Retrieve all subjects for the authenticated user with activity status"
  auth = "user"

  input {
    int page?=1 filters=min:1 {
      description = "Page number for pagination"
    }
    int per_page?=10 filters=min:1|max:100 {
      description = "Items per page (max 100)"
    }
  }

  stack {
    db.query "subject" {
      description = "Fetch all subjects for authenticated user"
      where = $db.subject.user_id == $auth.id
      sort = {subject.created_at: "desc"}
      return = {
        type: "list"
        paging: {
          page: $input.page
          per_page: $input.per_page
          totals: true
        }
      }
      addon = [
        {
          name: "subject_activity_count"
          input: {subject_id: $output.id}
          as: "items.activity_count"
        }
        {
          name: "subject_overdue_count"
          input: {subject_id: $output.id}
          as: "items.overdue_count"
        }
      ]
    } as $subjects_list
  }

  response = $subjects_list

  history = "inherit"

  test "list subjects for authenticated user" {
    input = {
      page: 1
      per_page: 10
    }
    expect.to_have_key ($response) {
      value = "items"
    }
  }

  test "subjects list has pagination" {
    input = {
      page: 1
      per_page: 5
    }
    expect.to_have_key ($response) {
      value = "curPage"
    }
  }
}
