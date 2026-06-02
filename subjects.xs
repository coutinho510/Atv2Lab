table subjects {
  // O 'user_id' é uma referência à tabela 'user' que já existe no Xano.
  // Isso garante que cada disciplina pertence a um usuário.
  table_ref user_id "user";

  // Nome da disciplina, campo obrigatório.
  text name;

  // Nome do professor, campo opcional.
  text professor?;

  // Índice para otimizar buscas pelo 'user_id'.
  index(user_id);
}