// Junction table for managing user enrollments in subjects with assigned roles
table subject_enrollment {
  auth = false

  schema {
    // Unique identifier for the enrollment
    int id
  
    // Subject the user is enrolled in
    int subject_id {
      table = "subject"
    }
  
    // User who is enrolled in the subject
    int user_id {
      table = "user"
    }
  
    // Role of the user within the subject (learner, instructor, or admin)
    enum subject_role {
      values = ["learner", "instructor", "admin"]
    }
  
    // Account that owns this enrollment (for auditing purposes)
    int account_id {
      table = "account"
    }
  
    // Timestamp when the enrollment was created
    timestamp created_at?=now {
      visibility = "private"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {
      type : "btree|unique"
      field: [
        {name: "subject_id", op: "asc"}
        {name: "user_id", op: "asc"}
      ]
    }
    {type: "btree", field: [{name: "account_id", op: "asc"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  tags = ["xano:quick-start"]
}