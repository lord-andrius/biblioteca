-- Criação do scheme caso não exista! :)
-- Há duas formas de usar o banco de dados criando um schema ou um banco separado, escolha o que mais for fácil para você
-- USANDO SCHEMA:
--DROP SCHEMA biblioteca CASCADE; -- (Cuidado ao usar esse comando)
--CREATE SCHEMA biblioteca; -- CASO QUEIRA USAR UM SCHEMA (MAIS FÁCIL, só que pode causar erros caso você possua outros schemas no mesmo banco com tabelas com o mesmo nome das utilizadas nesse script)
SET search_path TO biblioteca; -- Usado somente se você escolher criar um schema

-- CRIANDO BANCO:
--DROP DATABASE biblioteca; -- APAGA O BANCO EXISTENTE
--CREATE DATABASE biblioteca; -- CASO QUEIRA USAR UM BANCO SEPARADO (RECOMENDADO, pois evita conflitos com outros schemas e melhora o isolamento, mas é necessário adicionar o banco ao DBeaver)


DROP TABLE IF EXISTS detalhe_emprestimo;
DROP TABLE IF EXISTS emprestimo;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS turma;
DROP TABLE IF EXISTS serie;
DROP TABLE IF EXISTS turno;
DROP TABLE IF EXISTS exemplar_livro;
DROP TABLE IF EXISTS livro_categoria;
DROP TABLE IF EXISTS livro_subcategoria;
DROP TABLE IF EXISTS subcategoria;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS livro_autor;
DROP TABLE IF EXISTS livro;
DROP TABLE IF EXISTS autor;
DROP TABLE IF EXISTS pais;


CREATE TABLE IF NOT EXISTS turno(
	id_turno SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL UNIQUE,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_turno)
);


CREATE TABLE IF NOT EXISTS serie(
	id_serie SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL UNIQUE,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_serie)
);


CREATE TABLE IF NOT EXISTS turma(
	id_turma SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL,
	serie INT NOT NULL,
	turno INT NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_turma),
	UNIQUE(descricao, serie, turno),
	FOREIGN KEY(serie) REFERENCES serie(id_serie),
	FOREIGN KEY(turno) REFERENCES turno(id_turno)
);




CREATE TABLE IF NOT EXISTS pais (
	id_pais SMALLINT NOT NULL,
	nome VARCHAR(255) NOT NULL UNIQUE,
	sigla VARCHAR(2) NOT NULL UNIQUE,
	ativo BOOLEAN NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_pais)
);


CREATE TABLE IF NOT EXISTS autor(
	id_autor SERIAL NOT NULL,
	nome VARCHAR(255) NOT NULL UNIQUE,
	ano_nascimento SMALLINT ,
	nacionalidade SMALLINT,
	sexo CHAR,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_autor),
	FOREIGN KEY(nacionalidade) REFERENCES pais(id_pais) 
);




CREATE TABLE IF NOT EXISTS livro(
	id_livro SERIAL NOT NULL,
	isbn VARCHAR(13) NOT NULL UNIQUE,
	titulo VARCHAR(255) NOT NULL,
	ano_publicacao DATE,
	editora VARCHAR(255),
	pais SMALLINT,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_livro),
	FOREIGN KEY(pais) REFERENCES pais(id_pais)
);


CREATE TABLE IF NOT EXISTS livro_autor(
	id_livro INT NOT NULL,
	id_autor INT NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_livro, id_autor),
	FOREIGN KEY(id_livro) REFERENCES livro(id_livro),
	FOREIGN KEY(id_autor) REFERENCES autor(id_autor)
);


CREATE TABLE IF NOT EXISTS categoria (
	id_categoria SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL UNIQUE,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_categoria)
);

CREATE TABLE IF NOT EXISTS subcategoria (
	id_subcategoria SERIAL NOT NULL,
	descricao VARCHAR(255) NOT NULL UNIQUE,
	ativo BOOLEAN NOT NULL DEFAULT TRUE,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_subcategoria)
);

CREATE TABLE IF NOT EXISTS livro_subcategoria (
	id_livro INT NOT NULL,
	id_subcategoria INT NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_livro, id_subcategoria),
	FOREIGN KEY(id_livro) REFERENCES livro(id_livro),
	FOREIGN KEY(id_subcategoria) REFERENCES subcategoria(id_subcategoria)
);

CREATE TABLE IF NOT EXISTS livro_categoria (
	id_livro INT NOT NULL,
	id_categoria INT NOT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_livro, id_categoria),
	FOREIGN KEY(id_livro) REFERENCES livro(id_livro),
	FOREIGN KEY(id_categoria) REFERENCES categoria(id_categoria)
);


CREATE TABLE IF NOT EXISTS exemplar_livro (
	id_exemplar_livro SERIAL NOT NULL,
	livro INT NOT NULL,
	cativo BOOLEAN NOT NULL,
	status SMALLINT DEFAULT 1 NOT NULL,
	estado SMALLINT DEFAULT 1 NOT NULL,
	ativo  BOOLEAN NOT NULL DEFAULT TRUE,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_exemplar_livro),
	FOREIGN KEY(livro) REFERENCES livro(id_livro) 
);

CREATE TABLE IF NOT EXISTS usuario (
	id_usuario SERIAL NOT NULL,
	login VARCHAR(255) NOT NULL UNIQUE,
	cpf VARCHAR(12),
	nome VARCHAR(255) NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE,
	telefone VARCHAR(11),
	data_nascimento DATE,
	senha VARCHAR(255) NOT NULL,
	permissoes BIGINT NOT NULL,
	ativo BOOLEAN NOT NULL DEFAULT TRUE,
	turma INT DEFAULT NULL,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_usuario),
	FOREIGN KEY(turma) REFERENCES turma(id_turma)
);


CREATE TABLE IF NOT EXISTS emprestimo (
	id_emprestimo SERIAL NOT null,
	exemplar_livro INT NOT NULL,
	usuario INT NOT NULL, -- Esse usuário é o aluno que pede o livro
	data_emprestimo DATE NOT NULL,
	num_renovacoes smallint DEFAULT 0,
	data_prevista_devolucao DATE NOT NULL,
	data_devolucao DATE DEFAULT NULL,
	status smallint DEFAULT 1,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_atualizacao TIMESTAMP,
	PRIMARY KEY(id_emprestimo),
	FOREIGN KEY(exemplar_livro) REFERENCES exemplar_livro(id_exemplar_livro),
	FOREIGN KEY(usuario) REFERENCES usuario(id_usuario)
);


CREATE TABLE IF NOT EXISTS detalhe_emprestimo (
	id_detalhe_emprestimo SERIAL NOT NULL,
	usuario INT NOT NULL, -- Esse é o usuário do sistema que realiza o empréstimo
	emprestimo INT NOT NULL,
	data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	acao SMALLINT NOT NULL,
	detalhe VARCHAR(255),
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	observacao VARCHAR(255),
	primary key(id_detalhe_emprestimo),
	foreign key (usuario) references usuario(id_usuario),
	foreign key (emprestimo) references emprestimo(id_emprestimo)
);

-- Tabela pais
INSERT INTO pais (id_pais, nome, sigla, ativo) VALUES
(1, 'Brasil', 'BR', true),
(2, 'Estados Unidos', 'US', true),
(3, 'Reino Unido', 'UK', true);


-- Tabela autor
INSERT INTO autor (nome, ano_nascimento, nacionalidade, sexo) VALUES
('Machado de Assis', '1839', 1, 'M'),
('J.K. Rowling', '1965', 3, 'F'),
('George R. R. Martin', '1948', 2, 'M');


-- Tabela livro
INSERT INTO livro (isbn, titulo, ano_publicacao, editora, pais) VALUES
('9781234567897', 'Dom Casmurro', '1899-01-01', 'Editora X', 1),
('9780747532743', 'Harry Potter e a Pedra Filosofal', '1997-06-26', 'Bloomsbury', 3),
('9780553103540', 'A Game of Thrones', '1996-08-06', 'Bantam Books', 2);


-- Tabela livro_autor
INSERT INTO livro_autor (id_livro, id_autor) VALUES
(1, 1),  -- Dom Casmurro por Machado de Assis
(2, 2),  -- Harry Potter por J.K. Rowling
(3, 3);  -- A Game of Thrones por George R. R. Martin


-- Tabela categoria
-- INSERT INTO categoria (descricao) VALUES
-- ('Ficção'),
-- ('Fantasia'),
-- ('Clássico');


-- -- Tabela livro_categoria
-- INSERT INTO livro_categoria (id_livro, id_categoria) VALUES
-- (1, 3),  -- Dom Casmurro é Clássico
-- (2, 2),  -- Harry Potter é Fantasia
-- (3, 2);  -- A Game of Thrones é Fantasia


-- Tabela exemplar_livro
INSERT INTO exemplar_livro (id_exemplar_livro, livro, cativo, status, estado) VALUES
(1, 1, FALSE, 1, 1),  -- Exemplar de Dom Casmurro
(2, 2, TRUE, 1, 2),   -- Exemplar de Harry Potter
(3, 3, FALSE, 2, 2);  -- Exemplar de A Game of Thrones

-- Poque as vezes o postgres ferra a sequência do serial
-- estou colacando a sequencia para avançar mais um apartir do max(id)
-- eu sei isso já deveria ser automático, mas eu deu pal no meu pc. :(
select setval((select pg_get_serial_sequence('exemplar_livro', 'id_exemplar_livro')), (select max(id_exemplar_livro) from exemplar_livro) + 1);



-- CriarUsuario = 0b1
-- LerUsuario = 0b10
-- AtualizarUsuario = 0b100
-- DeletarUsuario = 0b1000

INSERT INTO turno (id_turno, descricao) VALUES
(1, 'Manhã'),
(2, 'Tarde'),
(3, 'Noite'),
(4, 'Integral');


INSERT INTO serie (id_serie, descricao) VALUES
(1, '1º Ano'),
(2, '2º Ano'),
(3, '3º Ano');


INSERT INTO turma (id_turma, descricao, serie, turno) VALUES
(1, 'A', 1, 1),
(2, 'B', 1, 1),
(3, 'C', 1, 1),
(4, 'A', 1, 2),
(5, 'B', 1, 2),
(6, 'C', 1, 2),
(7, 'A', 1, 3),
(8, 'B', 1, 3),
(9, 'C', 1, 3),
(10, 'A', 1, 4),
(11, 'B', 1, 4),
(12, 'C', 1, 4),
(13, 'A', 2, 1),
(14, 'B', 2, 1),
(15, 'C', 2, 1),
(16, 'A', 2, 2),
(17, 'B', 2, 2),
(18, 'C', 2, 2),
(19, 'A', 2, 3),
(20, 'B', 2, 3),
(21, 'C', 2, 3),
(22, 'A', 2, 4),
(23, 'B', 2, 4),
(24, 'C', 2, 4),
(25, 'A', 3, 1),
(26, 'B', 3, 1),
(27, 'C', 3, 1),
(28, 'A', 3, 2),
(29, 'B', 3, 2),
(30, 'C', 3, 2),
(31, 'A', 3, 3),
(32, 'B', 3, 3),
(33, 'C', 3, 3),
(34, 'A', 3, 4),
(35, 'B', 3, 4),
(36, 'C', 3, 4);

-- Tabela usuario
INSERT INTO usuario (login, cpf, nome, email, telefone, data_nascimento, senha, permissoes) VALUES
('admin','21747274046', 'Admin User', 'admin@biblioteca.com', '11123456789', '1990-01-01', 'ea4a6e5c2c9f8239b566c1dc4ef972514f159ebd61d046168688a2c8531a4bf3',  16383), -- senhaAdmin
	('biblio','76784092066', 'Bibliotecario', 'bibliotecario@biblioteca.com', '11123456789', '1980-05-15', '76cc71b64516994b050bdb5a79c50865654e551ae126492ee20d08047e841a86',  16383), --senhaBiblio
('joao','26843511040', 'João Silva', 'joao.silva@usuario.com', '11987654321', '1995-08-10', 'bffeba2cd38fb42e180da0254a7893f6db46e3cb2a93ff5e9b5494ce789e1006',  1); --senhaJoao

update usuario set turma = 1 where login = 'joao';

-- Tabela emprestimo
INSERT INTO emprestimo (id_emprestimo, exemplar_livro, usuario, data_emprestimo, data_prevista_devolucao) VALUES
(1, 1, 3, '2024-01-01', '2024-01-15'),
(2, 2, 3, '2024-01-02', '2024-01-16');
select setval((select pg_get_serial_sequence('emprestimo', 'id_emprestimo')), (select max(id_emprestimo) from emprestimo) + 1);



-- Tabela detalhe_emprestimo
INSERT INTO detalhe_emprestimo (id_detalhe_emprestimo, usuario, emprestimo, acao, detalhe, observacao) VALUES
(1, 3, 1, 1, 'Empréstimo realizado', 'eu odeio javascript'),
(2, 3, 2, 2, 'Renovação solicitada', 'c > c++');
select setval((select pg_get_serial_sequence('detalhe_emprestimo', 'id_detalhe_emprestimo')), (select max(id_detalhe_emprestimo) from detalhe_emprestimo) + 1);

