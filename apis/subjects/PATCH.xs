// description = "Atualiza uma disciplina existente do usuário autenticado."
// group = "subjects"

auth.require_login();

input subject_id int;
input name text?;
input teacher_name text?;

db.edit subjects {
    id: $subject_id,
    user_id: $auth.id
} with {
    name: $name,
    teacher_name: $teacher_name
};