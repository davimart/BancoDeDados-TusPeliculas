import pandas as pd
import matplotlib.pyplot as plt
from database_utils import *

def cadastrar_pessoas():
    print("Executando cadastrar_pessoas")

    # Obter entradas do usuário
    nome = input("Digite o nome: ")
    nome_arte = input("Digite o nome artístico: ")
    sexo = input("Digite o gênero: ")
    ano_nasc = input("Digite o ano de nascimento: ")
    site = input("Digite o site: ")
    ano_estreia = input("Digite o ano de estreia: ")
    situacao = input("Digite a situação (por exemplo, ATIVO(A)): ")
    nacionalidade = input("Digite a nacionalidade: ")

    # Construir a consulta SQL
    query = f"INSERT INTO PESSOA (Nome, Nome_Arte, Sexo, Ano_nasc, Site, Ano_Estreia, Situacao, Nacionalidade) " \
            f"VALUES ('{nome}', '{nome_arte}', '{sexo}', '{ano_nasc}', '{site}', '{ano_estreia}', '{situacao}', '{nacionalidade}');"
    return query  # Retornar a consulta SQL


def cadastrar_eventos():
    print("Executando cadastrar_eventos")

    # Obter entradas do usuário
    nome_evento = input("Digite o nome do evento: ")
    nacionalidade = input("Digite a nacionalidade: ")
    tipo = input("Digite o tipo de evento: ")
    ano_inicio = input("Digite o ano de início: ")

    # Construir a consulta SQL
    query = f"INSERT INTO EVENTO (Nome_Evento, Nacionalidade, Tipo, Ano_Inicio) " \
            f"VALUES ('{nome_evento}', '{nacionalidade}', '{tipo}', '{ano_inicio}');"

    return query  # Retornar a consulta SQL

def cadastrar_edicao():
    print("Executando cadastrar_edicao")

    # Obter entradas do usuário
    nome_evento = input("Digite o nome do evento: ")
    ano = input("Digite o ano da edição: ")
    localidade = input("Digite a localidade da edição: ")

    # Construir a consulta SQL
    query = f"INSERT INTO EDICAO (Nome_Evento, Ano, Localidade) " \
            f"VALUES ('{nome_evento}', '{ano}', '{localidade}');"

    return query  # Retornar a consulta SQL

# database_operations.py

def cadastrar_premios():
    print("Executando cadastrar_premios")

    # Obter entradas do usuário
    id_edicao = input("Digite o ID da edição: ")
    nome_premio = input("Digite o nome do prêmio: ")
    tipo_premio = input("Digite o tipo do prêmio: ")
    id_pessoa = input("Digite o ID da pessoa: ")
    id_filme = input("Digite o ID do filme: ")
    vencedor = input("Digite se é o vencedor (TRUE/FALSE): ")

    # Construir a consulta SQL
    query = f"INSERT INTO PREMIO (ID_Edicao, Nome, Tipo, ID_Pessoa, ID_Filme, Vencedor) " \
            f"VALUES ({id_edicao}, '{nome_premio}', '{tipo_premio}', {id_pessoa}, {id_filme}, {vencedor});"

    return query  # Retornar a consulta SQL
# database_operations.py

def cadastrar_melhor_filme():
    print("Executando cadastrar_melhor_filme")

    # Obter entradas do usuário
    id_edicao = input("Digite o ID da edição: ")
    id_filme = input("Digite o ID do filme: ")
    vencedor = input("Digite se é o vencedor (TRUE/FALSE): ")

    # Construir a consulta SQL
    query = f"INSERT INTO MELHOR_FILME (ID_Edicao, ID_Filme, Vencedor) " \
            f"VALUES ({id_edicao}, {id_filme}, {vencedor});"

    return query  # Retornar a consulta SQL


def cadastrar_filmes():
    print("Executando cadastrar_filmes")

    # Obter entradas do usuário
    titulo_original = input("Digite o título original: ")
    ano_prod = input("Digite o ano de produção: ")
    titulo_br = input("Digite o título em português: ")
    data_estreia = input("Digite a data de estreia (formato YYYY-MM-DD): ")
    local_estreia = input("Digite o local de estreia: ")
    idioma_original = input("Digite o idioma original: ")
    arrec_prim_ano = input("Digite a arrecadação no primeiro ano: ")
    arrec_total = input("Digite a arrecadação total: ")
    genero_filme = input("Digite o gênero do filme: ")

    # Construir a consulta SQL
    query = f"INSERT INTO FILME (Titulo_Original, Ano_Prod, Titulo_BR, Data_Estreia, Local_Estreia, Idioma_Original, Arrec_PrimAno, Arrec_Total, Genero_Filme) " \
            f"VALUES ('{titulo_original}', '{ano_prod}', '{titulo_br}', '{data_estreia}', '{local_estreia}', '{idioma_original}', {arrec_prim_ano}, {arrec_total}, '{genero_filme}');"

    return query  # Retornar a consulta SQL

def histograma(df):
    """
    Cria um histograma a partir de um DataFrame com duas colunas.

    Parâmetros:
    - df: DataFrame com duas colunas (nomes e valores)

    Retorna:
    - None (exibe o histograma)
    """
    if len(df.columns) != 2:
        print("O DataFrame deve ter exatamente duas colunas.")
        return

    names_column, values_column = df.columns

    plt.figure(figsize=(10, 6))
    plt.bar(df[names_column], df[values_column], color='blue', alpha=0.7)
    plt.xlabel(names_column)
    plt.ylabel(values_column)
    title = f'Histograma - {names_column} vs {values_column}'
    plt.title(title)
    plt.xticks(rotation=45)
    
    
    salvar_imagem = input("Deseja salvar a imagem? (s/n): ").lower()
    if salvar_imagem in ['s', 'sim']:
        nome_arquivo = f"{title.replace(' ', '_').lower()}.png"
        plt.savefig(nome_arquivo)
        print(f"Imagem salva como {nome_arquivo}")
    
    plt.show()
    plt.close()
    


def gerar_grafico_atores():
    print("Executing gerar_grafico_atores")
    
    query = """SELECT P.Nome, COUNT(*) AS Numero_Premios
                FROM PESSOA P
                JOIN PREMIO PR ON P.ID_Pessoa = PR.ID_Pessoa
                WHERE PR.Tipo IN ('Melhor Ator Principal', 'Melhor Ator Coadjuvante','Melhor Atriz Principal', 'Melhor Atriz Coadjuvante') 
                AND PR.Vencedor = True
                GROUP BY P.ID_Pessoa, P.Nome
                ORDER BY Numero_Premios DESC
                LIMIT 10;"""

    return query  # You can modify this to return relevant information

def gerar_grafico_filmes():
    print("Executing gerar_grafico_filmes")
    
    query = """SELECT F.Titulo_Original, COUNT(*) AS Numero_Premios
            FROM FILME F
            LEFT JOIN PREMIO P ON F.ID_Filme = P.ID_Filme
            LEFT JOIN MELHOR_FILME MF ON F.ID_Filme = MF.ID_Filme
            WHERE P.Vencedor = TRUE OR MF.Vencedor  = TRUE
            GROUP BY F.ID_Filme, F.Titulo_Original
            ORDER BY Numero_Premios DESC
            LIMIT 10;"""

    return query  # You can modify this to return relevant information

def gerar_grafico_arrecadacao():
    print("Executing gerar_grafico_arrecadacao")
     
    query = """SELECT Titulo_Original, Arrec_Total
                FROM FILME
                ORDER BY Arrec_Total DESC
                LIMIT 10;"""

    return query  # You can modify this to return relevant information

def listar_melhores_atores():
    print("Executing listar_melhores_atores")

    query = """SELECT P.Nome
                FROM PESSOA P
                JOIN PREMIO ON PREMIO.ID_Pessoa = P.ID_Pessoa
                WHERE Premio.Tipo = 'Melhor Ator Principal' or
                Premio.Tipo = 'Melhor Atriz Principal' or
                Premio.Tipo = 'Melhor Ator Coadjuvante' or
                Premio.Tipo = 'Melhor Atriz Coadjuvante'
        ;"""

    return query  # You can modify this to return relevant information

def listar_premios_por_evento():
    edition_id = input("Qual é o ID da Edição? ")
    print("\nCATEGORIAS:")
    categorias = ('Melhor Filme', 'Melhor Ator Principal', 'Melhor Ator Coadjuvante', 'Melhor Atriz Principal', 'Melhor Atriz Coadjuvante', 'Melhor Diretor')

    for i, categoria in enumerate(categorias, start=1):
        print(f"{i}. {categoria}")

    numero_categoria = int(input("Escolha o número da categoria do Prêmio: "))

    if 1 <= numero_categoria <= len(categorias):
        categoria = categorias[numero_categoria - 1]
        print(f"Executando listar_premios_por_evento para edition_id {edition_id} e categoria {categoria}")
      
        if categoria == 'Melhor Filme':
            query = f"""SELECT F.Titulo_Original, Nome_Evento, Ano,'Melhor Filme' AS Premio, MF.Vencedor
                        FROM MELHOR_FILME MF
                        JOIN FILME F ON MF.ID_Filme = F.ID_Filme
                        JOIN EDICAO E ON MF.ID_Edicao = E.ID_Edicao
                        WHERE MF.ID_Edicao = {edition_id};"""
        else:
            query = f"""SELECT P.Nome, Nome_Evento, Ano, PR.Tipo AS Premio, PR.Vencedor
                        FROM PREMIO PR
                        JOIN PESSOA P ON PR.ID_Pessoa = P.ID_Pessoa
                        JOIN EDICAO E ON PR.ID_Edicao = E.ID_Edicao
                        WHERE PR.ID_Edicao =  {edition_id} and PR.Tipo = '{categoria}';"""
        return query  # You can modify this to return relevant information
    else:
        print("Número de categoria inválido. Por favor, escolha um número válido.")
        return None
