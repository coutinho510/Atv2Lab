## 1. API Client

- [x] 1.1 Adicionar `MEMBERS_API_URL` e `update_profile(name, email)` em `utils/api_client.py` (PATCH `/user/edit_profile`).
- [x] 1.2 Adicionar `request_password_reset(email)` (GET `/reset/request-reset-link`).
- [x] 1.3 Adicionar `magic_link_login(email, magic_token)` (POST `/reset/magic-link-login`).
- [x] 1.4 Adicionar `update_password(password, confirm_password, token)` (POST `/reset/update_password`, token explícito para suportar tanto o fluxo logado quanto o fluxo de magic link).
- [x] 1.5 Adicionar `is_session_expired()` (GET `/auth/me`, retorna True apenas em 401/403, nunca em erro de rede), com `_check_token_expired` cacheado por token (`@st.cache_data(ttl=60)`) para não disparar uma requisição a cada rerender do Streamlit nem misturar resultados entre sessões de usuários diferentes — encontrado durante testes manuais (rate limit do plano gratuito do Xano: 10 req/20s).

## 2. Editar Perfil e Alterar Senha

- [x] 2.1 Formulário de edição de nome/e-mail em `views/perfil_page.py` usando `update_profile()`.
- [x] 2.2 Substituir o stub "Alterar Senha" por um formulário que usa `update_password()` com o token da sessão atual.

## 3. Esqueci a Senha

- [x] 3.1 Nova opção "Esqueci a Senha" no menu de acesso de `app.py`.
- [x] 3.2 Etapa 1: solicitar link via `request_password_reset()`.
- [x] 3.3 Etapa 2: concluir redefinição via `magic_link_login()` + `update_password()`.

## 4. Logout Automático

- [x] 4.1 Verificar `is_session_expired()` ao entrar na área autenticada de `app.py`; se expirado, limpar sessão e voltar ao login com aviso.

## 5. Validação

- [x] 5.1 Validar manualmente: editar perfil, alterar senha logado, fluxo completo de esqueci-a-senha, e sessão expirada (token inválido forçado) levando ao logout automático.
