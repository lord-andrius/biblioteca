package banco

import (
	//"log"
	"biblioteca/modelos"
	"context"
	"fmt"
)

type ErroBancoLivro int

func CriarLivro(novoLivro modelos.Livro, nomeAutores []string, nomeCategorias []string) ErroBancoLivro {
	conexao := PegarConexao()

	if IsbnDuplicado(novoLivro.Isbn) {
		return ErroIsbnDuplicado
	}

	transacao, _ := conexao.Begin(context.Background())
	defer transacao.Rollback(context.Background())

	_, erroQuery := transacao.Exec(context.Background(),
		"insert into livro (isbn, titulo, ano_publicacao, editora, pais, data_criacao) VALUES ($1, $2, $3, $4, $5, current_timestamp)",
		novoLivro.Isbn,
		novoLivro.Titulo,
		novoLivro.AnoPublicacao,
		novoLivro.Editora,
		novoLivro.Pais,
	)

	if erroQuery != nil {
		panic("Um erro imprevisto acontesceu no cadastro do livro. Provavelmente é um bug")
	}

	var idDosAutores []int

	for _, nomeAutor := range nomeAutores {
		idDoAutor := PegarIdAutor(nomeAutor)
		if idDoAutor == 0 {
			InserirAutor(modelos.Autor{Nome: nomeAutor})
			idDoAutor = PegarIdAutor(nomeAutor)
		}
		idDosAutores = append(idDosAutores, idDoAutor)
	}

	var idDoLivro int
	transacao.QueryRow(context.Background(), "select id_livro from livro where isbn = $1", novoLivro.Isbn).Scan(&idDoLivro)

	for _, idDoAutor := range idDosAutores {
		_, erroQuery := transacao.Exec(
			context.Background(),
			"insert into livro_autor(id_livro, id_autor, data_criacao) values ($1, $2, current_timestamp)",
			idDoLivro,
			idDoAutor,
		)

		if erroQuery != nil {
			panic("Um erro imprevisto acontesceu no cadastro do livro. Provavelmente é um bug")
		}
	}

	var idDasCategorias []int

	for _, nomeCategoria := range nomeCategorias {
		var idDaCategoria int

		transacao.QueryRow(
			context.Background(),
			"select id_categoria from categoria where descricao = $1",
			nomeCategoria,
		).Scan(&idDaCategoria)

		if idDaCategoria == 0 {

			transacao.Exec(
				context.Background(),
				"insert into categoria(descricao, data_criacao) values ($1, current_timestamp)",
				nomeCategoria,
			)

			transacao.QueryRow(
				context.Background(),
				"select id_categoria from categoria where descricao = $1",
				nomeCategoria,
			).Scan(&idDaCategoria)

		}
		idDasCategorias = append(idDasCategorias, idDaCategoria)
	}

	for _, idDaCategoria := range idDasCategorias {
		_, erroQuery := transacao.Exec(
			context.Background(),
			"insert into livro_categoria(id_livro, id_categoria, data_criacao) values ($1, $2, current_timestamp)",
			idDoLivro,
			idDaCategoria,
		)

		if erroQuery != nil {
			panic("Um erro imprevisto acontesceu no cadastro do livro. Provavelmente é um bug")
		}
	}

	transacao.Commit(context.Background())
	return ErroNenhum
}

func PesquisarLivro(busca string) []modelos.LivroResposta {
	conexao := PegarConexao()
	busca = "%" + busca + "%"
	textoQuery := "select id_livro, isbn, titulo, to_char(ano_publicacao, 'yyyy-mm-dd'), editora, pais from livro where isbn like $1 or titulo like $1 or ano_publicacao::varchar like $1 or editora like $1 or pais::varchar like $1"
	linhas, erro := conexao.Query(context.Background(), textoQuery, busca)
	if erro != nil {
		return []modelos.LivroResposta{}
	}

	var livroTemporario modelos.Livro
	livrosEncontrados := make([]modelos.LivroResposta, 0)
	for linhas.Next() {
		var livroRespostaTemporario modelos.LivroResposta
		linhas.Scan(&livroTemporario.IdDoLivro, &livroTemporario.Isbn, &livroTemporario.Titulo, &livroTemporario.AnoPublicacao, &livroTemporario.Editora, &livroTemporario.Pais)
		fmt.Println("Pais: ", livroTemporario.Pais)
		paisLivro, _ := PegarPaisPeloId(livroTemporario.Pais)
		categorias, _ := PegarCategoriasAssociadosAoLivro(livroTemporario.IdDoLivro)
		autores, _ := PegarAutoresAssociadosAoLivro(livroTemporario.IdDoLivro)

		livroRespostaTemporario = modelos.LivroResposta{
			IdDoLivro:     livroTemporario.IdDoLivro,
			Isbn:          livroTemporario.Isbn,
			Titulo:        livroTemporario.Titulo,
			AnoPublicacao: livroTemporario.AnoPublicacao,
			Editora:       livroTemporario.Editora,
			Pais:          paisLivro,
			Categorias:    categorias,
			Autores:       autores,
		}

		livrosEncontrados = append(livrosEncontrados, livroRespostaTemporario)
	}

	return livrosEncontrados
}

func PegarTodosLivros() []modelos.LivroResposta {
	conexao := PegarConexao()
	textoQuery := "select id_livro, isbn, titulo, to_char(ano_publicacao, 'yyyy-mm-dd'), editora, pais from livro"
	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		return []modelos.LivroResposta{}
	}

	var livroTemporario modelos.Livro
	livrosEncontrados := make([]modelos.LivroResposta, 0)
	for linhas.Next() {
		var livroRespostaTemporario modelos.LivroResposta
		linhas.Scan(&livroTemporario.IdDoLivro, &livroTemporario.Isbn, &livroTemporario.Titulo, &livroTemporario.AnoPublicacao, &livroTemporario.Editora, &livroTemporario.Pais)

		paisLivro, _ := PegarPaisPeloId(livroTemporario.Pais)
		categorias, _ := PegarCategoriasAssociadosAoLivro(livroTemporario.IdDoLivro)
		autores, _ := PegarAutoresAssociadosAoLivro(livroTemporario.IdDoLivro)

		livroRespostaTemporario = modelos.LivroResposta{
			IdDoLivro:     livroTemporario.IdDoLivro,
			Isbn:          livroTemporario.Isbn,
			Titulo:        livroTemporario.Titulo,
			AnoPublicacao: livroTemporario.AnoPublicacao,
			Editora:       livroTemporario.Editora,
			Pais:          paisLivro,
			Categorias:    categorias,
			Autores:       autores,
		}

		livrosEncontrados = append(livrosEncontrados, livroRespostaTemporario)
	}

	return livrosEncontrados
}

func PegarLivroPeloId(id int) (modelos.Livro, bool) {
	conexao := PegarConexao()
	var livro modelos.Livro
	textoQuery := "select id_livro, isbn, titulo, to_char(ano_publicacao, 'yyyy-mm-dd'), editora, pais from livro where id_livro = $1"
	if erro := conexao.QueryRow(context.Background(), textoQuery, id).Scan(
		&livro.IdDoLivro,
		&livro.Isbn,
		&livro.Titulo,
		&livro.AnoPublicacao,
		&livro.Editora,
		&livro.Pais,
	); erro == nil {
		return livro, true
	} else {
		return livro, false
	}
}

func AtualizarLivro(livroComDadosAntigos, livroAtualizado modelos.Livro, nomeAutores []string, nomeCategorias []string) ErroBancoLivro {
	conexao := PegarConexao()

	if livroComDadosAntigos.Isbn != livroAtualizado.Isbn && IsbnDuplicado(livroAtualizado.Isbn) {
		return ErroLoginDuplicado
	}

	transacao, _ := conexao.Begin(context.Background())
	defer transacao.Rollback(context.Background())

	var erroQuery error

	textoQuery := "update livro set isbn = $1, titulo = $2, ano_publicacao = $3, editora = $4, pais = $5, data_atualizacao = current_timestamp where id_livro = $6"
	if _, erroQuery := transacao.Exec(
		context.Background(),
		textoQuery,
		livroAtualizado.Isbn,
		livroAtualizado.Titulo,
		livroAtualizado.AnoPublicacao,
		livroAtualizado.Editora,
		livroAtualizado.Pais,
		livroAtualizado.IdDoLivro,
	); erroQuery != nil {
		panic("Um erro desconhecido acontesceu na atualização do livro")
	}

	if _, erroQuery = transacao.Exec(
		context.Background(),
		"delete from livro_autor where id_livro = $1", livroComDadosAntigos.IdDoLivro,
	); erroQuery != nil {
		panic("Um erro imprevisto acontenceu na exclusão da associação do livro autor. Provavelmente é um bug")
	}
	var idDosAutores []int

	for _, nomeAutor := range nomeAutores {
		idDoAutor := PegarIdAutor(nomeAutor)
		if idDoAutor == 0 {
			InserirAutor(modelos.Autor{Nome: nomeAutor})
			idDoAutor = PegarIdAutor(nomeAutor)
		}
		idDosAutores = append(idDosAutores, idDoAutor)
	}
	for _, idDoAutor := range idDosAutores {
		if _, erroQuery := transacao.Exec(
			context.Background(),
			"insert into livro_autor(id_livro, id_autor, data_criacao) values ($1, $2, current_timestamp)",
			livroComDadosAntigos.IdDoLivro,
			idDoAutor,
		); erroQuery != nil {
			panic("Um erro imprevisto acontesceu no cadastro do livro. Provavelmente é um bug")
		}
	}

	if _, erroQuery = transacao.Exec(
		context.Background(),
		"delete from livro_categoria where id_livro = $1", livroComDadosAntigos.IdDoLivro,
	); erroQuery != nil {
		panic("Um erro imprevisto acontenceu na exclusão da associação do livro autor. Provavelmente é um bug")
	}

	var idDasCategorias []int

	for _, nomeCategoria := range nomeCategorias {
		var idDaCategoria int

		transacao.QueryRow(
			context.Background(),
			"select id_categoria from categoria where descricao = $1",
			nomeCategoria,
		).Scan(&idDaCategoria)

		if idDaCategoria == 0 {

			transacao.Exec(
				context.Background(),
				"insert into categoria(descricao, data_criacao) values ($1, current_timestamp)",
				nomeCategoria,
			)

			transacao.QueryRow(
				context.Background(),
				"select id_categoria from categoria where descricao = $1",
				nomeCategoria,
			).Scan(&idDaCategoria)

		}
		idDasCategorias = append(idDasCategorias, idDaCategoria)
	}

	for _, idDaCategoria := range idDasCategorias {
		_, erroQuery := transacao.Exec(
			context.Background(),
			"insert into livro_categoria(id_livro, id_categoria, data_criacao) values ($1, $2, current_timestamp)",
			livroComDadosAntigos.IdDoLivro,
			idDaCategoria,
		)

		if erroQuery != nil {
			panic("Um erro imprevisto acontesceu no cadastro do livro. Provavelmente é um bug")
		}
	}

	transacao.Commit(context.Background())
	return ErroNenhum
}

func ExcluirLivro(idDoLivro int) ErroBancoLivro {
	conexao := PegarConexao()
	_, achou := PegarLivroPeloId(idDoLivro)
	if !achou {
		return ErroLivroInexistente
	}

	transacao, _ := conexao.Begin(context.Background())
	defer transacao.Rollback(context.Background())

	var erroQuery error

	if _, erroQuery = transacao.Exec(
		context.Background(),
		"delete from livro_autor where id_livro = $1", idDoLivro,
	); erroQuery != nil {
		panic("Um erro imprevisto acontenceu na exclusão da associação do livro autor. Provavelmente é um bug")
	}

	if _, erroQuery = transacao.Exec(
		context.Background(),
		"delete from livro_categoria where id_livro = $1", idDoLivro,
	); erroQuery != nil {
		panic("Um erro imprevisto acontenceu na exclusão da associação do livro autor. Provavelmente é um bug")
	}

	if _, erroQuery = transacao.Exec(
		context.Background(),
		"delete from livro where id_livro = $1",
		idDoLivro,
	); erroQuery != nil {
		panic("Um erro imprevisto acontenceu na exclusão do livro. Provavelmente é um bug")
	}

	transacao.Commit(context.Background())
	return ErroNenhum
}

func PegarIdLivro(isbn string) int {
	conexao := PegarConexao()
	var id int
	if conexao.QueryRow(context.Background(), "select id_livro from livro where isbn = $1", isbn).Scan(&id) == nil {
		return id
	} else {
		return 0
	}
}

func IsbnDuplicado(cpf string) bool {
	conexao := PegarConexao()
	qtdIsbn := 0
	if conexao.QueryRow(context.Background(), "select count(isbn) from livro where isbn = $1", cpf).Scan(&qtdIsbn) == nil {
		return qtdIsbn > 0
	} else {
		panic("Erro ao procurar por isbn duplicado. Provavelmente é um bug")
	}
}

func PegarAutoresAssociadosAoLivro(idLivro int) ([]modelos.AutorResposta, error) {
	conexao := PegarConexao()
	consulta := `
		SELECT 
			a.id_autor,
			a.nome, 
			a.ano_nascimento,
			a.nacionalidade as nacionalidade_codigo,
			p.nome,
			a.sexo as codigo_sexo,
			CASE 
				WHEN a.sexo = 'M' THEN 'Masculino' 
				WHEN a.sexo = 'F' THEN 'feminino'
			END 
		FROM autor a
		LEFT JOIN pais p ON a.nacionalidade = p.id_pais
		INNER JOIN livro_autor la ON a.id_autor = la.id_autor
		WHERE la.id_livro = $1
	`
	linhas, erroQuery := conexao.Query(context.Background(), consulta, idLivro)
	if erroQuery != nil {
		panic("Um erro aconteceu ao tentar pegar os autores associados ao livro")
	}
	var autores []modelos.AutorResposta
	for linhas.Next() {
		var autor modelos.AutorResposta
		linhas.Scan(&autor.ID, &autor.Nome, &autor.NacionalidadeCodigo, &autor.Nacionalidade, &autor.SexoCodigo, &autor.Sexo)
		autores = append(autores, autor)
	}

	return autores, nil
}

func PegarCategoriasAssociadosAoLivro(idLivro int) ([]modelos.Categoria, error) {
	conexao := PegarConexao()
	consulta := `
		SELECT c.id_categoria, c.descricao 
		FROM categoria c
		INNER JOIN livro_categoria lc ON c.id_categoria = lc.id_categoria
		WHERE lc.id_livro = $1
	`
	linhas, erroQuery := conexao.Query(context.Background(), consulta, idLivro)
	if erroQuery != nil {
		panic("Um erro aconteceu ao tentar pegar as categorias associados ao livro")
	}
	var categorias []modelos.Categoria
	for linhas.Next() {
		var categoria modelos.Categoria
		linhas.Scan(&categoria.IdDaCategoria, &categoria.Descricao)
		categorias = append(categorias, categoria)
	}

	return categorias, nil
}
