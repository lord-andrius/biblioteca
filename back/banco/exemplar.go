package banco

import (
	"biblioteca/modelos"
	"context"
	"fmt"

	pgx "github.com/jackc/pgx/v5"
)

type ErroBancoExemplar int

const (
	ErroBancoExemplarNenhum = iota
	ErroBancoExemplarMudouLivro
	ErroBancoExemplarLivroInexistente
)

func CadastrarExemplar(novoExemplar modelos.ExemplarLivro) (modelos.ExemplarLivro, ErroBancoExemplar) {
	conexao := PegarConexao()
	livro, achou := PegarLivroPeloId(novoExemplar.Livro.IdDoLivro)
	if !achou {
		return modelos.ExemplarLivro{}, ErroBancoExemplarLivroInexistente
	}
	novoExemplar.Livro = livro
	textoDaQuery := "insert into exemplar_livro(id_exemplar_livro, livro, cativo, status, estado, ativo) values (default, $1, $2, $3, $4, $5)"
	_, erro := conexao.Exec(
		context.Background(),
		textoDaQuery,
		novoExemplar.Livro.IdDoLivro,
		novoExemplar.Cativo,
		novoExemplar.Status,
		novoExemplar.Estado,
		true,
	)
	if erro != nil {
		fmt.Println(erro)
		panic("Um erro inesperado acontesceu. Provavelmente é um bug")
	}

	textoDaQuery = "select max(id_exemplar_livro) from exemplar_livro"
	conexao.QueryRow(context.Background(), textoDaQuery).Scan(&novoExemplar.IdDoExemplarLivro)
	return novoExemplar, ErroBancoExemplarNenhum
}

func BuscarExemplares(exemplar modelos.ExemplarLivro) []modelos.ExemplarLivro {
	if exemplar.IdDoExemplarLivro != 0 {
		if exemplar, achou := PegarExemplarPorId(exemplar.IdDoExemplarLivro); achou {
			return []modelos.ExemplarLivro{exemplar}
		}
		return []modelos.ExemplarLivro{}
	}

	if exemplar.Livro.IdDoLivro != 0 {
		if exemplares, achou := PegarExemplarPeloIdDoLivro(exemplar.Livro.IdDoLivro); achou {
			return exemplares
		}
		return []modelos.ExemplarLivro{}
	}

	// Pegando todos os livros
	conexao := PegarConexao()
	textoQuery := `
	select 
	el.id_exemplar_livro,
	l.id_livro,
	l.isbn,
	l.titulo,
	to_char(l.ano_publicacao, 'yyyy-mm-dd'),
	l.editora ,
	l.pais ,
	el.cativo,
	el.status,
	el.estado,
	el.ativo
from exemplar_livro el
join livro l on l.id_livro = el.livro`

	var exemplarTemporario modelos.ExemplarLivro
	exemplaresAchados := make([]modelos.ExemplarLivro, 0, 10)
	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		return []modelos.ExemplarLivro{}
	}

	_, erro = pgx.ForEachRow(
		linhas,
		[]any{
			&exemplarTemporario.IdDoExemplarLivro,
			&exemplarTemporario.Livro.IdDoLivro,
			&exemplarTemporario.Livro.Isbn,
			&exemplarTemporario.Livro.Titulo,
			&exemplarTemporario.Livro.AnoPublicacao,
			&exemplarTemporario.Livro.Editora,
			&exemplarTemporario.Livro.Pais,
			&exemplarTemporario.Cativo,
			&exemplarTemporario.Status,
			&exemplarTemporario.Estado,
			&exemplarTemporario.Ativo,
		},
		func() error {
			exemplaresAchados = append(exemplaresAchados, exemplarTemporario)
			return nil
		},
	)

	if erro != nil {
		return []modelos.ExemplarLivro{}
	}
	return exemplaresAchados

}

func PegarExemplarPorId(id int) (modelos.ExemplarLivro, bool) {
	conexao := PegarConexao()
	textoQuery := `
	select 
	el.id_exemplar_livro,
	l.id_livro,
	l.isbn,
	l.titulo,
	to_char(l.ano_publicacao, 'yyyy-mm-dd'),
	l.editora ,
	l.pais ,
	el.cativo,
	el.status,
	el.estado,
	el.ativo
from exemplar_livro el
join livro l on l.id_livro = el.livro
where el.id_exemplar_livro = $1`

	var exemplarEncontrado modelos.ExemplarLivro
	if erro := conexao.QueryRow(context.Background(), textoQuery, id).Scan(
		&exemplarEncontrado.IdDoExemplarLivro,
		&exemplarEncontrado.Livro.IdDoLivro,
		&exemplarEncontrado.Livro.Isbn,
		&exemplarEncontrado.Livro.Titulo,
		&exemplarEncontrado.Livro.AnoPublicacao,
		&exemplarEncontrado.Livro.Editora,
		&exemplarEncontrado.Livro.Pais,
		&exemplarEncontrado.Cativo,
		&exemplarEncontrado.Status,
		&exemplarEncontrado.Estado,
		&exemplarEncontrado.Ativo,
	); erro != nil {
		return modelos.ExemplarLivro{}, false
	}

	return exemplarEncontrado, true
}

func PegarExemplarPorIdTransacao(transacao pgx.Tx, id int) (modelos.ExemplarLivro, bool) {
	textoQuery := `
	select 
	el.id_exemplar_livro,
	l.id_livro,
	l.isbn,
	l.titulo,
	to_char(l.ano_publicacao, 'yyyy-mm-dd'),
	l.editora ,
	l.pais ,
	el.cativo,
	el.status,
	el.estado,
	el.ativo
from exemplar_livro el
join livro l on l.id_livro = el.livro
where el.id_exemplar_livro = $1`

	var exemplarEncontrado modelos.ExemplarLivro
	if erro := transacao.QueryRow(context.Background(), textoQuery, id).Scan(
		&exemplarEncontrado.IdDoExemplarLivro,
		&exemplarEncontrado.Livro.IdDoLivro,
		&exemplarEncontrado.Livro.Isbn,
		&exemplarEncontrado.Livro.Titulo,
		&exemplarEncontrado.Livro.AnoPublicacao,
		&exemplarEncontrado.Livro.Editora,
		&exemplarEncontrado.Livro.Pais,
		&exemplarEncontrado.Cativo,
		&exemplarEncontrado.Status,
		&exemplarEncontrado.Estado,
		&exemplarEncontrado.Ativo,
	); erro != nil {
		return modelos.ExemplarLivro{}, false
	}

	return exemplarEncontrado, true
}


func PegarExemplarPeloIdDoLivro(IdDoLivro int) ([]modelos.ExemplarLivro, bool) {
	conexao := PegarConexao()
	textoQuery := `
	select 
	el.id_exemplar_livro,
	l.id_livro,
	l.isbn,
	l.titulo,
	to_char(l.ano_publicacao, 'yyyy-mm-dd'),
	l.editora ,
	l.pais ,
	el.cativo,
	el.status,
	el.estado,
	el.ativo
from exemplar_livro el
join livro l on l.id_livro = el.livro
where l.id_livro = $1`

	var exemplarTemporario modelos.ExemplarLivro
	exemplaresAchados := make([]modelos.ExemplarLivro, 0, 10)
	linhas, erro := conexao.Query(context.Background(), textoQuery, IdDoLivro)
	if erro != nil {
		return []modelos.ExemplarLivro{}, false
	}

	_, erro = pgx.ForEachRow(
		linhas,
		[]any{
			&exemplarTemporario.IdDoExemplarLivro,
			&exemplarTemporario.Livro.IdDoLivro,
			&exemplarTemporario.Livro.Isbn,
			&exemplarTemporario.Livro.Titulo,
			&exemplarTemporario.Livro.AnoPublicacao,
			&exemplarTemporario.Livro.Editora,
			&exemplarTemporario.Livro.Pais,
			&exemplarTemporario.Cativo,
			&exemplarTemporario.Status,
			&exemplarTemporario.Estado,
			&exemplarTemporario.Ativo,
		},
		func() error {
			exemplaresAchados = append(exemplaresAchados, exemplarTemporario)
			return nil
		},
	)

	if erro != nil {
		return []modelos.ExemplarLivro{}, false
	}
	return exemplaresAchados, true
}

func AtualizarExemplar(exemplarComDadosAntigos, exemplarComDadosAtualizados modelos.ExemplarLivro) ErroBancoExemplar {
	// Se tentar mudar o livro do exemplar
	// vamos retornar um erro.
	// Pensar melhor sobre o que acontesce se mudar o
	// exemplar.
	if exemplarComDadosAtualizados.Livro.IdDoLivro != exemplarComDadosAntigos.Livro.IdDoLivro {
		return ErroBancoExemplarMudouLivro
	}

	conexao := PegarConexao()
	textoQuery := "update exemplar_livro set cativo = $1, status = $2, estado = $3, ativo = $4"
	if _, erroQuery := conexao.Query(
		context.Background(),
		textoQuery,
		exemplarComDadosAtualizados.Cativo,
		exemplarComDadosAtualizados.Status,
		exemplarComDadosAtualizados.Estado,
		exemplarComDadosAtualizados.Ativo,
	); erroQuery != nil {
		panic("Um erro desconhecido acontesceu na atualização do exemplar")
	}
	return ErroBancoExemplarNenhum
}

func DeletarExemplar(exemplarASerExcluido modelos.ExemplarLivro) ErroBancoExemplar {
	exemplarDesativado := exemplarASerExcluido
	exemplarDesativado.Ativo = false
	return AtualizarExemplar(exemplarASerExcluido, exemplarDesativado)
}
