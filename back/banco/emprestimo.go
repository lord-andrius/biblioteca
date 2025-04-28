package banco

import (
	"biblioteca/modelos"
	"context"
	"fmt"
	"os"
	"strconv"
	"time"

	pgx "github.com/jackc/pgx/v5"
)

type ErroBancoEmprestimo int

const (
	ErroBancoEmprestimoNenhum = iota
	ErroBancoEmprestimoExemplarEmprestado
	ErroBancoEmprestimoExemplarIndisponivel
	ErroBancoEmprestimoExemplarErroInterno
)

func CadastroEmprestimo(transacao pgx.Tx, emprestimos []modelos.Emprestimo) ErroBancoEmprestimo {
	// Nessa função alteramos os modelos passados

	diasEmprestimo, erro := strconv.Atoi(os.Getenv("DIAS_EMPRESTIMO"))
	if erro != nil {
		panic("Configuração 'DIAS_EMPRESTIMO' é inválida ou inexistente")
	}
	textoDaQuery := `insert into emprestimo(id_emprestimo, exemplar_livro, usuario, data_emprestimo, num_renovacoes, data_prevista_devolucao, status)
values (default, $1, $2, $3, default, $4, default);`
	for indice, emprestimo := range emprestimos {
		exemplar := emprestimo.Exemplar

		if exemplar.Status == modelos.StatusExemplarLivroEmprestado {
			return ErroBancoEmprestimoExemplarEmprestado
		}

		if exemplar.Status == modelos.StatusExemplarLivroIndisponivel {
			return ErroBancoEmprestimoExemplarIndisponivel
		}

		// Nota: Mudar para seguir a regra do usuário

		agora := time.Now()
		dataEmprestimo := agora.Format(time.DateOnly)
		var dataEntregaPrevista string
		if exemplar.Cativo && agora.Weekday() != time.Friday {
			dataEntregaPrevista = agora.AddDate(0, 0, 1).Add(time.Hour * 10).Format(time.DateOnly)
		} else if exemplar.Cativo && agora.Weekday() == time.Friday {
			dataEntregaPrevista = agora.AddDate(0, 0, 3).Add(time.Hour * 10).Format(time.DateOnly)
		} else {
			dataEntregaPrevista = agora.AddDate(0, 0, diasEmprestimo).Format(time.DateOnly)
		}

		emprestimos[indice].DataEmprestimo = agora.Format(time.DateOnly)
		emprestimos[indice].DataDeEntregaPrevista = dataEntregaPrevista
		_, erro := transacao.Exec(
			context.Background(),
			textoDaQuery,
			exemplar.IdDoExemplarLivro,
			emprestimo.Usuario.IdDoUsuario,
			dataEmprestimo,
			dataEntregaPrevista,
		)
		transacao.QueryRow(context.Background(), "select currval('emprestimo_id_emprestimo_seq')").Scan(
			&emprestimos[indice].IdDoEmprestimo,
		)
		if erro != nil {
			fmt.Println(erro)
			transacao.Rollback(context.Background())
			panic("Erro no cadastro de um empréstimo.")
		}

		emprestimos[indice].Exemplar.Status = modelos.StatusExemplarLivroEmprestado
		AtualizarExemplarTransacao(transacao, emprestimos[indice].Exemplar, emprestimos[indice].Exemplar)

	}

	return ErroBancoEmprestimoNenhum
}

func PesquisarEmprestimo(idDoEmprestimo, idDoExemplar, idDoUsuarioEmprestimo, idDoUsuarioAluno int) []modelos.Emprestimo {
	emprestimos := make([]modelos.Emprestimo, 0)
	conexao := PegarConexao()
	var erro error
	var rows pgx.Rows
	if idDoEmprestimo == idDoExemplar &&
		idDoExemplar == idDoUsuarioEmprestimo &&
		idDoUsuarioEmprestimo == idDoUsuarioAluno &&
		idDoUsuarioAluno == 0 {
		// basicamente vamos pegar todos os empréstimos
		// Nota: Lento que só
		rows, erro = conexao.Query(context.Background(), `
				select id_emprestimo, 
							 exemplar_livro,
							 usuario,
							 to_char(data_emprestimo, 'yyyy-mm-dd'),
							 num_renovacoes,
							 to_char(data_prevista_devolucao, 'yyyy-mm-dd'),
							 to_char(data_devolucao, 'yyyy-mm-dd'),
							 status
				from emprestimo
			`)
		if erro != nil {
			return []modelos.Emprestimo{}
		}
	} else if idDoUsuarioAluno == 0 {
		// Aqui nos vamos usar todos os parametros menos idDoUsuarioAluno
		rows, erro = conexao.Query(context.Background(), `
			select id_emprestimo, 
						 exemplar_livro,
						 usuario,
						 to_char(data_emprestimo, 'yyyy-mm-dd'),
						 num_renovacoes,
						 to_char(data_prevista_devolucao, 'yyyy-mm-dd'),
						 to_char(data_devolucao, 'yyyy-mm-dd'),
						 status
			from emprestimo
			where id_emprestimo = $1 or
			exemplar_livro = $2 or
			usuario = $3
		`,
			idDoEmprestimo,
			idDoExemplar,
			idDoUsuarioEmprestimo,
		)
		if erro != nil {
			return []modelos.Emprestimo{}
		}
	} else {
		return PegarEmprestimosPeloIdDoAluno(idDoUsuarioAluno)
	}

	// Tem que ser assim porque dataDevolucao pode ser null
	var dataEmprestimo any
	var dataDevolucao any
	var dataDeEntregaPrevista any
	var emprestimo modelos.Emprestimo
	_, erro = pgx.ForEachRow(
		rows,
		[]any{
			&emprestimo.IdDoEmprestimo,
			&emprestimo.Exemplar.IdDoExemplarLivro,
			&emprestimo.Usuario.IdDoUsuario,
			&dataEmprestimo,
			&emprestimo.NumeroRenovacoes,
			&dataDeEntregaPrevista,
			&dataDevolucao,
			&emprestimo.Status,
		},
		func() error {
			if dataEmprestimo != nil {
				emprestimo.DataEmprestimo, _ = dataEmprestimo.(string)
			}
			if dataDevolucao != nil {
				emprestimo.DataDeDevolucao, _ = dataDevolucao.(string)
			}
			if dataDeEntregaPrevista != nil {
				emprestimo.DataDeEntregaPrevista, _ = dataDeEntregaPrevista.(string)
			}
			emprestimos = append(emprestimos, emprestimo)

			return nil
		},
	)
	if erro != nil {
		fmt.Println(erro)
		return []modelos.Emprestimo{}
	}
	return emprestimos
}

func PegarEmprestimosPeloIdDoAluno(idDoAluno int) []modelos.Emprestimo {
	conexao := PegarConexao()
	emprestimos := make([]modelos.Emprestimo, 0)
	var emprestimo modelos.Emprestimo
	var dataEmprestimo any = nil
	var dataDeDevolucao any = nil
	var dataDeEntregaPrevista any = nil
	detalhes := PegarDetalheEmprestimoPorIdDoAluno(idDoAluno)
	listaIds := "("
	for indice, detalhe := range detalhes {
		listaIds = listaIds + fmt.Sprintf("%d", detalhe.Emprestimo.IdDoEmprestimo)
		if indice < len(detalhes)-1 {
			listaIds = listaIds + ","
		}
	}
	listaIds = listaIds + ")"
	if rows, erro := conexao.Query(context.Background(), `
			select id_emprestimo, 
						 exemplar_livro,
						 usuario,
						 to_char(data_emprestimo, 'yyyy-mm-dd'),
						 num_renovacoes,
						 to_char(data_prevista_devolucao, 'yyyy-mm-dd'),
						 to_char(data_devolucao, 'yyyy-mm-dd'),
						 status
			from emprestimo
			where id_emprestimo in`+listaIds,
	); erro != nil {
		fmt.Println(erro)
		return []modelos.Emprestimo{}
	} else {
		if _, erro := pgx.ForEachRow(
			rows,
			[]any{
				&emprestimo.IdDoEmprestimo,
				&emprestimo.Exemplar.IdDoExemplarLivro,
				&emprestimo.Usuario.IdDoUsuario,
				&dataEmprestimo,
				&emprestimo.NumeroRenovacoes,
				&dataDeEntregaPrevista,
				&dataDeDevolucao,
				&emprestimo.Status,
			},
			func() error {
				if dataEmprestimo != nil {
					emprestimo.DataEmprestimo, _ = dataEmprestimo.(string)
				}
				if dataDeDevolucao != nil {
					emprestimo.DataDeDevolucao, _ = dataDeDevolucao.(string)
				}
				if dataDeEntregaPrevista != nil {
					emprestimo.DataDeEntregaPrevista, _ = dataDeEntregaPrevista.(string)
				}
				emprestimos = append(emprestimos, emprestimo)
				return nil
			},
		); erro != nil {
			fmt.Println(erro)
			return []modelos.Emprestimo{}
		} else {
			return emprestimos
		}
	}
}

func PegarEmprestimoPorId(idEmprestimo int) (modelos.Emprestimo, error) {
	conexao := PegarConexao()

	query := `
		SELECT 
			e.id_emprestimo,
			e.exemplar_livro,
			e.usuario,
			TO_CHAR(e.data_emprestimo, 'yyyy-mm-dd') AS data_emprestimo,
			(
				SELECT count(de.id_detalhe_emprestimo) 
				FROM detalhe_emprestimo de
				WHERE de.emprestimo = e.id_emprestimo
				AND de.acao = 2
			) as num_renovacoes,
			COALESCE(TO_CHAR(e.data_prevista_devolucao, 'yyyy-mm-dd'), '') AS data_prevista_devolucao,
			COALESCE(TO_CHAR(e.data_devolucao, 'yyyy-mm-dd'), '') AS data_devolucao,
			e.status
		FROM emprestimo e
		WHERE e.id_emprestimo = $1
	`
	linha := conexao.QueryRow(context.Background(), query, idEmprestimo)

	var emprestimo modelos.Emprestimo

	if erro := linha.Scan(
		&emprestimo.IdDoEmprestimo,
		&emprestimo.Exemplar.IdDoExemplarLivro,
		&emprestimo.Usuario.IdDoUsuario,
		&emprestimo.DataEmprestimo,
		&emprestimo.NumeroRenovacoes,
		&emprestimo.DataDeEntregaPrevista,
		&emprestimo.DataDeDevolucao,
		&emprestimo.Status,
	); erro != nil {
		fmt.Println(erro)
		return modelos.Emprestimo{}, erro
	}

	return emprestimo, nil
}

func AtualizarEmprestimo(transacao pgx.Tx, emprestimo modelos.Emprestimo) error {
	conexao := PegarConexao()

	query := `
		UPDATE emprestimo
		SET	data_devolucao = current_date,
			status = $1,
			data_atualizacao = current_timestamp
		WHERE id_emprestimo = $2
	`
	_, erro := conexao.Exec(context.Background(), query,
		emprestimo.Status,
		emprestimo.IdDoEmprestimo,
	)
	if erro != nil {
		fmt.Println("Erro atualizarEmprestimo:", erro)
		return erro
	}
	return nil
}
