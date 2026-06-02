// description = "Deleta uma disciplina do usuário autenticado."
// group = "subjects"

auth.require_login();

input subject_id int;

db.delete subjects {
    id: $subject_id,
    user_id: $auth.id
};