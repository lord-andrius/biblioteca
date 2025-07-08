package banco

import (
	"biblioteca/modelos"
	"context"
	"fmt"
	"strings"
)

func RelatorioAutor(filtro []map[string]string) []modelos.RelatorioAutor {
	conexao := PegarConexao()
	textoQuery := `
		SELECT 
			a.id_autor,
			a.nome,
			COALESCE(a.ano_nascimento::varchar, '-') AS ano_nascimento,
			COALESCE(p.nome, '-') AS nacionalidade,
			CASE
				WHEN a.sexo = 'M' THEN 'Masculino(a)'
				WHEN a.sexo = 'F' THEN 'Feminino(a)'
				ELSE '-'
			END AS sexo
		FROM autor a
		INNER JOIN pais p ON a.nacionalidade = p.id_pais
	`

	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		panic(erro)
	}
	defer linhas.Close()

	var relatorioAutores []modelos.RelatorioAutor

	for linhas.Next() {

		var relatorioAutor modelos.RelatorioAutor

		if erro := linhas.Scan(
			&relatorioAutor.IDDoAtuor,
			&relatorioAutor.Nome,
			&relatorioAutor.AnoNascimento,
			&relatorioAutor.Nacionalidade,
			&relatorioAutor.Sexo,
		); erro != nil {
			panic(erro)
		}

		relatorioAutores = append(relatorioAutores, relatorioAutor)
	}

	return relatorioAutores
}

func RelatorioCategoria(filtros []map[string]string) []modelos.RelatorioCategoria {
	conexao := PegarConexao()

	var filtrosTextoQuery []string

	for _, filtro := range filtros {
		if filtro["Id"] != "" {
			filtroTemporario := fmt.Sprintf("id_categoria = %s", filtro["id"])
			filtrosTextoQuery = append(filtrosTextoQuery, filtroTemporario)
		}

		if filtro["Descricacao"] != "" {

			filtroTemporario := fmt.Sprintf("descricao like '%%%s%%'", filtro["descricacao"])
			filtrosTextoQuery = append(filtrosTextoQuery, filtroTemporario)
		}

		if filtro["Ativo"] != "" {

			var ativoFmt string

			if strings.ToLower(filtro["ativo"]) == "s" {
				ativoFmt = "TRUE"
			} else if strings.ToLower(filtro["ativo"]) == "n" {
				ativoFmt = "FALSE"
			} else {
				panic("filtro inválido")
			}

			filtroTemporario := fmt.Sprintf("ativo = %s", ativoFmt)
			filtrosTextoQuery = append(filtrosTextoQuery, filtroTemporario)
		}
	}

	textoQuery := `
		SELECT 
			id_categoria,
			descricao,
			CASE
				WHEN ativo = TRUE THEN 'Sim'
				WHEN ativo = FALSE THEN 'Não'
				ELSE '-'
			END AS ativo
		FROM categoria
	`

	if len(filtrosTextoQuery) > 0 {

		filtroTextoQuery := "WHERE " + strings.Join(filtrosTextoQuery, " AND ")

		textoQuery = fmt.Sprintf("%s %s", textoQuery, filtroTextoQuery)
	}

	textoQueryOrdenacao := "ORDER BY id_categoria, descricao"

	textoQuery = fmt.Sprintf("%s %s", textoQuery, textoQueryOrdenacao)

	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		panic(erro)
	}
	defer linhas.Close()

	var relatorioCategorias []modelos.RelatorioCategoria

	for linhas.Next() {

		var relatorioCategoria modelos.RelatorioCategoria

		if erro := linhas.Scan(
			&relatorioCategoria.IdDaCategoria,
			&relatorioCategoria.Descricao,
			&relatorioCategoria.Ativo,
		); erro != nil {
			panic(erro)
		}

		relatorioCategorias = append(relatorioCategorias, relatorioCategoria)
	}

	return relatorioCategorias
}

func RelatorioLivro(filtros []map[string]string) []modelos.RelatorioLivro {
	conexao := PegarConexao()

	var filtrosTextoQuery []string

	for _, filtro := range filtros {
		if filtro["Id"] != "" {
			filtrosTextoQuery = append(filtrosTextoQuery, FiltroCompararString(filtro["Id"], "l.id_livro"))
		}

		if filtro["Isbn"] != "" {
			filtrosTextoQuery = append(filtrosTextoQuery, FiltroCompararString(filtro["Isbn"], "l.isbn"))
		}

		if filtro["Titulo"] != "" {
			filtrosTextoQuery = append(filtrosTextoQuery, FiltroCompararString(filtro["Titulo"], "l.titulo"))
		}

		if filtro["AnoPublicacao"] != "" {
			filtrosTextoQuery = append(filtrosTextoQuery, FiltroCompararNumeros(filtro["AnoPublicacao"], "EXTRACT(YEAR FROM l.ano_publicacao)"))
		}

		if filtro["Editora"] != "" {
			filtrosTextoQuery = append(filtrosTextoQuery, FiltroCompararString(filtro["Editora"], "l.editora"))
		}

		if filtro["Pais"] != "" {
			filtrosTextoQuery = append(filtrosTextoQuery, FiltroCompararString(filtro["Pais"], "p.nome"))
		}

		if filtro["Autor"] != "" {
			filtrosTextoQuery = append(filtrosTextoQuery, FiltroCompararString(filtro["Autor"], "a.nome"))
		}

		if filtro["Categoria"] != "" {
			filtrosTextoQuery = append(filtrosTextoQuery, FiltroCompararString(filtro["Categoria"], "c.descricacao"))
		}

		if filtro["Subcategoria"] != "" {
			filtrosTextoQuery = append(filtrosTextoQuery, FiltroCompararString(filtro["Subcategoria"], "sc.descricao"))
		}
	}

	textoQuery := `
		SELECT 
			l.id_livro,
			l.isbn,
			l.titulo,
			CAST(l.ano_publicacao AS varchar) AS ano_publicacao,
			l.editora,
			p.nome AS pais,
			COALESCE(a.nome, '-') AS autor,
			COALESCE(c.descricao, '-') AS categoria,
			COALESCE(sc.descricao, '-')  AS subcategoria
		FROM livro l
		INNER JOIN pais p ON l.pais = p.id_pais
		LEFT JOIN livro_autor la ON l.id_livro = la.id_livro 
		LEFT JOIN autor a ON la.id_autor = a.id_autor 
		LEFT JOIN livro_categoria lc ON l.id_livro = lc.id_livro 
		LEFT JOIN categoria c ON lc.id_categoria = c.id_categoria 
		LEFT JOIN livro_subcategoria lsc ON l.id_livro = lsc.id_livro 
		LEFT JOIN subcategoria sc ON lsc.id_subcategoria = sc.id_subcategoria
	`

	if len(filtrosTextoQuery) > 0 {

		filtroTextoQuery := "WHERE " + strings.Join(filtrosTextoQuery, " AND ")

		fmt.Println(filtroTextoQuery)

		textoQuery = fmt.Sprintf("%s %s", textoQuery, filtroTextoQuery)

	}

	textoQueryOrdenacao := "ORDER BY id_livro, titulo, isbn"

	textoQuery = fmt.Sprintf("%s %s", textoQuery, textoQueryOrdenacao)

	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		panic(erro)
	}
	defer linhas.Close()

	var relatorioLivros []modelos.RelatorioLivro

	for linhas.Next() {

		var relatorioLivro modelos.RelatorioLivro

		if erro := linhas.Scan(
			&relatorioLivro.IDDoLivro,
			&relatorioLivro.ISBN,
			&relatorioLivro.Titulo,
			&relatorioLivro.AnoPublicacao,
			&relatorioLivro.Editora,
			&relatorioLivro.Pais,
			&relatorioLivro.Autor,
			&relatorioLivro.Categoria,
			&relatorioLivro.Subcategoria,
		); erro != nil {
			panic(erro)
		}

		relatorioLivros = append(relatorioLivros, relatorioLivro)
	}

	return relatorioLivros
}

func RelatorioExemplar(filtro []map[string]string) []modelos.RelatorioExemplar {
	conexao := PegarConexao()
	textoQuery := `
		SELECT DISTINCT
			id_exemplar_livro,
			l.isbn,
			l.titulo,
			CASE 
				WHEN cativo = TRUE THEN 'Sim' 
				ELSE 'Não' 
			END AS cativo,
			CASE 
				WHEN status = 1 THEN 'Emprestado'
				WHEN status = 2 THEN 'Disponível'
				WHEN status = 3 THEN 'Indisponível'
				ELSE ' - '
			END	AS status,
			CASE 
				WHEN status = 1 THEN 'Bom'
				WHEN status = 2 THEN 'Danificado'
				ELSE ' - '
			END	AS estado
		FROM exemplar_livro el
		INNER JOIN livro l ON el.livro = l.id_livro 
		WHERE ativo = TRUE
	`

	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		panic(erro)
	}
	defer linhas.Close()

	var relatorioExemplares []modelos.RelatorioExemplar

	for linhas.Next() {

		var relatorioExemplar modelos.RelatorioExemplar

		if erro := linhas.Scan(
			&relatorioExemplar.IDDoExemplarLivro,
			&relatorioExemplar.ISBN,
			&relatorioExemplar.Titulo,
			&relatorioExemplar.Cativo,
			&relatorioExemplar.Status,
			&relatorioExemplar.Estado,
		); erro != nil {
			panic(erro)
		}

		relatorioExemplares = append(relatorioExemplares, relatorioExemplar)
	}

	return relatorioExemplares
}

func RelatorioSubcategoria(filtro []map[string]string) []modelos.RelatorioSubcategoria {
	conexao := PegarConexao()
	textoQuery := `
		SELECT 
			id_subcategoria,
			descricao,
			CASE
				WHEN ativo = TRUE THEN 'Sim'
				WHEN ativo = FALSE THEN 'Não'
				ELSE '-'
			END AS ativo
		FROM subcategoria
	`

	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		panic(erro)
	}
	defer linhas.Close()

	var relatorioSubcategorias []modelos.RelatorioSubcategoria

	for linhas.Next() {

		var relatorioSubcategoria modelos.RelatorioSubcategoria

		if erro := linhas.Scan(
			&relatorioSubcategoria.IdDaCategoria,
			&relatorioSubcategoria.Descricao,
			&relatorioSubcategoria.Ativo,
		); erro != nil {
			panic(erro)
		}

		relatorioSubcategorias = append(relatorioSubcategorias, relatorioSubcategoria)
	}

	return relatorioSubcategorias
}

func RelatorioUsuario(filtro []map[string]string) []modelos.RelatorioUsuario {
	conexao := PegarConexao()
	textoQuery := `
		SELECT 
			u.id_usuario,
			u.login,
			u.cpf,
			u.nome,
			COALESCE(u.email, '-') AS email,
			COALESCE(telefone::varchar, '-') AS telefone,
			to_char(data_nascimento, 'mm/dd/yyyy') AS data_nascimento,
			CASE
				WHEN u.turma IS NOT NULL THEN concat(t.descricao, ' - ', s.descricao, ' - ', tu.descricao) 
				ELSE '-'
			END AS turma,
			CASE 
				WHEN u.ativo = TRUE THEN 'Sim'
				WHEN u.ativo = FALSE THEN 'Não'
				ELSE '-'
			END AS ativo
		FROM usuario u
		LEFT JOIN turma t ON u.turma = t.id_turma
		LEFT JOIN serie s ON t.serie = s.id_serie 
		LEFT JOIN turno tu ON t.turno = tu.id_turno
	`

	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		panic(erro)
	}
	defer linhas.Close()

	var relatorioUsuarios []modelos.RelatorioUsuario

	for linhas.Next() {

		var relatorioUsuario modelos.RelatorioUsuario

		if erro := linhas.Scan(
			&relatorioUsuario.IdDoUsuario,
			&relatorioUsuario.Login,
			&relatorioUsuario.CPF,
			&relatorioUsuario.Nome,
			&relatorioUsuario.Email,
			&relatorioUsuario.Telefone,
			&relatorioUsuario.DataNascimento,
			&relatorioUsuario.Turma,
			&relatorioUsuario.Ativo,
		); erro != nil {
			panic(erro)
		}

		relatorioUsuarios = append(relatorioUsuarios, relatorioUsuario)
	}

	return relatorioUsuarios
}

func FiltroCompararString(valor, colunaBanco string) string {

	filtroTextoQuery := fmt.Sprintf("%s LIKE '%%%s%%'", colunaBanco, valor)

	return filtroTextoQuery
}

func FiltroCompararNumeros(valor, colunaBanco string) string {
	var filtroTextoQuery string

	if strings.Contains(valor, "<=>") {

		numeros := strings.Split(valor, "<=>")
		filtroTextoQuery = fmt.Sprintf("%s BETWEEN %s AND %s", colunaBanco, numeros[0], numeros[1])

	} else if strings.Contains(valor, ">=") {

		valor = strings.ReplaceAll(valor, ">=", "")

		filtroTextoQuery = fmt.Sprintf("%s >= %s", colunaBanco, valor)

	} else if strings.Contains(valor, "<=") {

		valor = strings.ReplaceAll(valor, "<=", "")

		filtroTextoQuery = fmt.Sprintf("%s <= %s", colunaBanco, valor)

	} else if strings.Contains(valor, "<>") {

		valor = strings.ReplaceAll(valor, "<>", "")

		filtroTextoQuery = fmt.Sprintf("%s <> %s", colunaBanco, valor)

	} else if strings.Contains(valor, ">") {

		valor = strings.ReplaceAll(valor, ">", "")

		filtroTextoQuery = fmt.Sprintf("%s > %s", colunaBanco, valor)

	} else if strings.Contains(valor, "<") {

		valor = strings.ReplaceAll(valor, "<", "")

		filtroTextoQuery = fmt.Sprintf("%s < %s", colunaBanco, valor)

	} else {

		filtroTextoQuery = fmt.Sprintf("%s = %s", colunaBanco, valor)

	}

	return filtroTextoQuery
}

func FiltroCompararData(valor, colunaBanco string) string {
	var filtroTextoQuery string

	if strings.Contains(valor, "<=>") {

		numeros := strings.Split(valor, "<=>")
		filtroTextoQuery = fmt.Sprintf("'%s' BETWEEN '%s' AND '%s'", colunaBanco, numeros[0], numeros[1])

	} else if strings.Contains(valor, ">=") {

		valor = strings.ReplaceAll(valor, ">=", "")

		filtroTextoQuery = fmt.Sprintf("'%s' >= '%s'", colunaBanco, valor)

	} else if strings.Contains(valor, "<=") {

		valor = strings.ReplaceAll(valor, "<=", "")

		filtroTextoQuery = fmt.Sprintf("'%s' <= '%s'", colunaBanco, valor)

	} else if strings.Contains(valor, "<>") {

		valor = strings.ReplaceAll(valor, "<>", "")

		filtroTextoQuery = fmt.Sprintf("'%s' <> '%s'", colunaBanco, valor)

	} else if strings.Contains(valor, ">") {

		valor = strings.ReplaceAll(valor, ">", "")

		filtroTextoQuery = fmt.Sprintf("'%s' > '%s'", colunaBanco, valor)

	} else if strings.Contains(valor, "<") {

		valor = strings.ReplaceAll(valor, "<", "")

		filtroTextoQuery = fmt.Sprintf("'%s' < '%s'", colunaBanco, valor)

	} else {

		filtroTextoQuery = fmt.Sprintf("'%s' = '%s'", colunaBanco, valor)

	}

	return filtroTextoQuery
}

func FiltroCompararBoleano(valor, coluna string) string {

	var filtroTextoQuery string

	if strings.ToLower(valor) == "sim" {

		filtroTextoQuery = fmt.Sprintf("%s = TRUE", coluna)

	} else {

		filtroTextoQuery = fmt.Sprintf("%s = FALSE", coluna)

	}

	return filtroTextoQuery
}
