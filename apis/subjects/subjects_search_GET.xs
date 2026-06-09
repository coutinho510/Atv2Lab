query "subjects/search" verb=GET {
  api_group = "subjects"
  description = "Search subjects by name for authenticated user"
  auth = "user"

  input {
    text query filters=trim {
      description = "Search term to find subjects by name"
    }
    int page?=1 filters=min:1 {
      description = "Page number for pagination"
    }
    int per_page?=10 filters=min:1|max:100 {
      description = "Items per page (max 100)"
    }
  }

  stack {
    // Validate query is not empty
    precondition (($input.query|strlen) > 0) {
      description = "Search query cannot be empty"
      error_type = "inputerror"
      error = "Search query must not be empty"
    }

    precondition (($input.query|strlen) <= 100) {
      description = "Search query is too long"
      error_type = "inputerror"
      error = "Search query must be 100 characters or less"
    }

    // Search for subjects matching the query
    db.query "subject" {
      description = "Search subjects by name for authenticated user"
      where = $db.subject.user_id == $auth.id && $db.subject.name includes $input.query
      sort = {subject.name: "asc"}
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
    } as $search_results

    debug.log {
      value = {
        event: "subject_search",
        user_id: $auth.id,
        query: $input.query,
        results_found: ($search_results.items|count)
      }
    }
  }

  response = $search_results

  history = "inherit"

  test "search subjects by name" {
    input = {
      query: "Math"
      page: 1
      per_page: 10
    }
    expect.to_have_key ($response) {
      value = "items"
    }
  }

  test "search with pagination" {
    input = {
      query: "Science"
      page: 1
      per_page: 5
    }
    expect.to_have_key ($response) {
      value = "perPage"
    }
  }

  test "search returns empty results" {
    input = {
      query: "NonExistentSubject123"
      page: 1
      per_page: 10
    }
    expect.to_equal (($response.items|count)) {
      value = 0
    }
  }
}
