// function search_subjects_logic
// description: Orquestra a busca de disciplinas, permitindo filtrar por nome e/ou por tarefas atrasadas.

// Entradas da função
input text? search_term "Termo para buscar no nome da disciplina"
input boolean? has_overdue_tasks "Se verdadeiro, filtra apenas disciplinas com tarefas atrasadas"

// 1. Inicia buscando todas as disciplinas para ter uma base.
//    Em um cenário real, otimizaríamos isso para filtrar já no banco de dados.
db.query "subject" as subjects

// 2. Prepara uma variável para armazenar os resultados filtrados.
create_variable subjects_filtered = $subjects

// 3. Lógica para filtrar por tarefas atrasadas.
//    Este bloco só executa se o parâmetro 'has_overdue_tasks' for verdadeiro.
if $has_overdue_tasks {
    // a. Busca todas as tarefas acadêmicas.
    db.query "academic_tasks" as all_tasks

    // b. Converte a lista de tarefas para uma string JSON.
    json.encode $all_tasks as tasks_json_string

    // c. Executa o script Python externo para encontrar os IDs das disciplinas com tarefas atrasadas.
    //    O script recebe o JSON de tarefas como um argumento de linha de comando.
    execute "python" as script_result with (
        "scripts/find_overdue_subjects.py",
        "--tasks-json",
        $tasks_json_string
    )

    // d. Decodifica a saída JSON do script.
    json.decode $script_result.stdout as script_output
    create_variable overdue_ids = $script_output.overdue_subject_ids

    // e. Filtra a lista de disciplinas, mantendo apenas aquelas cujos IDs estão na lista de 'overdue_ids'.
    array.filter $subjects_filtered as subjects_filtered_by_overdue where (
        $this.id in $overdue_ids
    )
    create_variable subjects_filtered = $subjects_filtered_by_overdue
}

// 4. Lógica para filtrar por termo de busca (nome da disciplina).
//    Este filtro é aplicado sobre o resultado da filtragem anterior (se houve).
if !is_empty($search_term) {
    array.filter $subjects_filtered as subjects_filtered_by_name where (
        $this.name contains $search_term
    )
    create_variable subjects_filtered = $subjects_filtered_by_name
}

// 5. Retorna a lista final de disciplinas filtradas.
return $subjects_filtered