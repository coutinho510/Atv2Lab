## 1. API Client

- [x] 1.1 Adicionar `MEMBERS_API_URL` e `update_profile(name, email)` em `utils/api_client.py` (PATCH `/user/edit_profile`).
- [x] 1.2 Adicionar `request_password_reset(email)` (POST `/reset/request-reset-link`, gera e envia o código de 6 dígitos via Resend).
- [x] 1.3 Adicionar `confirm_password_reset(email, code, password, confirm_password)` (POST `/reset/confirm-code`, valida o código e grava a nova senha em uma única chamada, sem token).
- [x] 1.4 Adicionar `update_password(password, confirm_password, token)` (POST `/reset/update_password`, usado apenas no fluxo de "Alterar Senha" do usuário já logado, com o token da sessão atual).
- [x] 1.5 Adicionar `is_session_expired()` (GET `/auth/me`, retorna True apenas em 401/403, nunca em erro de rede), com `_check_token_expired` cacheado por token (`@st.cache_data(ttl=60)`) para não disparar uma requisição a cada rerender do Streamlit nem misturar resultados entre sessões de usuários diferentes — encontrado durante testes manuais (rate limit do plano gratuito do Xano: 10 req/20s).

## 2. Editar Perfil e Alterar Senha

- [x] 2.1 Formulário de edição de nome/e-mail em `views/perfil_page.py` usando `update_profile()`.
- [x] 2.2 Substituir o stub "Alterar Senha" por um formulário que usa `update_password()` com o token da sessão atual.

## 3. Esqueci a Senha

- [x] 3.1 Nova opção "Esqueci a Senha" no menu de acesso de `app.py`.
- [x] 3.2 Etapa 1: solicitar código via `request_password_reset()`.
- [x] 3.3 Etapa 2: concluir redefinição com e-mail + código + nova senha via `confirm_password_reset()` (chamada única, sem token intermediário).
- [x] 3.4 Backend XanoScript reescrito para código de 6 dígitos + Resend, espelhando `atv-praticainovation` (ver commit "feat(xano): reset de senha via codigo de 6 digitos + Resend"); deploy manual do usuário via push staged to Xano + variável de ambiente `RESEND_API_KEY_`.

## 4. Logout Automático

- [x] 4.1 Verificar `is_session_expired()` ao entrar na área autenticada de `app.py`; se expirado, limpar sessão e voltar ao login com aviso.

## 5. Validação

- [x] 5.1 Validar manualmente: editar perfil, alterar senha logado, fluxo completo de esqueci-a-senha, e sessão expirada (token inválido forçado) levando ao logout automático.
