# calculate-progress Specification

## Purpose

Este documento define o comportamento do script `calculate_progress.py`, que serve para calcular a porcentagem de progresso com base em um número total de itens e um número de itens concluídos.

## ADDED Requirements

### Requirement: Calcular a porcentagem de progresso
O sistema SHALL calcular a porcentagem de progresso (concluídas / total * 100).

#### Scenario: Cálculo com valores válidos
- **WHEN** o script for executado com os argumentos `completed=5` e `total=10`
- **THEN** o script SHALL retornar o JSON `{"progress_percentage": 50.0}`.

#### Scenario: Cálculo com zero concluídas
- **WHEN** o script for executado com os argumentos `completed=0` e `total=10`
- **THEN** o script SHALL retornar o JSON `{"progress_percentage": 0.0}`.

#### Scenario: Cálculo com total zero (divisão por zero)
- **WHEN** o script for executado com o argumento `total=0`
- **THEN** o script SHALL retornar o JSON `{"progress_percentage": 0.0}` para evitar erro de divisão por zero.