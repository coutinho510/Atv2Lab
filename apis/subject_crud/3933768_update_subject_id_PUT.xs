// Update an existing subject
// Modifies a record in the subject table by its ID.
// Update a subject
query "update/{subject_id}" verb=PUT {
  api_group = "Subject CRUD"
  auth = "user"

  input {
    // Subject ID to update
    int subject_id
  
    // Name of the subject
    text name? filters=trim
  
    // Professor name
    text professor? filters=trim
  
    // Workload in hours
    int cargahoraria? filters=min:0
  
    // Status of the subject
    enum status? {
      values = ["rascunho", "ativo", "arquivado"]
    }
  
    // Período/semestre da disciplina (ex.: "2026.1")
    text periodo? filters=trim
  }

  stack {
    // First, verify the subject exists
    db.get subject {
      field_name = "id"
      field_value = $input.subject_id
    } as $existing
  
    precondition ($existing != null && $existing.user_id == $auth.id) {
      error_type = "notfound"
      error = "Subject not found OR Not your subject to update"
    }
  
    // Build the update object (only include provided fields)
    var $update_data {
      value = {updated_at: now}
    }
  
    conditional {
      if ($input.name != null) {
        var.update $update_data {
          value = $update_data|set:"name":$input.name
        }
      }
    }
  
    conditional {
      if ($input.professor != null) {
        var.update $update_data {
          value = $update_data|set:"professor":$input.professor
        }
      }
    }
  
    conditional {
      if ($input.cargahoraria != null) {
        var.update $update_data {
          value = $update_data
            |set:"cargahoraria":$input.cargahoraria
        }
      }
    }
  
    conditional {
      if ($input.status != null) {
        var.update $update_data {
          value = $update_data|set:"status":$input.status
        }
      }
    }
  
    conditional {
      if ($input.periodo != null) {
        var.update $update_data {
          value = $update_data|set:"periodo":$input.periodo
        }
      }
    }
  
    db.patch subject {
      field_name = "id"
      field_value = $input.subject_id
      data = $update_data
    } as $updated_subject
  }

  response = $updated_subject
}