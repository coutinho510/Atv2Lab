# ✅ Checklist EduTrack AI — O que o sistema deve fazer

Visão funcional do sistema: o que está pronto, o que falta e o que pode ser melhorado.

---

## 🔐 Autenticação e Acesso

- [x] Permitir que o usuário crie uma conta com e-mail e senha.
- [x] Permitir que o usuário faça login e acesse o sistema com suas credenciais.
- [x] Manter o usuário autenticado durante a navegação entre páginas.
- [x] Permitir que o usuário visualize e edite seu perfil (nome, e-mail).
- [x] Permitir que o usuário redefina sua senha via e-mail.
- [x] Encerrar a sessão automaticamente quando o token de autenticação expirar.

---

## 📚 Gestão de Disciplinas

- [x] Permitir que o usuário cadastre uma disciplina informando nome, professor e carga horária.
- [x] Garantir que as disciplinas cadastradas sejam armazenadas no banco de dados e vinculadas ao usuário logado.
- [x] Listar todas as disciplinas do usuário.
- [x] Permitir que o usuário edite os dados de uma disciplina.
- [x] Permitir que o usuário exclua uma disciplina.
- [x] Impedir o cadastro de disciplinas duplicadas (mesmo nome e professor).
- [x] Permitir buscar disciplinas por nome.
- [x] Permitir filtrar disciplinas que possuem tarefas em atraso.

---

## 📝 Gestão de Tarefas

- [x] Permitir que o usuário cadastre uma tarefa vinculada a uma disciplina, informando título, descrição e prazo.
- [x] Garantir que as tarefas cadastradas sejam armazenadas no banco de dados e associadas à disciplina e ao usuário corretos.
- [x] Listar todas as tarefas do usuário, agrupadas por disciplina ou por prazo.
- [x] Permitir que o usuário edite os dados de uma tarefa.
- [x] Permitir que o usuário exclua uma tarefa.
- [x] Permitir que o usuário marque uma tarefa como concluída.
- [x] Permitir filtrar tarefas por status (Pendente, Em andamento, Concluída).
- [x] Identificar e sinalizar visualmente as tarefas com prazo vencido.

---

## 🏠 Propostas de Melhoria

### 📊 Dashboard

Criar uma tela inicial com visão geral do sistema logo após o login, exibindo:

- [x] Total de disciplinas ativas
- [x] Total de tarefas pendentes e em atraso
- [x] As próximas tarefas com prazo mais próximo
- [x] Indicador de progresso geral (percentual de tarefas concluídas)

---

### 📈 Relatórios e Progresso

- [x] Criar uma tela de relatórios com o histórico de tarefas por período e progresso por disciplina.
- [x] Permitir que o usuário exporte seus dados (disciplinas e tarefas) em formato CSV ou PDF. *(implementado apenas CSV, por decisão de escopo)*

---

### 📅 Evolução das Disciplinas e Tarefas

- [x] Permitir associar um semestre/período a cada disciplina para melhor organização.
- [x] Adicionar campo de prioridade nas tarefas (Baixa, Média, Alta).
- [x] Exibir o progresso de cada disciplina com base nas tarefas concluídas.
- [ ] Permitir arquivar disciplinas concluídas sem excluí-las.

---

### 🎨 Design e Experiência do Usuário

- [x] Definir uma identidade visual consistente para o app (cores, logo, tipografia).
- [x] Melhorar a tela de login e cadastro com um layout mais atrativo.
- [x] Exibir uma tela de boas-vindas para usuários que ainda não possuem dados cadastrados.
- [x] Solicitar confirmação antes de excluir disciplinas ou tarefas.

---

## 🔧 Manutenções e Ajustes Pendentes

- [ ] Em "📅 Próximas Tarefas" (Dashboard), exibir também a prioridade de cada tarefa, além do indicador de atraso.
- [x] Trocar o ícone de prioridade alta (atualmente 🔴, igual ao de "atrasada"), pois os dois indicadores estão se confundindo visualmente.
- [ ] Redesenhar o 🏠 Dashboard para ser visualmente mais simples e bonito, mostrando quantidade de tarefas, status, prioridades e disciplinas.
- [ ] Redesenhar a página 👤 Meu Perfil:
  - [ ] Seção 🔐 Segurança deve conter apenas o botão de trocar senha.
  - [ ] Em ℹ️ Informações Adicionais, corrigir o formato de "conta criada em" (hoje exibe o timestamp bruto, ex: `1782001269632`).
  - [ ] Em ✏️ Editar Perfil, os campos de edição devem ficar ocultos até o usuário clicar em um botão para exibi-los.
- [ ] Tornar a tela de Relatórios mais detalhada.
