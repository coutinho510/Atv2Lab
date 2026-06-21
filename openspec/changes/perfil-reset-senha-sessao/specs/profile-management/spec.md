## ADDED Requirements

### Requirement: Usuário pode editar nome e e-mail do próprio perfil
Usuários autenticados SHALL ser capazes de atualizar seu nome e e-mail a partir da página de Perfil.

#### Scenario: Usuário atualiza nome e e-mail com sucesso
- **WHEN** um usuário autenticado preenche o formulário de edição de perfil com nome e e-mail válidos e confirma
- **THEN** o sistema atualiza o registro do usuário via `PATCH /user/edit_profile` e exibe os dados atualizados

#### Scenario: Usuário tenta salvar perfil com campos vazios
- **WHEN** um usuário autenticado tenta salvar o formulário de edição de perfil com nome ou e-mail vazio
- **THEN** o sistema exibe um erro de validação e não envia a requisição

### Requirement: Usuário autenticado pode alterar a própria senha
Usuários autenticados SHALL ser capazes de definir uma nova senha sem precisar do fluxo de e-mail, usando sua sessão atual.

#### Scenario: Usuário logado altera a senha com sucesso
- **WHEN** um usuário autenticado informa nova senha e confirmação coincidentes no formulário "Alterar Senha"
- **THEN** o sistema atualiza a senha via `POST /reset/update_password` usando o token da sessão atual

#### Scenario: Confirmação de senha não corresponde
- **WHEN** a nova senha e a confirmação não coincidem
- **THEN** o sistema exibe um erro e não envia a requisição
