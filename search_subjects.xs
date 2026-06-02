// api GET /subjects/search
// description: Endpoint para buscar disciplinas por nome ou por tarefas atrasadas.

// Entradas da Query String (URL)
input text? search "Termo para buscar no nome da disciplina."
input boolean? overdue "Se verdadeiro, filtra apenas disciplinas com tarefas atrasadas."

// 1. Chama a função de lógica de negócios reutilizável.
//    Mapeia os parâmetros da API para os parâmetros da função.
call "search_subjects_logic" as result with (
    search_term = $search,
    has_overdue_tasks = $overdue
)

// 2. Retorna o resultado da função diretamente como a resposta da API.
return $result