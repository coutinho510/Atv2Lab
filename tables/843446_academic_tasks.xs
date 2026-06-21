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
  
    // Account ID for multi-tenancy
    int account_id {
      table = "account"
    }
  
    // Task creation timestamp
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text data? filters=trim
    enum status_tarefa?=pendente {
      values = ["pendente", "completa", "em_progresso"]
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "subject_id", op: "asc"}]}
    {type: "btree", field: [{name: "user_id", op: "asc"}]}
    {type: "btree", field: [{name: "account_id", op: "asc"}]}
  ]

  tags = ["xano:quick-start"]
}