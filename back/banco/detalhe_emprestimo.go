package banco

import (
	"biblioteca/modelos"
	"context"
	"fmt"
  //"time"
  //"os"

	pgx "github.com/jackc/pgx/v5"
)

type ErroBancoDetalheEmprestimo int


const (
	ErroBancoDetalheEmprestimoNenhum = iota
	ErroBancoDetalheEmprestimoObservacaoInvalida
)

func CadastroDetalheEmprestimo(transacao pgx.Tx, detalheEmprestimo modelos.DetalheEmprestimo)  ErroBancoDetalheEmprestimo {
	// Geralmente eu verificaria a existencia do empréstimo 
	// Mas acho que isso será desnecessário	
	
	textoDaQuery := `insert into biblioteca.detalhe_emprestimo(id_detalhe_emprestimo, usuario, emprestimo, data_hora, acao, detalhe, observacao)
values (default, $1, $2, default, $3, $4, $5)`

	if len(detalheEmprestimo.Observacao) > 255 {
		return ErroBancoDetalheEmprestimoObservacaoInvalida
	}
	_, erro := transacao.Exec(
		context.Background(),
		textoDaQuery,
		detalheEmprestimo.Usuario.IdDoUsuario,
		detalheEmprestimo.Emprestimo.IdDoEmprestimo,
		detalheEmprestimo.Acao,
		modelos.TextoAcaoDetalhe(detalheEmprestimo.Acao),
		detalheEmprestimo.Observacao,
	)	
	if erro != nil {
			fmt.Println(erro)
			transacao.Rollback(context.Background())
			panic("Erro no cadastro de um detalhe_empréstimo.")	
	}
	return ErroBancoDetalheEmprestimoNenhum	
}
