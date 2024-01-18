/*

Para o sistema de Filmes, vocês vão ter que desenvolver:

1. Devem ser controladas as seguintes restrições de integridade perdidas no mapeamento ao esquema relacional (Implemente em SQL uma solução para isso): 20%
    a. Deve-se considerar que uma pessoa não pode ser júri de um Evento se participar de um filme aí indicado, com qualquer papel.
*/ -- Juri imparcial

CREATE OR REPLACE FUNCTION JURI_IMPARCIAL() RETURNS TRIGGER AS $$
BEGIN
IF NEW.ID_Pessoa IN
    (WITH CombinedPeople AS (
    SELECT ID_Filme, ID_Pessoa
    FROM DIRETOR AS D
    FULL OUTER JOIN PRODUTOR AS P USING(ID_Pessoa,ID_Filme)
    FULL OUTER JOIN ATOR AS A USING(ID_Pessoa,ID_Filme)
    FULL OUTER JOIN ROTEIRISTA AS R USING(ID_Pessoa,ID_Filme)
),

FilmesIndicados AS (
    Select ID_Edicao, ID_Filme, ID_Pessoa
    FROM PREMIO
    FULL OUTER JOIN MELHOR_FILME USING (ID_Edicao, ID_Filme)
)


SELECT ID_Pessoa
FROM FilmesIndicados
JOIN CombinedPeople USING(ID_Filme, ID_Pessoa)
WHERE NEW.ID_Edicao = ID_Edicao) THEN RAISE
EXCEPTION 'Esta pessoa participa de um filme nesta edição e não pode ser juri. ID_Pessoa: %',
          NEW.ID_Pessoa;

END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER TRIGGER_JURI_IMPARCIAL
BEFORE
INSERT
OR
UPDATE ON JURI
FOR EACH ROW EXECUTE FUNCTION JURI_IMPARCIAL();

/*
    b. Que um filme que foi documentário não tem atores.

*/ -- Documentário não tem atores -  o que a gente fez para outra entrega e acho que não precisa mudar

CREATE OR REPLACE FUNCTION DOC_SEM_ATORES() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT Genero_Filme FROM FILME WHERE FILME.ID_Filme = NEW.ID_Filme) = 'Documentário' THEN
        RAISE EXCEPTION 'Documentários não tem atores. ID_Filme: %', NEW.ID_Filme;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER TRIGGER_DOC_SEM_ATORES
BEFORE
INSERT
OR
UPDATE ON ATOR
FOR EACH ROW EXECUTE FUNCTION DOC_SEM_ATORES();

/*
2. Desenvolva uma pequena aplicação que: 80%
(30%)
a. Permita*/ --1. Cadastrar pessoas

INSERT INTO PESSOA (Nome, Nome_Arte, Sexo, Ano_nasc, Site, Ano_Estreia, Situacao, Nacionalidade)
VALUES ('Mikael Viana Ferreira',
        'Mikagol',
        'Masculino',
        '1999',
        'mikael.com',
        '2006',
        'APOSENTADO(A)',
        'Brasileiro');

--2. Cadastrar eventos

INSERT INTO EVENTO (Nome_Evento, Nacionalidade, Tipo, Ano_Inicio)
VALUES ('BotaPagodao',
        'Taiwanesa',
        'Sindicato',
        '2005');

--3. Cadastrar edi��o

INSERT INTO EDICAO (Nome_Evento, Ano, Localidade)
VALUES ('BotaPagodao',
        '2007',
        'HOng Kong');

--4. Cadastrar pr�mios, nomina��es, premia��es

INSERT INTO MELHOR_FILME (ID_Edicao, ID_Filme, Vencedor)
VALUES (3,
        5,
        FALSE);

--1. Cadastrar pessoas

INSERT INTO PESSOA (Nome, Nome_Arte, Sexo, Ano_nasc, Site, Ano_Estreia, Situacao, Nacionalidade)
VALUES ('Mikael Viana Ferreira',
        'Mika',
        'Masculino',
        '1999',
        'mikael.com',
        '2006',
        'APOSENTADO(A)',
        'Brasileiro');

--2. Cadastrar eventos

INSERT INTO EVENTO (Nome_Evento, Nacionalidade, Tipo, Ano_Inicio)
VALUES ('MeuEventoNovo',
        'Portugu�s',
        'Sindicato dos roteiristas',
        '2009');

--4. Cadastrar pr�mios, nomina��es, premia��es

INSERT INTO PREMIO (ID_Edicao, Nome, Tipo, ID_Pessoa, ID_Filme, Vencedor)
VALUES (20,
        'Melhor Ator Santander',
        'Melhor Ator Principal',
        1,
        1,
        TRUE);

--5. Cadastrar filmes

INSERT INTO FILME (Titulo_Original, Ano_Prod, Titulo_BR, Data_Estreia, Local_Estreia, Idioma_Original, Arrec_PrimAno, Arrec_Total, Genero_Filme)
VALUES ('A volta dos que n�o foram',
        '1956',
        '',
        '1963-05-05',
        'Miami Beach',
        'Portugu�s',
        9999,
        67784,
        'Document�rio');

/*
*/ /*
(50%)
b. Resolva os seguintes resultados:
i. Gerar um gráfico, histograma, que apresente os dez atores (atrizes) com maior número de prêmios.
*/
SELECT P.Nome,
       COUNT(*) AS Numero_Premios
FROM PESSOA P
JOIN PREMIO PR ON P.ID_Pessoa = PR.ID_Pessoa
WHERE PR.Tipo IN ('Melhor Ator Principal',
                  'Melhor Ator Coadjuvante',
                  'Melhor Atriz Principal',
                  'Melhor Atriz Coadjuvante')
    AND PR.Vencedor = True
GROUP BY P.ID_Pessoa,
         P.Nome
ORDER BY Numero_Premios DESC
LIMIT 10;

--ii. Gerar um gráfico, histograma, que apresente os 10 filmes mais premiados.

SELECT F.Titulo_Original,
       COUNT(*) AS Numero_Premios
FROM FILME F
LEFT JOIN PREMIO P ON F.ID_Filme = P.ID_Filme
LEFT JOIN MELHOR_FILME MF ON F.ID_Filme = MF.ID_Filme
WHERE P.Vencedor = TRUE
    OR MF.Vencedor = TRUE
GROUP BY F.ID_Filme,
         F.Titulo_Original
ORDER BY Numero_Premios DESC
LIMIT 10;

--iii. Gerar um gráfico, histograma, que apresente os 10 filmes com maior arrecadação

SELECT Titulo_Original,
       Arrec_Total
FROM FILME
ORDER BY Arrec_Total DESC
LIMIT 10;

--iv. Listar os atores (atrizes) nominados como melhor ator em todos os eventos existentes”.

SELECT P.Nome
FROM PESSOA P
JOIN PREMIO ON PREMIO.ID_Pessoa = P.ID_Pessoa
WHERE Premio.Tipo = 'Melhor Ator Principal'
    or Premio.Tipo = 'Melhor Atriz Principal'
    or Premio.Tipo = 'Melhor Ator Coadjuvante'
    or Premio.Tipo = 'Melhor Atriz Coadjuvante';

--v. Dado um prêmio, indique quais foram os autores ou filmes nominados e premiados.
 -- Replace 'your_award_id' with the actual ID of the award you are interested in.
DECLARE @edition_id INT = edicao;

DECLARE @tipo INT = tipo;

-- For authors (Diretor, Produtor, Ator, Roteirista), if applicable

SELECT P.Nome,
       Nome_Evento,
       Ano,
       PR.Tipo AS Premio,
       PR.Vencedor
FROM PREMIO PR
JOIN PESSOA P ON PR.ID_Pessoa = P.ID_Pessoa
JOIN EDICAO E ON PR.ID_Edicao = E.ID_Edicao
WHERE PR.ID_Edicao = @edition_id
    and PR.Tipo = @tipo;

-- For films (Melhor Filme, etc.)

SELECT F.Titulo_Original,
       Nome_Evento,
       Ano,
       'Melhor Filme' AS Premio,
       MF.Vencedor
FROM MELHOR_FILME MF
JOIN FILME F ON MF.ID_Filme = F.ID_Filme
JOIN EDICAO E ON MF.ID_Edicao = E.ID_Edicao
WHERE MF.ID_Edicao = @edition_id;

