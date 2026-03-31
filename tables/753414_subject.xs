// Stores subjects/courses that belong to an account
table subject {
  auth = false

  schema {
    // Unique identifier for the subject
    int id
  
    // Name of the subject
    text name filters=trim
  
    // Detailed description of the subject
    text description? filters=trim
  
    // Number of credits associated with the subject (non-negative)
    int credits? filters=min:0
  
    // Status of the subject (draft, active, or archived)
    enum status?=active {
      values = ["draft", "active", "archived"]
    }
  
    // Account that owns this subject
    int account_id {
      table = "account"
    }
  
    // Timestamp when the subject was created
    timestamp created_at?=now {
      visibility = "private"
    }
  
    // Timestamp when the subject was last updated
    timestamp updated_at?=now {
      visibility = "private"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "account_id", op: "asc"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
    {
      type : "btree|unique"
      field: [{name: "account_id", op: "asc"}, {name: "name", op: "asc"}]
    }
  ]

  tags = ["xano:quick-start"]
}