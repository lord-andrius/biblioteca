package banco

import (
	"biblioteca/modelos"
	"context"
	"fmt"
	"time"

	pgx "github.com/jackc/pgx/v5"
)

func PegarDashboard() modelos.Dashboard {
	conexao := PegarConexao()
	var dash modelos.Dashboard

	textoQueryEmprestimo := `select count(id_detalhe_emprestimo), to_char(Date(data_criacao), 'yyyy-mm-dd')
	from  detalhe_emprestimo
	where data_criacao >= $1 and
	data_criacao <= $2 and
	acao = 1
	group by Date(data_criacao)
	order by Date(data_criacao) desc;`

	agora := time.Now()
	domingo := agora.AddDate(0, 0, -int(agora.Weekday()))
	sabado := agora.AddDate(0, 0, int(time.Saturday-agora.Weekday()))
	domingoStr := domingo.Local().Format(time.DateOnly)
	sabadoStr := sabado.Local().Format(time.DateOnly)

	qtdEmprestimo := 0
	dataEmprestimoStr := "";
	linhas, erro := conexao.Query(context.Background(), textoQueryEmprestimo, domingoStr, sabadoStr)
	if erro != nil {
		fmt.Println(erro)
		return dash
	}

	_, erro = pgx.ForEachRow(linhas, []any{&qtdEmprestimo, &dataEmprestimoStr}, func() error {
		dataEmprestimo, _ := time.Parse(time.DateOnly, dataEmprestimoStr)

		dash.QtdEmprestimoSemana[dataEmprestimo.Weekday()] = qtdEmprestimo
		return nil
	})

	if erro != nil {
		fmt.Println(erro)
		panic("bug")
	}

	qtdDevolucoes := 0
	textoQueryDevolucoes := `select count(id_detalhe_emprestimo), to_char(Date(data_criacao), 'yyyy-mm-dd')
	from  detalhe_emprestimo
	where data_criacao >= $1 and
	data_criacao <= $2 and
	acao = 3
	group by Date(data_criacao)
	order by Date(data_criacao) desc;`
	linhas, erro = conexao.Query(context.Background(), textoQueryDevolucoes, domingoStr, sabadoStr)
	if erro != nil {
		fmt.Println(erro)
		return dash
	}
	_, erro = pgx.ForEachRow(linhas, []any{&qtdDevolucoes, &dataEmprestimoStr}, func() error {
		dataEmprestimo, _ := time.Parse(time.DateOnly, dataEmprestimoStr)
		dash.QtdDevolucaoSemana[dataEmprestimo.Weekday()] = qtdDevolucoes
		return nil
	})

	if erro != nil {
		fmt.Println(erro)
		return dash
	}

	qtdLivrosAtrasados := 0

	// só vai pegar a quantidade de livros atrasados atuais
	textoQueryLivrosAtrasados := `select count(id_emprestimo)
	from emprestimo
	where now() > data_prevista_devolucao and
	data_devolucao is null;
	`
	conexao.QueryRow(context.Background(), textoQueryLivrosAtrasados).Scan(&qtdLivrosAtrasados)
	dash.QtdLivrosAtrasadosSemana[agora.Weekday()] = qtdLivrosAtrasados

	return dash
}

func PegarQtdDevolucoesAtrasadoSemana() [7]int {
	conexao := PegarConexao()

	resultado := [7]int{}

	agora := time.Now()
	domingo := agora.AddDate(0, 0, -int(agora.Weekday()))
	sabado := agora.AddDate(0, 0, int(time.Saturday-agora.Weekday()))
	domingoStr := domingo.Local().Format(time.DateOnly)
	sabadoStr := sabado.Local().Format(time.DateOnly)

	textoQuery := `select count(id_detalhe_emprestimo),  to_char(Date(de.data_criacao), 'yyyy-mm-dd')
	from  detalhe_emprestimo de
	join emprestimo e on e.id_emprestimo = de.emprestimo
	where de.data_criacao >= $1 and
	de.data_criacao <= $2 and
	now() > data_prevista_devolucao and
	data_devolucao is null and
	acao = 3
	group by Date(de.data_criacao)
	order by Date(de.data_criacao) desc;`

	linhas, erro := conexao.Query(context.Background(), textoQuery, domingoStr, sabadoStr)
	if erro != nil {
		fmt.Println(erro)
		return resultado
	}
	qtdDevolucoes := 0
	dataEmprestimoStr := ""
	pgx.ForEachRow(linhas, []any{&qtdDevolucoes, &dataEmprestimoStr}, func() error {
		dataEmprestimo, _ := time.Parse(time.DateOnly, dataEmprestimoStr)
		resultado[dataEmprestimo.Weekday()] = qtdDevolucoes
		return nil
	})

	return resultado
}
