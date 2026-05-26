# Proposta: Lançamento de Notas em Atividades

## Why (Por quê?)

Atualmente, o sistema EduTrack AI não possui uma forma para que os professores registrem as notas dos alunos em atividades acadêmicas específicas. Adicionar essa funcionalidade é um passo essencial para permitir o acompanhamento do desempenho dos alunos, que é uma função central de uma plataforma de gestão acadêmica.

## What Changes (O que vai mudar?)

Para habilitar o lançamento de notas, as seguintes mudanças são propostas:

1.  **Nova Tabela no Banco de Dados:** Será criada uma nova tabela chamada `activity_grades` para armazenar as notas. Ela conterá, no mínimo, referências para o aluno (`user_id`), para a atividade (`task_id`) e o valor da nota (`grade`).
2.  **Nova API de Criação:** Será criado um endpoint `POST /activity_grades` que permitirá que um professor (usuário autenticado) submeta uma nova nota para um aluno em uma atividade específica.

## Impact (Impacto)

O impacto esperado é a adição de uma nova capacidade ao sistema sem afetar as funcionalidades existentes. Os professores poderão registrar notas, e esses dados estarão disponíveis para futuras funcionalidades, como a consulta de boletins ou relatórios de desempenho. Nenhuma funcionalidade atual será quebrada.