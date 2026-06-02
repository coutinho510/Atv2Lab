## Why

O dashboard principal da aplicação precisa exibir uma métrica clara do progresso geral do aluno. Atualmente, essa lógica está simulada e parcialmente implementada no frontend. Para tornar o cálculo reutilizável, robusto e desacoplado da interface, é necessário formalizá-lo como um componente de backend (script Python) que pode ser invocado de maneira padronizada.

## What Changes

- **Criação de um Script Python (`calculate_progress.py`):** Um script dedicado será criado para receber o número de itens concluídos e o total de itens, retornando a porcentagem de progresso.
- **Formalização da Especificação:** A especificação do comportamento deste script será documentada usando OpenSpec.
- **Integração com o Frontend:** O dashboard (`app.py`) será ajustado para invocar este script e exibir o resultado, substituindo a lógica de simulação atual por uma chamada real ao processo.

## Impact

- **Backend:** Adição do novo script `scripts/calculate_progress.py`.
- **Frontend:** Modificação no arquivo `app.py` para executar o script e exibir seu resultado.
- **Reusabilidade:** O script poderá ser utilizado por outros componentes do sistema no futuro, se necessário.