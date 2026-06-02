// description = "Cria uma nova disciplina para o usuário autenticado."
// group = "subjects"

auth.require_login();

input name text;
input teacher_name text?;

db.add subjects {
    user_id: $auth.id,
    name: $name,
    teacher_name: $teacher_name
};