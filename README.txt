Trabalho Semestral

Davi Araujo Martins - 10337787
Mikael Viana Ferreira - 13728399
Victor Augusto Costa Monteiro - 8942937

Arquivos:
parte_1.sql - tem as nossas respostas para o parte 1 do Trabalho

pasta \app- é nossa aplicação da parte 2 do Trabalho
	Dependências: pandas, matplotlib, psycopg2, todos disponível com pip install

	Outros arquivos:
	script_inicial.sql - tem um código para gerar todas as tabelas com as retrições de acordo com a aplicação

	código para preencher essas tabelas com alguns dados:
		preencher_tabelas_1.sql
		preencher_tabelas_2.sql

	Devem ser executados em ordem

	No decorrer do programa, para realização de testes, basta se lembrar que o banco foi populado com IDs de 1 a 20
	EX.: ao cadastrar prêmios, o programa te pede um ID de edição, filme e pessoa

	Também para facilidade, em todas as tabelas que representam uma relação de trabalho com o filme, ATOR,
	ROTEIRISTA, PRODUTOR, etc., foi inserido que a pessoa 1 esta no filme 1, pessoa 2 no filme 2, etc.

	para executar o programar, rodar o arquivo main.py
	O arquivo lhe perguntará as credenciais de acesso ao banco

		host = 'localhost'
    	database = 'TusPeliculas'
    	user = 'meu_user'
    	password = '1234'
    	port = '5432'

link do vídeo:
Professor, tivemos problemas para gravar um vídeo com áudio. Tentamos mais de uma ferramenta sem sucesso, infelizmente. Acreditamos que o readme.txt está detalhando bem como abrir e utilizar a nossa aplicação, e como entregamos cada parte do trabalho. Fica em anexo um vídeo mostrando a aplicação em funcionamento.