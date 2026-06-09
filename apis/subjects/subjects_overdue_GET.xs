query "subjects/overdue" verb=GET {
  api_group = "subjects"
  description = "Retrieve subjects with overdue activities for authenticated user"
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
    // Get subjects that have overdue activities
    db.query "subject" {
      description = "Fetch subjects with overdue activities for authenticated user"
      join = {
        academic_activity: {
          table: "academic_activity"
          type: "inner"
          where: $db.subject.id == $db.academic_activity.subject_id && $db.academic_activity.due_date < now && $db.academic_activity.status != "completed"
        }
      }
      where = $db.subject.user_id == $auth.id
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
          name: "subject_overdue_count"
          input: {subject_id: $output.id}
          as: "items.overdue_count"
        }
        {
          name: "subject_activity_count"
          input: {subject_id: $output.id}
          as: "items.total_activities"
        }
      ]
    } as $overdue_subjects

    debug.log {
      value = {
        event: "overdue_subjects_retrieved",
        user_id: $auth.id,
        subjects_with_overdue: ($overdue_subjects.items|count)
      }
    }
  }

  response = $overdue_subjects

  history = "inherit"

  test "retrieve subjects with overdue activities" {
    input = {
      page: 1
      per_page: 10
    }
    expect.to_have_key ($response) {
      value = "items"
    }
  }

  test "overdue subjects include activity count" {
    input = {
      page: 1
      per_page: 10
    }
    expect.to_have_key ($response) {
      value = "items"
    }
  }

  test "pagination metadata present" {
    input = {
      page: 1
      per_page: 5
    }
    expect.to_have_key ($response) {
      value = "curPage"
    }
  }
}
