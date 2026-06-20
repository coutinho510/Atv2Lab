## Why

A auditoria do `checklist.md` apontou três lacunas na seção "Autenticação e Acesso": (1) o endpoint de edição de perfil (`apis/members_accounts/3600499_user_edit_profile_PATCH.xs`) existe no backend mas não tem UI no frontend; (2) os endpoints de reset de senha por e-mail (`reset/request-reset-link`, `reset/magic-link-login`, `reset/update_password`) existem mas não são chamados pelo Streamlit, que mostra "será implementada em breve"; (3) o token de autenticação expira em 24h (`security.create_auth_token` com `expiration = 86400`) mas o frontend nunca detecta isso, deixando o usuário com uma sessão "presa" mostrando erros em vez de voltar à tela de login.

## What Changes

- **Editar Perfil**: novo formulário em `views/perfil_page.py` que chama `update_profile()` (novo, em `utils/api_client.py`) contra o PATCH `/user/edit_profile` já existente.
- **Alterar Senha (usuário logado)**: o botão "Alterar Senha" (hoje um stub) passa a usar a mesma função `update_password()` com o token de sessão atual, sem precisar do fluxo de e-mail.
- **Esqueci a Senha (usuário deslogado)**: nova opção na tela de acesso (`app.py`) com duas etapas — solicitar link (`request_password_reset()` → GET `/reset/request-reset-link`) e concluir a redefinição informando o `magic_token` recebido por e-mail (`magic_link_login()` → POST `/reset/magic-link-login`, seguido de `update_password()` com o token temporário retornado).
- **Logout automático**: nova função `is_session_expired()` que verifica se `GET /auth/me` retorna 401/403; chamada uma vez ao renderizar a área autenticada de `app.py`, limpando a sessão e voltando à tela de login com um aviso quando o token expirou.

## Capabilities

### New Capabilities
- `profile-management`: usuários autenticados podem visualizar e editar seu próprio nome/e-mail, e alterar sua senha diretamente.
- `user-authentication` (extensão): usuários deslogados podem solicitar e concluir a redefinição de senha via e-mail; sessões com token expirado são encerradas automaticamente.

### Modified Capabilities
<!-- Nenhuma capacidade existente com spec formal precisa mudar nesta fase -->

## Impact

- **Frontend apenas**: `utils/api_client.py`, `views/perfil_page.py`, `app.py`.
- **Backend**: nenhuma mudança — todos os endpoints usados já existem (`Authentication` e `Members & Accounts` API groups). Nenhum arquivo `.xs` foi modificado, conforme a diretriz do projeto de não escrever XanoScript diretamente.
- **Limitações conhecidas**:
  - O e-mail de redefinição enviado pelo backend aponta para uma página de demonstração do Xano (`/1_start_here_demo_page#/update-password`), não para o app Streamlit. Por isso o usuário precisa copiar manualmente o `magic_token` e o e-mail da URL recebida e colá-los na segunda etapa do formulário de redefinição. Apontar o link para o domínio real do app exigiria alterar o XanoScript do endpoint `reset/request-reset-link` e está fora do escopo desta mudança.
  - A função `generate_magic_link` retorna o erro "No user found for that email" quando o e-mail não existe, e esse erro é repassado ao usuário pela tela de "Esqueci a Senha". Isso permite enumerar e-mails cadastrados (testado manualmente). Corrigir isso também exigiria alterar XanoScript e está fora do escopo desta mudança.
