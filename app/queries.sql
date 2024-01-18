
--1. Cadastrar pessoas
INSERT INTO PESSOA (Nome, Nome_Arte, Sexo, Ano_nasc, Site, Ano_Estreia, Situacao, Nacionalidade) VALUES ('Mikael Viana Ferreira', 'Mikagol', 'Masculino', '1999', 'mikael.com', '2006', 'APOSENTADO(A)', 'Brasileiro');

--2. Cadastrar eventos
INSERT INTO EVENTO (Nome_Evento, Nacionalidade, Tipo, Ano_Inicio) VALUES ('BotaPagodao', 'Taiwanesa', 'Sindicato', '2005');

--3. Cadastrar edição
INSERT INTO EDICAO (Nome_Evento, Ano, Localidade) VALUES ('BotaPagodao', '2007', 'Hong Kong');

--4. Cadastrar prêmios, nominações, premiações
INSERT INTO PREMIO (ID_Edicao, Nome, Tipo, ID_Pessoa, ID_Filme, Vencedor) VALUES (20, 'Melhor Ator Santander', 'Melhor Ator Principal', 1, 1, TRUE);

--5. Cadastrar filmes
INSERT INTO FILME (Titulo_Original, Ano_Prod, Titulo_BR, Data_Estreia, Local_Estreia, Idioma_Original, Arrec_PrimAno, Arrec_Total, Genero_Filme) VALUES ('A volta dos que nao foram', '1956', 'A volta dos que nao foram', '1963-05-05', 'Miami Beach', 'Portugues', 9999, 678965, 'Documentário');

--6. Gerar um gráfico, histograma, que apresente os dez atores (atrizes) com maior número de prêmios.
SELECT P.Nome, COUNT(*) AS Numero_Premios
                FROM PESSOA P
                JOIN PREMIO PR ON P.ID_Pessoa = PR.ID_Pessoa
                WHERE PR.Tipo IN ('Melhor Ator Principal', 'Melhor Ator Coadjuvante','Melhor Atriz Principal', 'Melhor Atriz Coadjuvante') 
                AND PR.Vencedor = True
                GROUP BY P.ID_Pessoa, P.Nome
                ORDER BY Numero_Premios DESC
                LIMIT 10;

--7. Gerar um gráfico, histograma, que apresente os 10 filmes mais premiados.
SELECT F.Titulo_Original, COUNT(*) AS Numero_Premios
            FROM FILME F
            LEFT JOIN PREMIO P ON F.ID_Filme = P.ID_Filme
            LEFT JOIN MELHOR_FILME MF ON F.ID_Filme = MF.ID_Filme
            WHERE P.Vencedor = TRUE OR MF.Vencedor  = TRUE
            GROUP BY F.ID_Filme, F.Titulo_Original
            ORDER BY Numero_Premios DESC
            LIMIT 10;

--8. Gerar um gráfico, histograma, que apresente os 10 filmes com maior arrecadação
SELECT Titulo_Original, Arrec_Total
                FROM FILME
                ORDER BY Arrec_Total DESC
                LIMIT 10;

--9. Listar os atores (atrizes) nominados como melhor ator em todos os eventos existentes
SELECT P.Nome
                FROM PESSOA P
                JOIN PREMIO ON PREMIO.ID_Pessoa = P.ID_Pessoa
                WHERE Premio.Tipo = 'Melhor Ator Principal' or
                Premio.Tipo = 'Melhor Atriz Principal' or
                Premio.Tipo = 'Melhor Ator Coadjuvante' or
                Premio.Tipo = 'Melhor Atriz Coadjuvante'
        ;

--10. Dado um prêmio, indique quais foram os autores ou filmes nominados e premiados.
SELECT P.Nome, Nome_Evento, Ano, PR.Tipo AS Premio, PR.Vencedor
                        FROM PREMIO PR
                        JOIN PESSOA P ON PR.ID_Pessoa = P.ID_Pessoa
                        JOIN EDICAO E ON PR.ID_Edicao = E.ID_Edicao
                        WHERE PR.ID_Edicao =  1 and PR.Tipo = 'Melhor Diretor';

--10. Dado um prêmio, indique quais foram os autores ou filmes nominados e premiados.
SELECT P.Nome, Nome_Evento, Ano, PR.Tipo AS Premio, PR.Vencedor
                        FROM PREMIO PR
                        JOIN PESSOA P ON PR.ID_Pessoa = P.ID_Pessoa
                        JOIN EDICAO E ON PR.ID_Edicao = E.ID_Edicao
                        WHERE PR.ID_Edicao =  1 and PR.Tipo = 'Melhor Diretor';
-- resultados:
/*
                nome           nome_evento   ano          premio  vencedor
0  Quentin Tarantino  Cannes Film Festival  2022  Melhor Diretor      True
*/
