// Table for managing academic tasks/assignments
table academic_tasks {
  auth = false

  schema {
    // Unique task identifier
    int id
  
    // User who created the task (student)
    int user_id {
      table = "user"
    }
  
    // Subject this task belongs to
    int subject_id {
      table = "subject"
    }
  
    // Task title
    text title
  
    // Detailed task description
    text description?
  
    // Task due date
    timestamp due_date?
  
    // Task status (pending, in-progress, completed)
    text status?=pending
  
    // Account ID for multi-tenancy
    int account_id {
      table = "account"
    }
  
    // Task creation timestamp
    timestamp created_at?=now {
      visibility = "private"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "subject_id", op: "asc"}]}
    {type: "btree", field: [{name: "user_id", op: "asc"}]}
    {type: "btree", field: [{name: "account_id", op: "asc"}]}
    {type: "btree", field: [{name: "due_date", op: "asc"}]}
  ]

  tags = ["xano:quick-start"]
}