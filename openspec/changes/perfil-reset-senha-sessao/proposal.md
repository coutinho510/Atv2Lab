## Why

A auditoria do `checklist.md` apontou três lacunas na seção "Autenticação e Acesso": (1) o endpoint de edição de perfil (`apis/members_accounts/3600499_user_edit_profile_PATCH.xs`) existe no backend mas não tem UI no frontend; (2) os endpoints de reset de senha por e-mail (`reset/request-reset-link`, `reset/magic-link-login`, `reset/update_password`) existem mas não são chamados pelo Streamlit, que mostra "será implementada em breve"; (3) o token de autenticação expira em 24h (`security.create_auth_token` com `expiration = 86400`) mas o frontend nunca detecta isso, deixando o usuário com uma sessão "presa" mostrando erros em vez de voltar à tela de login.

## What Changes

- **Editar Perfil**: novo formulário em `views/perfil_page.py` que chama `update_profile()` (novo, em `utils/api_client.py`) contra o PATCH `/user/edit_profile` já existente.
- **Alterar Senha (usuário logado)**: o botão "Alterar Senha" (hoje um stub) passa a usar a mesma função `update_password()` com o token de sessão atual, sem precisar do fluxo de e-mail.
- **Esqueci a Senha (usuário deslogado)**: nova opção na tela de acesso (`app.py`) com duas etapas — solicitar código (`request_password_reset()` → POST `/reset/request-reset-link`, que gera um código de 6 dígitos e envia por e-mail via **Resend**) e concluir a redefinição informando e-mail + código + nova senha em uma única chamada (`confirm_password_reset()` → POST `/reset/confirm-code`). Sem token intermediário: o código em si é a prova de identidade. Esse fluxo substitui uma primeira versão baseada em magic-link/UUID, reescrita para espelhar a implementação já validada no projeto `atv-praticainovation` (XanoScript ajustado nessa mesma branch, ver commit "feat(xano): reset de senha via codigo de 6 digitos + Resend").
- **Logout automático**: nova função `is_session_expired()` que verifica se `GET /auth/me` retorna 401/403; chamada uma vez ao renderizar a área autenticada de `app.py`, limpando a sessão e voltando à tela de login com um aviso quando o token expirou.

## Capabilities

### New Capabilities
- `profile-management`: usuários autenticados podem visualizar e editar seu próprio nome/e-mail, e alterar sua senha diretamente.
- `user-authentication` (extensão): usuários deslogados podem solicitar e concluir a redefinição de senha via e-mail; sessões com token expirado são encerradas automaticamente.

### Modified Capabilities
<!-- Nenhuma capacidade existente com spec formal precisa mudar nesta fase -->

## Impact

- **Frontend**: `utils/api_client.py`, `views/perfil_page.py`, `app.py`.
- **Backend (XanoScript, deploy manual do usuário via push staged to Xano)**:
  - `functions/getting_started_template/269529_generate_magic_link.xs`: renomeada para `generate_reset_code`, gera código numérico de 6 dígitos (15min de expiração) em vez de UUID (60min).
  - `apis/authentication/3600491_reset_request_reset_link_GET.xs`: verb `GET`→`POST`; envia o e-mail com o código via Resend (`service_provider = "resend"`, `api_key = $env.RESEND_API_KEY_`) em vez do provedor `"xano"`.
  - `apis/authentication/3600492_reset_magic_link_login_POST.xs`: vira `reset/confirm-code`, valida o código e grava a nova senha em uma única chamada sem emitir token.
  - `tables/753409_user.xs`: `password_reset.token` muda de `password` (hash automático) para `text`, necessário para a comparação direta de texto no `confirm-code`.
  - `apis/authentication/3600493_reset_update_password_POST.xs` não foi alterado (usado só no fluxo de "Alterar Senha" logado).
- **Configuração manual necessária no Xano** (fora do alcance desta mudança via código): variável de ambiente `RESEND_API_KEY_` com uma chave gerada em resend.com/api-keys.
- **Limitação conhecida**: a função `generate_reset_code` retorna o erro "No user found for that email" quando o e-mail não existe, e esse erro é repassado ao usuário pela tela de "Esqueci a Senha". Isso permite enumerar e-mails cadastrados (testado manualmente, mesmo comportamento do projeto de referência). Corrigir isso exigiria alterar XanoScript adicional e está fora do escopo desta mudança.
