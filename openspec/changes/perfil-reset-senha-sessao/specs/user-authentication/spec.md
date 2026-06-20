## ADDED Requirements

### Requirement: Usuário pode redefinir a senha via e-mail
Usuários deslogados que esqueceram a senha SHALL ser capazes de solicitar um link de redefinição por e-mail e concluir a troca de senha usando o token recebido.

#### Scenario: Usuário solicita o link de redefinição
- **WHEN** um usuário deslogado informa seu e-mail cadastrado na opção "Esqueci a Senha" e confirma
- **THEN** o sistema chama `GET /reset/request-reset-link`, que envia o e-mail com o link e confirma o envio

#### Scenario: E-mail informado não está cadastrado
- **WHEN** um usuário informa um e-mail que não existe na base
- **THEN** o sistema exibe o erro retornado pela API ("No user found for that email"); isso permite enumerar e-mails cadastrados, limitação conhecida do endpoint existente que não foi alterado nesta mudança

#### Scenario: Usuário conclui a redefinição com token válido
- **WHEN** um usuário informa e-mail, `magic_token` válido e uma nova senha (com confirmação) na etapa de conclusão
- **THEN** o sistema troca o token por uma sessão temporária via `POST /reset/magic-link-login` e atualiza a senha via `POST /reset/update_password`

#### Scenario: Token de redefinição inválido ou expirado
- **WHEN** o `magic_token` informado é inválido, expirado ou já utilizado
- **THEN** o sistema exibe o erro retornado pela API e não altera a senha

### Requirement: Sessão é encerrada automaticamente quando o token expira
O sistema SHALL detectar quando o token de autenticação armazenado na sessão não é mais válido e encerrar a sessão automaticamente, retornando o usuário à tela de login.

#### Scenario: Token expirado é detectado ao navegar no app
- **WHEN** o usuário autenticado navega para qualquer página e `GET /auth/me` retorna 401 ou 403
- **THEN** o sistema limpa o token e os dados do usuário da sessão, exibe um aviso de sessão expirada e volta à tela de login

#### Scenario: Erro de rede não derruba a sessão
- **WHEN** a verificação de sessão falha por erro de rede (não 401/403)
- **THEN** o sistema mantém a sessão atual e não força o logout
