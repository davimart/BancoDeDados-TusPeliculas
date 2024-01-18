# main.py
from database_operations import *
from database_utils import *
import pandas as pd

# Define the global variable outside of any function or class
menu_options = ["0. Sair",
    "1. Cadastrar pessoas",
    "2. Cadastrar eventos",
    "3. Cadastrar edição",
    "4. Cadastrar prêmios, nominações, premiações",
    "5. Cadastrar filmes",
    "6. Gerar um gráfico, histograma, que apresente os dez atores (atrizes) com maior número de prêmios.",
    "7. Gerar um gráfico, histograma, que apresente os 10 filmes mais premiados.",
    "8. Gerar um gráfico, histograma, que apresente os 10 filmes com maior arrecadação",
    "9. Listar os atores (atrizes) nominados como melhor ator em todos os eventos existentes",
    "10. Dado um prêmio, indique quais foram os autores ou filmes nominados e premiados.",
    "11. Executar todas as opções anteriores",
    "0. Sair"
]
def display_menu():
    global menu_options  # Indicate that you are using the global variable

    print("\nMENU:")
    for option in menu_options:
        print(option)

def choices(choice,connect_to_db,cursor):
    global menu_options
    print("Opção escolhida: ", menu_options[choice])
    query = None
    if choice == 1:
        query = cadastrar_pessoas()
    elif choice == 2:
        query = cadastrar_eventos()
    elif choice == 3:
        query = cadastrar_edicao()
    elif choice == 4:
        cadastrar = 's'
        while cadastrar == 's':
            tipo_premio = input("É o prêmio de melhor filme? (s/n):")
            if tipo_premio == 'n':
                query = cadastrar_premios()
            elif tipo_premio == 's':
                query = cadastrar_melhor_filme()
            cadastrar = input("Deseja cadastrar outro prêmio? (s/n):")
    elif choice == 5:
        query = cadastrar_filmes()
    elif choice in [6, 7, 8]:
        if choice == 6:
            query = gerar_grafico_atores()
        elif choice == 7:
            query = gerar_grafico_filmes()
        elif choice == 8:
            query = gerar_grafico_arrecadacao()
        
        if connect_to_db == 's':
            cursor.execute(query)
            query_result = cursor.fetchall()

            # Get column names from the cursor description
            column_names = [desc[0] for desc in cursor.description]
            df = pd.DataFrame(query_result, columns=column_names)

            histograma(df)
        else:
            print("Para realizar os comandos em SQL precisa conectar a database primeiro")
    elif choice == 9:
        query = listar_melhores_atores()
    elif choice == 10:
        query = listar_premios_por_evento()
    else:
        print("Invalid choice. Please try again.")

    return query

def main():
    connection = None
    cursor = None
    table_name = None
    global menu_options
    print("Você pode conectar a uma database passando os dados para database", end=' ')
    print(" e/ou salvar os comandos SQL produzidos em um arquivo chamado queries.sql")
    connect_to_db = input("Você quer conectar a database? (s/n): ").lower()
    salvar_arquivo = input("Você quer salvar comandos no arquivo .sql? (s/n): ").lower()

    if connect_to_db == 's':
        connection = connect_to_database()
        cursor = connection.cursor()
    
    choice = 1
    while choice != 0:
        display_menu()
        choice = int(input("Escolha sua opção (0-10): "))
        if choice == 0:
            break

        if choice == 11:
            for number in range(1, 11):
                query = choices(number,connect_to_db,cursor)
                
                if query is not None:
                    print(f"Comando em SQL: {query}")
                    # Write the query to a text file
                    if salvar_arquivo == 's':
                        with open('queries.sql', 'a') as file:
                            file.write(f"\n--{menu_options[number]}\n")
                            file.write(f"{query}\n")
                
                if connect_to_db == 's':
                    cursor.execute(query)
                    cursor.connection.commit()
                    if choice in[6,7,8,9,10]:
                        query_result = cursor.fetchall()

                        # Get column names from the cursor description
                        column_names = [desc[0] for desc in cursor.description]
                        df = pd.DataFrame(query_result, columns=column_names)
                        print(df)
                        if salvar_arquivo == 's':
                            with open('queries.sql', 'a') as file:
                                file.write(f"-- resultados:\n")
                                file.write(f"/*\n{df}\n*/\n")
        else:
            query = choices(choice,connect_to_db,cursor)

            if query is not None:
                print(f"Comando em SQL: {query}")
                # Write the query to a text file
                if salvar_arquivo == 's':
                    with open('queries.sql', 'a') as file:
                        file.write(f"\n--{menu_options[choice]}\n")
                        file.write(f"{query}\n")
            
            if connect_to_db == 's':
                cursor.execute(query)
                cursor.connection.commit()
                if choice in[6,7,8,9,10]:
                    query_result = cursor.fetchall()

                    # Get column names from the cursor description
                    column_names = [desc[0] for desc in cursor.description]
                    df = pd.DataFrame(query_result, columns=column_names)
                    print(df)
                    if salvar_arquivo == 's':
                        with open('queries.sql', 'a') as file:
                            file.write(f"-- resultados:\n")
                            file.write(f"/*\n{df}\n*/\n")

    if cursor:
        cursor.close()
    if connection:
        connection.close()

if __name__ == "__main__":
    main()
