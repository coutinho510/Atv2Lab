# 🏗️ Arquitetura de Autenticação - Edutrack-ai

## 📊 Fluxo de Autenticação

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLIENTE (Streamlit)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SESSION STATE                                           │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • auth_token: Bearer token do usuário                  │  │
│  │  • user_data: { name, email, id, ... }                 │  │
│  │  • auth_mode: "login" ou "register"                     │  │
│  │  • editing_subject: Para editar disciplinas             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────┬──────────────────────────────────┘
                              │
                              │ (REQUEST COM BEARER TOKEN)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SERVIDOR XANO                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  POST /auth/login                                              │
│    Request:  { email, password }                               │
│    Response: { authToken, user: {...}, ... }                   │
│                                                                 │
│  POST /auth/signup                                             │
│    Request:  { name, email, password }                         │
│    Response: { authToken, user: {...}, ... }                   │
│                                                                 │
│  GET /auth/me (com Bearer Token)                               │
│    Request:  Headers: { Authorization: Bearer {token} }        │
│    Response: { name, email, id, ... }                          │
│                                                                 │
│  GET /subjects (com Bearer Token) - PROTEGIDO                  │
│  POST /subjects (com Bearer Token) - PROTEGIDO                 │
│  PATCH /subjects/{id} (com Bearer Token) - PROTEGIDO           │
│  DELETE /subjects/{id} (com Bearer Token) - PROTEGIDO          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxo de Login

```
┌─────────────────────────────────────────────────────────────┐
│ USUÁRIO ACESSA APP                                          │
└──────────────────────────┬────────────────────────────────┘
                           │
                           ▼
        ┌─────────────────────────────────────┐
        │ auth_token = None ?                 │
        └─────────────┬───────────────────────┘
                      │
          SIM ────────┼────── NÃO
          │           │       │
          │           │       └─→ MOSTRA MENU PROTEGIDO
          │           │
          ▼           │
   ┌───────────────────┴─────────────────────┐
   │ TELA DE LOGIN/REGISTRO                  │
   │ (Escolhe entre Login ou Registrar)      │
   └──────────────┬──────────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
    LOGIN              REGISTRAR
         │                 │
         │ email+pass      │ name+email+pass
         │ (validar senhas iguais)
         │                 │
         └────────┬────────┘
                  │
         POST /auth/login
         ou
         POST /auth/signup
                  │
                  ▼
        ┌─────────────────────────┐
        │ Sucesso?                │
        └──┬──────────┬──────────┐
         SIM         │          NÃO
          │          │           │
          │          │      st.error()
          │          │      continua na tela
          │          │
          │          │
          ▼          │
   session_state.auth_token = token
   session_state.user_data = user_data
                  │
                  ▼
         st.success("Login!")
                  │
                  ▼
         st.rerun()
                  │
                  ▼
    MOSTRA MENU PROTEGIDO
```

---

## 🛡️ Fluxo de Proteção de Endpoints

```
┌──────────────────────────────────────────────────────────┐
│ APLICAÇÃO PRECISA CHAMAR ENDPOINT PROTEGIDO              │
│ (ex: GET /subjects, POST /subjects, etc)                 │
└──────────────┬───────────────────────────────────────────┘
               │
               ▼
   ┌──────────────────────────────┐
   │ auth_token existe?           │
   └──┬──────────────────────────┐
    NÃO                          SIM
     │                            │
     ▼                            ▼
  Retorna []                 Cria Headers:
  (lista vazia)              {
                              "Authorization": 
                              f"Bearer {token}"
                             }
                              │
                              ▼
                        POST/GET/PATCH/DELETE
                        para {endpoint}
                              │
                              ▼
                        Xano valida token
                              │
                        ┌─────┴──────┐
                        │            │
                      VÁLIDO       INVÁLIDO
                        │            │
                        ▼            ▼
                      ✅ Retorna    ❌ Erro 401
                      dados        Unauthorized
```

---

## 🔐 Fluxo de Logout

```
┌────────────────────────────────────────┐
│ USUÁRIO CLICA "🚪 SAIR"                │
└───────────────────┬────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │ Limpa Session State:  │
        │ • auth_token = None   │
        │ • user_data = None    │
        │ • editing_subject = None
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │ st.success("Saiu!")   │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │ st.rerun()            │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │ VOLTA PARA TELA DE    │
        │ LOGIN (auth_token=None)
        └───────────────────────┘
```

---

## 📁 Estrutura de Arquivos Modificados

```
Edutrack-ai/
├── app.py                    ← REESCRITO com autenticação
├── utils/
│   └── api_client.py        ← ATUALIZADO com get_current_user()
├── AUTH_GUIDE.md            ← NOVO: Guia de uso
├── IMPLEMENTATION_SUMMARY.md ← NOVO: Resumo técnico
└── ARCHITECTURE.md          ← NOVO: Este arquivo
```

---

## 🔑 Variáveis de Sessão

```python
# Autenticação
st.session_state.auth_token    # str | None
st.session_state.user_data     # dict | None
st.session_state.auth_mode     # "login" | "register"

# Disciplinas
st.session_state.editing_subject  # dict | None
```

---

## 📡 Endpoints Protegidos vs Públicos

### ✅ **PÚBLICOS** (Sem token necessário)
- `POST /auth/login` - Fazer login
- `POST /auth/signup` - Registrar novo usuário
- `GET /1_start_here_demo_page` - Página demo

### 🔒 **PROTEGIDOS** (Requer Bearer Token)
- `GET /auth/me` - Obter dados do perfil
- `GET /subjects` - Listar disciplinas
- `POST /subjects` - Criar disciplina
- `PATCH /subjects/{id}` - Editar disciplina
- `DELETE /subjects/{id}` - Deletar disciplina
- `GET /academic_tasks` - Listar tarefas
- `GET /activity_grades` - Obter notas
- E outros endpoints de dados do usuário...

---

## ⚠️ Considerações de Segurança

| Item | Implementação |
|------|---|
| **Token Expiration** | ⚠️ Não verificado (TODO) |
| **Refresh Token** | ⚠️ Não implementado (TODO) |
| **HTTPS** | ✅ API usa HTTPS |
| **CORS** | ✅ Xano configura automaticamente |
| **Password Hashing** | ✅ Xano cuida disso |
| **Rate Limiting** | ❓ Depende da config do Xano |
| **Session Timeout** | ⚠️ Apenas quando fecha tab |

---

## 🚀 Melhorias Futuras

- [ ] Verificar expiração de token
- [ ] Implementar refresh token
- [ ] Recuperação de senha por e-mail
- [ ] Autenticação social (Google, GitHub)
- [ ] Two-factor authentication (2FA)
- [ ] Edição de perfil
- [ ] Histórico de login
- [ ] Rate limiting customizado

---

**Versão**: 2.0  
**Data**: Junho 2026  
**Status**: ✅ Implementado
