# Subjects API - Edutrack-ai

Documentação completa da API de Gerenciamento de Disciplinas.

## Base URL
```
/api/subjects
```

## Autenticação
Todos os endpoints requerem autenticação via Bearer Token:
```
Authorization: Bearer <token>
```

## Endpoints

### 1. CREATE - POST /subjects/create
Criar uma nova disciplina com validação de duplicatas.

**Request:**
```json
{
  "name": "Mathematics",
  "teacher_name": "Prof. Smith",
  "hours": 60
}
```

**Response (201):**
```json
{
  "id": 1,
  "name": "Mathematics",
  "teacher_name": "Prof. Smith",
  "hours": 60,
  "created_at": "2026-06-03T10:30:00Z"
}
```

**Validações:**
- Nome e professor não podem estar vazios
- Não pode haver duplicata (mesmo nome + professor para o mesmo usuário)

**Erros:**
- `400`: Nome ou professor vazios
- `400`: Disciplina duplicada
- `401`: Não autenticado

---

### 2. LIST - GET /subjects/list
Listar todas as disciplinas do usuário autenticado com contagem de atividades.

**Query Parameters:**
- `page` (int, default=1): Número da página
- `per_page` (int, default=10, max=100): Itens por página

**Response (200):**
```json
{
  "itemsReceived": 10,
  "curPage": 1,
  "nextPage": 2,
  "prevPage": null,
  "offset": 0,
  "perPage": 10,
  "totals": 15,
  "items": [
    {
      "id": 1,
      "name": "Mathematics",
      "teacher_name": "Prof. Smith",
      "hours": 60,
      "activity_count": 5,
      "overdue_count": 2,
      "created_at": "2026-06-03T10:30:00Z"
    }
  ]
}
```

---

### 3. GET - GET /subjects/{id}
Obter uma disciplina específica com detalhes de atividades.

**Path Parameters:**
- `id` (int): ID da disciplina

**Response (200):**
```json
{
  "id": 1,
  "name": "Mathematics",
  "teacher_name": "Prof. Smith",
  "hours": 60,
  "activity_count": 5,
  "overdue_count": 2,
  "created_at": "2026-06-03T10:30:00Z",
  "updated_at": "2026-06-03T10:30:00Z"
}
```

**Erros:**
- `404`: Disciplina não encontrada ou não pertence ao usuário
- `403`: Acesso negado

---

### 4. UPDATE - PATCH /subjects/{id}/update
Editar uma disciplina existente com validação de duplicatas.

**Path Parameters:**
- `id` (int): ID da disciplina

**Request:**
```json
{
  "name": "Advanced Mathematics",
  "teacher_name": "Prof. Johnson",
  "hours": 75
}
```

**Response (200):**
```json
{
  "id": 1,
  "name": "Advanced Mathematics",
  "teacher_name": "Prof. Johnson",
  "hours": 75,
  "updated_at": "2026-06-03T11:30:00Z"
}
```

**Validações:**
- Apenas campos fornecidos são atualizados
- Validação de duplicata para novo nome + professor
- Timestamp `updated_at` é atualizado automaticamente

**Erros:**
- `400`: Disciplina não encontrada
- `403`: Não autorizado para editar
- `400`: Duplicata detectada com novo nome/professor

---

### 5. DELETE - DELETE /subjects/{id}/delete
Deletar uma disciplina e todas as suas atividades associadas.

**Path Parameters:**
- `id` (int): ID da disciplina

**Response (200):**
```json
{
  "success": true,
  "message": "Subject and associated activities deleted successfully",
  "subject_id": 1,
  "activities_deleted": 5
}
```

**Validações:**
- A disciplina deve pertencer ao usuário autenticado
- Todas as atividades associadas são deletadas também

**Erros:**
- `400`: Disciplina não encontrada
- `403`: Não autorizado para deletar

---

### 6. SEARCH - GET /subjects/search
Buscar disciplinas por nome.

**Query Parameters:**
- `query` (text, required): Termo de busca
- `page` (int, default=1): Número da página
- `per_page` (int, default=10, max=100): Itens por página

**Request:**
```
GET /subjects/search?query=Math&page=1&per_page=10
```

**Response (200):**
```json
{
  "itemsReceived": 2,
  "curPage": 1,
  "nextPage": null,
  "prevPage": null,
  "offset": 0,
  "perPage": 10,
  "totals": 2,
  "items": [
    {
      "id": 1,
      "name": "Mathematics",
      "teacher_name": "Prof. Smith",
      "activity_count": 5,
      "overdue_count": 2,
      "created_at": "2026-06-03T10:30:00Z"
    }
  ]
}
```

**Validações:**
- Query não pode estar vazio
- Query não pode ter mais de 100 caracteres
- Busca é case-insensitive

**Erros:**
- `400`: Query vazio ou muito longo

---

### 7. OVERDUE - GET /subjects/overdue
Listar disciplinas com tarefas em atraso.

**Query Parameters:**
- `page` (int, default=1): Número da página
- `per_page` (int, default=10, max=100): Itens por página

**Response (200):**
```json
{
  "itemsReceived": 3,
  "curPage": 1,
  "nextPage": null,
  "prevPage": null,
  "offset": 0,
  "perPage": 10,
  "totals": 3,
  "items": [
    {
      "id": 1,
      "name": "Mathematics",
      "teacher_name": "Prof. Smith",
      "overdue_count": 3,
      "total_activities": 5,
      "created_at": "2026-06-03T10:30:00Z"
    }
  ]
}
```

**Filtros Aplicados:**
- Apenas atividades com `due_date < now()`
- Apenas atividades com `status != "completed"`
- Apenas disciplinas do usuário autenticado

---

## Status Codes

| Code | Significado |
|------|------------|
| 200 | OK - Requisição bem-sucedida |
| 201 | Created - Recurso criado com sucesso |
| 400 | Bad Request - Erro na validação de entrada |
| 401 | Unauthorized - Token não fornecido ou inválido |
| 403 | Forbidden - Usuário não tem permissão |
| 404 | Not Found - Recurso não encontrado |
| 500 | Internal Server Error - Erro do servidor |

## Addons Utilizados

### subject_activity_count
Conta o total de atividades acadêmicas para uma disciplina.
- Input: `subject_id`
- Output: `count` (int)

### subject_overdue_count
Conta o total de atividades em atraso para uma disciplina.
- Input: `subject_id`
- Output: `count` (int)

## Arquivos Criados

### Endpoints (em /apis/subjects/)
1. `subjects_create_POST.xs` - POST /subjects/create
2. `subjects_list_GET.xs` - GET /subjects/list
3. `subjects_id_GET.xs` - GET /subjects/{id}
4. `subjects_id_update_PATCH.xs` - PATCH /subjects/{id}/update
5. `subjects_id_delete_DELETE.xs` - DELETE /subjects/{id}/delete
6. `subjects_search_GET.xs` - GET /subjects/search
7. `subjects_overdue_GET.xs` - GET /subjects/overdue

### Addons (em /addons/)
1. `subject_activity_count.xs` - Conta atividades
2. `subject_overdue_count.xs` - Conta atividades atrasadas

## Exemplos de Uso

### Criar uma disciplina
```bash
curl -X POST http://localhost/api/subjects/create \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Physics",
    "teacher_name": "Dr. Anderson",
    "hours": 45
  }'
```

### Listar disciplinas
```bash
curl -X GET http://localhost/api/subjects/list?page=1&per_page=10 \
  -H "Authorization: Bearer <token>"
```

### Buscar disciplinas por nome
```bash
curl -X GET "http://localhost/api/subjects/search?query=Math" \
  -H "Authorization: Bearer <token>"
```

### Listar disciplinas com tarefas em atraso
```bash
curl -X GET http://localhost/api/subjects/overdue?page=1 \
  -H "Authorization: Bearer <token>"
```

### Editar uma disciplina
```bash
curl -X PATCH http://localhost/api/subjects/1/update \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Advanced Physics",
    "hours": 60
  }'
```

### Deletar uma disciplina
```bash
curl -X DELETE http://localhost/api/subjects/1/delete \
  -H "Authorization: Bearer <token>"
```

## Notas Importantes

1. **Autorização**: Todos os endpoints verificam se o usuário autenticado é o proprietário da disciplina
2. **Duplicatas**: O sistema previne o cadastro de disciplinas duplicadas (mesmo nome + professor)
3. **Cascata de Deleção**: Ao deletar uma disciplina, todas as atividades associadas são deletadas também
4. **Paginação**: Endpoints de listagem suportam paginação com limite máximo de 100 itens por página
5. **Contadores**: Cada disciplina retorna contadores de atividades totais e em atraso
6. **Logs**: Todas as operações são registradas em `debug.log` para auditoria

## Próximos Passos

Após criar esses endpoints, é recomendado:
1. Fazer push das mudanças: `push_all_changes_to_xano`
2. Testar cada endpoint usando o cliente API
3. Verificar os logs de debug para operações bem-sucedidas
4. Integrar com a interface Python no `pages/disciplinas_page.py`
