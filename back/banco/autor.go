package banco

import (
	"biblioteca/modelos"
	"context"
	"fmt"
	"strings"
)

// VisualizarAutores realizar o SELECT no banco de dados, pegar todos os registros da tabela de autor
func VisualizarAutores() ([]modelos.AutorResposta, error) {
	conexao := PegarConexao()

	var autores []modelos.AutorResposta

	linhas, err := conexao.Query(context.Background(),
		`SELECT 
			a.id_autor AS id,
			a.nome AS nome,
			a.ano_nascimento AS ano_nascimento,
			p.nome AS nacionalidade,
			a.nacionalidade AS nacionalidade_codigo,
			CASE	 
				WHEN a.sexo = 'M' THEN  'masculino'
				WHEN a.sexo = 'F' THEN 'feminino'
			END AS sexo,
			a.sexo AS sexo_codigo
		FROM autor a
		left join pais p on a.nacionalidade = p.id_pais`,
	)
	if err != nil {
		fmt.Println("Erro ao tentar executar a query")
		return autores, err
	}
	defer linhas.Close()

	for linhas.Next() {
		var autor modelos.AutorResposta
		if err := linhas.Scan(&autor.ID, &autor.Nome, &autor.AnoNascimento, &autor.Nacionalidade, &autor.NacionalidadeCodigo, &autor.Sexo, &autor.SexoCodigo); err != nil && !strings.Contains(err.Error(), "cannot scan NULL") {
			fmt.Println("Erro ao tentar scannear o resultado da query")
			return autores, err
		}
		autores = append(autores, autor)
	}

	return autores, nil
}

// InserirAutor realizar o INSERT no banco de dados, pegando como base os parametros da Struct Autor
func InserirAutor(a modelos.Autor) error {
	conexao := PegarConexao()

	var parametroAnoNascimento interface{}
	if a.AnoNascimento == 0 {
		parametroAnoNascimento = nil
	} else {
		parametroAnoNascimento = a.AnoNascimento
	}

	var parametroNacionalidade interface{}
	if a.Nacionalidade == 0 {
		parametroNacionalidade = nil
	} else {
		parametroNacionalidade = a.Nacionalidade
	}

	var parametroSexo interface{}
	if a.Sexo == "" {
		parametroSexo = nil
	} else {
		parametroSexo = a.Sexo
	}

	if _, err := conexao.Exec(context.Background(),
		"INSERT INTO autor (nome, ano_nascimento, nacionalidade, sexo) VALUES ($1, $2, $3, $4)",
		a.Nome,
		parametroAnoNascimento,
		parametroNacionalidade,
		parametroSexo,
	); err != nil {
		fmt.Println(a.Nome, a.AnoNascimento, a.Nacionalidade, a.Sexo)
		return err
	}

	return nil
}

// AtualizarAutor realizar o UPDATE no banco de dados, pegando como base os parametros da Struct Autor
func AtualizarAutor(a modelos.Autor) error {
	conexao := PegarConexao()

	var parametroAnoNascimento interface{}
	if a.AnoNascimento == 0 {
		parametroAnoNascimento = nil
	} else {
		parametroAnoNascimento = a.AnoNascimento
	}

	var parametroNacionalidade interface{}
	if a.Nacionalidade == 0 {
		parametroNacionalidade = nil
	} else {
		parametroNacionalidade = a.Nacionalidade
	}

	var parametroSexo interface{}
	if a.Sexo == "" {
		parametroSexo = nil
	} else {
		parametroSexo = a.Sexo
	}

	if _, err := conexao.Exec(context.Background(), `
		UPDATE autor
		SET nome = $1,
			ano_nascimento = $2,
			nacionalidade = $3,
			sexo = $4,
			data_atualizacao = CURRENT_TIMESTAMP
		WHERE id_autor = $5`,
		a.Nome,
		parametroAnoNascimento,
		parametroNacionalidade,
		parametroSexo,
		a.ID,
	); err != nil {
		return err
	}

	return nil
}

// ExcluirAutor realizar o DELETE no banco de dados, pegando como base os parametros da Struct Autor
func ExcluirAutor(a modelos.Autor) error {
	conexao := PegarConexao()

	if _, err := conexao.Exec(context.Background(), `
		DELETE FROM autor
		WHERE id_autor = $1`,
		a.ID,
	); err != nil {
		return err
	}

	return nil
}

func PegarIdAutor(nome string) int {
	conexao := PegarConexao()
	var id int
	if conexao.QueryRow(context.Background(), "select id_autor from autor where nome = $1", nome).Scan(&id) == nil {
		return id
	} else {
		return 0
	}
}
