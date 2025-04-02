package banco

import (
	"biblioteca/modelos"
	"context"
	"fmt"
  "time"
  "os"
	"strconv"

	pgx "github.com/jackc/pgx/v5"
)

type ErroBancoEmprestimo int

const (
	ErroBancoEmprestimoNenhum = iota
	ErroBancoEmprestimoExemplarEmprestado
	ErroBancoEmprestimoExemplarIndisponivel
)

func CadastroEmprestimo(transacao pgx.Tx, emprestimos ...modelos.Emprestimo)  ErroBancoEmprestimo {
	
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
