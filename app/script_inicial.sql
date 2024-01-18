/*
Trabalho Semestral

Davi Araujo Martins - 10337787
Mikael Viana Ferreira - 13728399
Victor Augusto Costa Monteiro - 8942937

Restrições

- Valores que não podem ser nulos
- Anos condizentes
- Não pode estar concorrendo e ser juri ao mesmo tempo
- Pessoa concorrendo tem que ser condizente com a categoria e com o filme
- Ano do filme tem que ser condizente com o ano da edição
- Documentário e não documentário tem que ter domínios distintos
- Documentário não pode ter atores
- Todo filme tem que ser um documentário ou não documentário
- Apagar em cascata
    Filme
    - Tabelas Ator, Diretor, Roteirista, Produtor, Premio, Melhor Filme, Documentario e Não documentário 
    Pessoa
    - Tabelas Ator, Diretor, Roteirista, Produtor, Premio, Juri
    Edição
    -Tabelas Premio, Juri, Melhor filme
    Evento
    - Tabela Edição

Considerações: a obrigatoriedade de um filme ser um documentário ou um não documentário foi feita 
a partir de um atributo chamado Genero_Filme na tabela FILME ao invés de ser uma tabela em si

*/
-- Database Section
-- ________________ 

-- create database TUS_PELICULAS;


-- DBSpace Section
-- _______________


-- Tables Section
-- _____________ 

CREATE DATABASE TusPeliculas;

USE TusPeliculas;

CREATE USER meu_user;

ALTER ROLE meu_user SUPERUSER PASSWORD '1234';

CREATE DOMAIN CUSTOM_YEAR AS SMALLINT
   CHECK (VALUE > 1750 AND VALUE < 2300);

CREATE TABLE EVENTO (
  Nome_Evento VARCHAR(50) PRIMARY KEY,
  Nacionalidade VARCHAR(50) NOT NULL,
  Tipo VARCHAR(50) NOT NULL,
  Ano_Inicio CUSTOM_YEAR NOT NULL
);

CREATE TABLE EDICAO (
  ID_Edicao SERIAL PRIMARY KEY,
  Nome_Evento VARCHAR(50) NOT NULL,
  Ano CUSTOM_YEAR NOT NULL,
  Localidade VARCHAR(50) NOT NULL,
  FOREIGN KEY (Nome_Evento) REFERENCES EVENTO(Nome_Evento) ON DELETE CASCADE
);

CREATE TYPE GENERO AS ENUM ('Masculino', 'Feminino', 'Não-Binário');
CREATE TYPE SITUACAO AS ENUM('APOSENTADO(A)', 'ATIVO(A)', 'FALECIDO(A)');

CREATE TABLE PESSOA (
  ID_Pessoa SERIAL PRIMARY KEY,
  Nome VARCHAR(50) NOT NULL,
  Nome_Arte VARCHAR(50),
  Sexo GENERO NOT NULL,
  Ano_nasc CUSTOM_YEAR NOT NULL,
  Site VARCHAR(50),
  Ano_Estreia CUSTOM_YEAR NOT NULL,
  Situacao SITUACAO NOT NULL,
  Nacionalidade VARCHAR(50) NOT NULL
);

CREATE TYPE GENERO_FILME AS ENUM('Documentário', 'Não-Documentário');

CREATE TABLE FILME(
  ID_Filme SERIAL PRIMARY KEY,
  Titulo_Original VARCHAR(50) NOT NULL,
  Ano_Prod CUSTOM_YEAR NOT NULL,
  Titulo_BR VARCHAR(50),
  Data_Estreia DATE NOT NULL,
  Local_Estreia VARCHAR(50),
  Idioma_Original VARCHAR(50) NOT NULL,
  Arrec_PrimAno INT,
  Arrec_Total INT,
  Genero_Filme GENERO_FILME NOT NULL,
 
  CONSTRAINT Estreia_Antes_Da_Prod CHECK(EXTRACT(YEAR FROM Data_Estreia) >= Ano_Prod),
  CONSTRAINT Arrecadacao CHECK(Arrec_Total >= Arrec_PrimAno)
);


/*
CREATE TABLE DOCUMENTARIOS(
ID_Filme INT NOT NULL,
  FOREIGN KEY (ID_Filme) REFERENCES FILME(ID_Filme),
  PRIMARY KEY (ID_Filme)
);

CREATE TABLE OUTROS_FILMES(
ID_Filme INT NOT NULL,
  FOREIGN KEY (ID_Filme) REFERENCES FILME(ID_Filme),
  PRIMARY KEY (ID_Filme)
);
*/

CREATE TYPE CATEGORIA AS ENUM('Melhor Ator Principal', 'Melhor Ator Coadjuvante','Melhor Atriz Principal', 'Melhor Atriz Coadjuvante', 'Melhor Diretor');

CREATE TABLE PREMIO (
  ID_Edicao INT NOT NULL,
  Nome VARCHAR(50) NOT NULL,
  Tipo CATEGORIA NOT NULL,
  ID_Pessoa INT NOT NULL,
  ID_Filme INT NOT NULL,
  Vencedor BOOL DEFAULT FALSE,
  FOREIGN KEY (ID_Edicao) REFERENCES EDICAO(ID_Edicao) ON DELETE CASCADE,
  PRIMARY KEY (ID_Edicao, Tipo, ID_Filme),
  FOREIGN KEY (ID_Pessoa) REFERENCES PESSOA(ID_Pessoa) ON DELETE CASCADE,
  FOREIGN KEY (ID_Filme) REFERENCES FILME(ID_Filme) ON DELETE CASCADE
);

CREATE TABLE MELHOR_FILME(
  ID_Edicao INT NOT NULL,
  ID_Filme INT NOT NULL,
  Vencedor BOOL DEFAULT FALSE,
  FOREIGN KEY (ID_Edicao) REFERENCES EDICAO(ID_Edicao) ON DELETE CASCADE,
  FOREIGN KEY (ID_Filme) REFERENCES FILME(ID_Filme) ON DELETE CASCADE,
  PRIMARY KEY (ID_Edicao, ID_Filme)
);

CREATE TABLE DIRETOR(
  ID_Pessoa INT NOT NULL,
  ID_Filme INT NOT NULL,
  E_Principal BOOL DEFAULT FALSE,
  FOREIGN key (ID_Pessoa) REFERENCES PESSOA(ID_Pessoa) ON DELETE CASCADE,
  FOREIGN key (ID_Filme) REFERENCES FILME(ID_Filme) ON DELETE CASCADE,
  PRIMARY KEY (ID_Pessoa, ID_Filme)
);

CREATE TABLE PRODUTOR(
  ID_Pessoa INT NOT NULL,
  ID_Filme INT NOT NULL,
  FOREIGN key (ID_Pessoa) REFERENCES PESSOA(ID_Pessoa) ON DELETE CASCADE,
  FOREIGN key (ID_Filme) REFERENCES FILME(ID_Filme) ON DELETE CASCADE,
  PRIMARY KEY (ID_Pessoa, ID_Filme)
);

CREATE TABLE ATOR(
  ID_Pessoa INT NOT NULL,
  ID_Filme INT NOT NULL,
  Principal BOOL DEFAULT FALSE,
  Personagem varchar(50) NOT NULL,
  FOREIGN key (ID_Pessoa) REFERENCES PESSOA(ID_Pessoa) ON DELETE CASCADE,
  FOREIGN key (ID_Filme) REFERENCES FILME(ID_Filme) ON DELETE CASCADE,
  PRIMARY KEY (ID_Pessoa, ID_Filme)
);

CREATE TABLE ROTEIRISTA(
  ID_Pessoa INT NOT NULL,
  ID_Filme INT NOT NULL,
  FOREIGN key (ID_Pessoa) REFERENCES PESSOA(ID_Pessoa) ON DELETE CASCADE,
  FOREIGN key (ID_Filme) REFERENCES FILME(ID_Filme) ON DELETE CASCADE,
  PRIMARY KEY (ID_Pessoa, ID_Filme)
);

CREATE TABLE JURI(
  ID_Edicao INT NOT NULL,
  ID_Pessoa INT NOT NULL,
  FOREIGN KEY (ID_Edicao) REFERENCES EDICAO(ID_Edicao) ON DELETE CASCADE,
  FOREIGN KEY (ID_Pessoa) REFERENCES PESSOA(ID_Pessoa) ON DELETE CASCADE,
  PRIMARY KEY (ID_Edicao, ID_Pessoa)
);

--------  TRIGGERS -----------


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


-- Pessoa tem que encaixar na categoria proposta
-- ('Melhor Ator Principal', 'Melhor Ator Coadjuvante','Melhor Atriz Principal', 'Melhor Atriz Coadjuvante', 'Melhor Diretor')
CREATE OR REPLACE FUNCTION PREMIO_ATOR()
RETURNS TRIGGER AS $$
BEGIN
    CASE
        WHEN NEW.TIPO = 'Melhor Ator Principal' THEN
            CASE
                -- Não trabalhou como ator nesse filme
                WHEN NEW.ID_Pessoa NOT IN (SELECT ID_Pessoa FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme) THEN
                    RAISE EXCEPTION 'A pessoa % não trabalhou como ator no filme %', NEW.ID_Pessoa, NEW.ID_Filme;

                -- Não é do sexo do tipo/categoria do premio
                WHEN (SELECT SEXO FROM PESSOA WHERE PESSOA.ID_Pessoa = NEW.ID_Pessoa) NOT IN ('Masculino', 'Não-Binário') THEN
                    RAISE EXCEPTION 'A pessoa não se encaixa nessa categoria devido ao sexo';

                -- Não é um ator principal nesse filme
                WHEN (SELECT Principal FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme AND ATOR.ID_Pessoa = NEW.ID_Pessoa) <> 1 THEN
                    RAISE EXCEPTION 'A pessoa % não foi um ator principal no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
            END CASE;
        WHEN NEW.TIPO = 'Melhor Ator Coadjuvante' THEN
            CASE
                -- Não trabalhou como ator nesse filme
                WHEN NEW.ID_Pessoa NOT IN (SELECT ID_Pessoa FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme) THEN
                    RAISE EXCEPTION 'A pessoa % não trabalhou como ator no filme %', NEW.ID_Pessoa, NEW.ID_Filme;

                -- Não é do sexo do tipo/categoria do premio
                WHEN (SELECT SEXO FROM PESSOA WHERE PESSOA.ID_Pessoa = NEW.ID_Pessoa) NOT IN ('Masculino', 'Não-Binário') THEN
                    RAISE EXCEPTION 'A pessoa não se encaixa nessa categoria devido ao sexo';

                -- Não é um ator coadjuvante nesse filme
                WHEN (SELECT Principal FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme AND ATOR.ID_Pessoa = NEW.ID_Pessoa) <> 0 THEN
                    RAISE EXCEPTION 'A pessoa % não foi um ator coadjuvante no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
            END CASE;
        WHEN NEW.TIPO = 'Melhor Atriz Principal' THEN
            CASE
                -- Não trabalhou como ator nesse filme
                WHEN NEW.ID_Pessoa NOT IN (SELECT ID_Pessoa FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme) THEN
                    RAISE EXCEPTION 'A pessoa % não trabalhou como ator no filme %', NEW.ID_Pessoa, NEW.ID_Filme;

                -- Não é do sexo do tipo/categoria do premio
                WHEN (SELECT SEXO FROM PESSOA WHERE PESSOA.ID_Pessoa = NEW.ID_Pessoa) NOT IN ('Feminino', 'Não-Binário') THEN
                    RAISE EXCEPTION 'A pessoa não se encaixa nessa categoria devido ao sexo';

                -- Não é uma atriz principal nesse filme
                WHEN (SELECT Principal FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme AND ATOR.ID_Pessoa = NEW.ID_Pessoa) <> 1 THEN
                    RAISE EXCEPTION 'A pessoa % não foi uma atriz principal no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
            END CASE;
        WHEN NEW.TIPO = 'Melhor Atriz Coadjuvante' THEN
            CASE
                -- Não trabalhou como ator nesse filme
                WHEN NEW.ID_Pessoa NOT IN (SELECT ID_Pessoa FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme) THEN
                    RAISE EXCEPTION 'A pessoa % não trabalhou como ator no filme %', NEW.ID_Pessoa, NEW.ID_Filme;

                -- Não é do sexo do tipo/categoria do premio
                WHEN (SELECT SEXO FROM PESSOA WHERE PESSOA.ID_Pessoa = NEW.ID_Pessoa) NOT IN ('Feminino', 'Não-Binário') THEN
                    RAISE EXCEPTION 'A pessoa não se encaixa nessa categoria devido ao sexo';

                -- Não é um ator coadjuvante nesse filme
                WHEN (SELECT Principal FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme AND ATOR.ID_Pessoa = NEW.ID_Pessoa) <> 0 THEN
                    RAISE EXCEPTION 'A pessoa % não foi um ator coadjuvante no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
            END CASE;
        -- Remove the unnecessary empty CASE statement
    END CASE;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION PREMIO_ATOR()
RETURNS TRIGGER AS $$
BEGIN
    CASE
        WHEN NEW.TIPO = 'Melhor Ator Principal' THEN
            CASE
                WHEN NEW.ID_Pessoa NOT IN (SELECT ID_Pessoa FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme) THEN
                    RAISE EXCEPTION 'A pessoa % não trabalhou como ator no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                WHEN (SELECT SEXO FROM PESSOA WHERE PESSOA.ID_Pessoa = NEW.ID_Pessoa) NOT IN ('Masculino', 'Não-Binário') THEN
                    RAISE EXCEPTION 'A pessoa % não se encaixa nessa categoria devido ao sexo no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                WHEN (SELECT Principal FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme AND ATOR.ID_Pessoa = NEW.ID_Pessoa) = FALSE THEN
                    RAISE EXCEPTION 'A pessoa % não foi um ator principal no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                ELSE NULL;
            END CASE;
        WHEN NEW.TIPO = 'Melhor Ator Coadjuvante' THEN
            CASE
                WHEN NEW.ID_Pessoa NOT IN (SELECT ID_Pessoa FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme) THEN
                    RAISE EXCEPTION 'A pessoa % não trabalhou como ator no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                WHEN (SELECT SEXO FROM PESSOA WHERE PESSOA.ID_Pessoa = NEW.ID_Pessoa) NOT IN ('Masculino', 'Não-Binário') THEN
                    RAISE EXCEPTION 'A pessoa % não se encaixa nessa categoria devido ao sexo no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                WHEN (SELECT Principal FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme AND ATOR.ID_Pessoa = NEW.ID_Pessoa) = TRUE THEN
                    RAISE EXCEPTION 'A pessoa % não foi um ator coadjuvante no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                ELSE NULL;
            END CASE;
        WHEN NEW.TIPO = 'Melhor Atriz Principal' THEN
            CASE
                WHEN NEW.ID_Pessoa NOT IN (SELECT ID_Pessoa FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme) THEN
                    RAISE EXCEPTION 'A pessoa % não trabalhou como ator no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                WHEN (SELECT SEXO FROM PESSOA WHERE PESSOA.ID_Pessoa = NEW.ID_Pessoa) NOT IN ('Feminino', 'Não-Binário') THEN
                    RAISE EXCEPTION 'A pessoa % não se encaixa nessa categoria devido ao sexo no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                WHEN (SELECT Principal FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme AND ATOR.ID_Pessoa = NEW.ID_Pessoa) = FALSE THEN
                    RAISE EXCEPTION 'A pessoa % não foi uma atriz principal no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                ELSE NULL;
            END CASE;
        WHEN NEW.TIPO = 'Melhor Atriz Coadjuvante' THEN
            CASE
                WHEN NEW.ID_Pessoa NOT IN (SELECT ID_Pessoa FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme) THEN
                    RAISE EXCEPTION 'A pessoa % não trabalhou como ator no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                WHEN (SELECT SEXO FROM PESSOA WHERE PESSOA.ID_Pessoa = NEW.ID_Pessoa) NOT IN ('Feminino', 'Não-Binário') THEN
                    RAISE EXCEPTION 'A pessoa % não se encaixa nessa categoria devido ao sexo no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                WHEN (SELECT Principal FROM ATOR WHERE ATOR.ID_Filme = NEW.ID_Filme AND ATOR.ID_Pessoa = NEW.ID_Pessoa) = TRUE THEN
                    RAISE EXCEPTION 'A pessoa % não foi um ator coadjuvante no filme %', NEW.ID_Pessoa, NEW.ID_Filme;
                ELSE NULL;
			END CASE;
		ELSE NULL;
    END CASE;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Se o filme é do ano anterior a edicao do premio
CREATE OR REPLACE FUNCTION FILME_ANO_PREMIO()
RETURNS TRIGGER AS $$
BEGIN

    IF (SELECT EXTRACT(YEAR FROM Data_Estreia) FROM FILME WHERE FILME.ID_Filme = NEW.ID_Filme) = (SELECT Ano FROM EDICAO WHERE EDICAO.ID_Edicao = NEW.ID_Edicao) - 1
    THEN RAISE EXCEPTION 'O filme % não elígvel por conta do ano', NEW.ID_Filme;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TRIGGER_FILME_ANO_PREMIO
BEFORE INSERT OR UPDATE
ON PREMIO
FOR EACH ROW
EXECUTE FUNCTION FILME_ANO_PREMIO();


-- Documentário não tem atores
CREATE OR REPLACE FUNCTION DOC_SEM_ATORES()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT Genero_Filme FROM FILME WHERE FILME.ID_Filme = NEW.ID_Filme) = 'Documentário' THEN
        RAISE EXCEPTION 'Documentários não tem atores. ID_Filme: %', NEW.ID_Filme;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TRIGGER_DOC_SEM_ATORES
BEFORE INSERT OR UPDATE
ON ATOR
FOR EACH ROW
EXECUTE FUNCTION DOC_SEM_ATORES();




