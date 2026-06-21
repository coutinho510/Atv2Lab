## ADDED Requirements

### Requirement: Usuário pode redefinir a senha via código enviado por e-mail
Usuários deslogados que esqueceram a senha SHALL ser capazes de solicitar um código de 6 dígitos por e-mail (via Resend) e concluir a troca de senha informando esse código em uma única chamada, sem token intermediário.

#### Scenario: Usuário solicita o código de redefinição
- **WHEN** um usuário deslogado informa seu e-mail cadastrado na opção "Esqueci a Senha" e confirma
- **THEN** o sistema chama `POST /reset/request-reset-link`, que gera um código numérico de 6 dígitos (válido por 15 minutos), envia por e-mail via Resend e confirma o envio

#### Scenario: E-mail informado não está cadastrado
- **WHEN** um usuário informa um e-mail que não existe na base
- **THEN** o sistema exibe o erro retornado pela API ("No user found for that email"); isso permite enumerar e-mails cadastrados, limitação conhecida herdada do endpoint que gera o código

#### Scenario: Usuário conclui a redefinição com código válido
- **WHEN** um usuário informa e-mail, o código de 6 dígitos recebido e uma nova senha (com confirmação) na etapa de conclusão
- **THEN** o sistema chama `POST /reset/confirm-code`, que valida o código contra o salvo no usuário e grava a nova senha numa única gravação, sem emitir token de sessão

#### Scenario: Código de redefinição inválido, expirado ou já usado
- **WHEN** o código informado não corresponde ao salvo, está expirado (mais de 15 minutos) ou já foi utilizado
- **THEN** o sistema exibe o erro retornado pela API e não altera a senha

### Requirement: Sessão é encerrada automaticamente quando o token expira
O sistema SHALL detectar quando o token de autenticação armazenado na sessão não é mais válido e encerrar a sessão automaticamente, retornando o usuário à tela de login.

#### Scenario: Token expirado é detectado ao navegar no app
- **WHEN** o usuário autenticado navega para qualquer página e `GET /auth/me` retorna 401 ou 403
- **THEN** o sistema limpa o token e os dados do usuário da sessão, exibe um aviso de sessão expirada e volta à tela de login

#### Scenario: Erro de rede não derruba a sessão
- **WHEN** a verificação de sessão falha por erro de rede (não 401/403)
- **THEN** o sistema mantém a sessão atual e não força o logout
