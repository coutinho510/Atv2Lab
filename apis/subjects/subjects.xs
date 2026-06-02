table subjects {
  text name {
    description = "O nome da disciplina (ex: Cálculo I)."
  }

  text teacher_name {
    description = "O nome do professor da disciplina."
  }

  int user_id {
    description = "ID do usuário proprietário da disciplina."
    relation = users.id
  }
}