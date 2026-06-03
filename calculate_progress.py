import argparse
import json

def calculate_progress(completed: int, total: int) -> float:
    """
    Calcula a porcentagem de progresso.
    Retorna 0.0 se o total for 0 para evitar divisão por zero.
    """
    if total == 0:
        return 0.0
    return (completed / total) * 100

def main():
    """
    Analisa os argumentos, calcula o progresso e imprime a saída em JSON.
    """
    parser = argparse.ArgumentParser(description="Calcula a porcentagem de progresso.")
    parser.add_argument("--completed", type=int, required=True, help="Número de itens concluídos.")
    parser.add_argument("--total", type=int, required=True, help="Número total de itens.")
    
    args = parser.parse_args()
    
    progress = calculate_progress(args.completed, args.total)
    
    print(json.dumps({"progress_percentage": progress}))

if __name__ == "__main__":
    main()