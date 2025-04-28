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

func CadastroEmprestimo(transacao pgx.Tx, emprestimos ...modelos.Emprestimo) ErroBancoEmprestimo {

	diasEmprestimo, erro := strconv.Atoi(os.Getenv("DIAS_EMPRESTIMOS"))
	if erro != nil {
		panic("Configuração 'DIAS_EMPRESTIMOS' é inválida ou inexistente")
	}
	textoDaQuery := `insert into emprestimo(id_emprestimo, exemplar_livro, usuario, data_emprestimo, num_renovacoes, data_prevista_devolucao, status)
values (default, $1, $2, $3, default, $4, default);`
	for _, emprestimo := range emprestimos {
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
		_, erro := transacao.Exec(
			context.Background(),
			textoDaQuery,
			exemplar.IdDoExemplarLivro,
			emprestimo.Usuario.IdDoUsuario,
			dataEmprestimo,
			dataEntregaPrevista,
		)

		if erro != nil {
			fmt.Println(erro)
			transacao.Rollback(context.Background())
			panic("Erro no cadastro de um empréstimo.")
		}
	}

	return ErroBancoEmprestimoNenhum
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
