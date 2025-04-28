package banco

import (
	"biblioteca/modelos"
	"context"
	"fmt"
  "time"
  //"os"

	pgx "github.com/jackc/pgx/v5"
)

type ErroBancoDetalheEmprestimo int


const (
	ErroBancoDetalheEmprestimoNenhum = iota
	ErroBancoDetalheEmprestimoObservacaoInvalida
)

func CadastroDetalheEmprestimo(transacao pgx.Tx, detalhesEmprestimos []modelos.DetalheEmprestimo)  ErroBancoDetalheEmprestimo {
	// Geralmente eu verificaria a existencia do empréstimo 
	// Mas acho que isso será desnecessário	
	
	textoDaQuery := `insert into biblioteca.detalhe_emprestimo(id_detalhe_emprestimo, usuario, emprestimo, data_hora, acao, detalhe)
values (default, $1, $2, default, $3, $4)`
	for indice, detalheEmprestimo := range detalhesEmprestimos {
		if len(detalheEmprestimo.Observacao) > 255 {
			return ErroBancoDetalheEmprestimoObservacaoInvalida
		}

		detalhesEmprestimos[indice].DataHora = time.Now().Format(time.DateTime)
			
		_, erro := transacao.Exec(
			context.Background(),
			textoDaQuery,
			detalheEmprestimo.Usuario.IdDoUsuario,
			detalheEmprestimo.Emprestimo.IdDoEmprestimo,
			detalheEmprestimo.Acao,
			modelos.TextoAcaoDetalhe(detalheEmprestimo.Acao),
		)	
		if erro != nil {
				fmt.Println(erro)
				transacao.Rollback(context.Background())
				panic("Erro no cadastro de um detalhe_empréstimo.")	
		}
		transacao.QueryRow(context.Background(), "select currval('detalhe_emprestimo_id_detalhe_emprestimo_seq')").Scan(
			&detalhesEmprestimos[indice].IdDetalheEmprestimo,
		)
	}
	return ErroBancoDetalheEmprestimoNenhum	
}
/*
func PegarDetalheEmprestimoPorIdDoEmprestimo(idDoEmprestimo int) []modelos.DetalheEmprestimo {
	detalhes := make([]modelos.DetalheEmprestimo, 0)
	conexao := PegarConexao()
	rows, erro := conexao.Query(
		``
	)
} 
*/
func PegarDetalheEmprestimoPorIdDoEmprestimo(idDoEmprestimo int) []modelos.DetalheEmprestimo {
	conexao := PegarConexao();
	detalhes := make([]modelos.DetalheEmprestimo, 0)
	var detalhe modelos.DetalheEmprestimo
	var dataHora interface{}
	rows, _ := conexao.Query(
		context.Background(), `
		select
		id_detalhe_emprestimo,
		usuario,
		emprestimo,
		to_char(data_hora, 'yyyy-mm-dd'),
		acao,
		detalhe
		from detalhe_emprestimo
		where emprestimo = $1;`,
		idDoEmprestimo,
	)
	if _, erro := pgx.ForEachRow(
				rows,	
				[]any{
					&detalhe.IdDetalheEmprestimo,
					&detalhe.Usuario.IdDoUsuario,
					&detalhe.Emprestimo.IdDoEmprestimo,
					&dataHora,
					&detalhe.Acao,
					&detalhe.Detalhe,
				},	
				func () error {
					if dataHora != nil {
						detalhe.DataHora, _ = dataHora.(string)	
					}
					detalhes = append(detalhes, detalhe)
					return nil
				},
		);  erro != nil {
				fmt.Println(erro)
				return []modelos.DetalheEmprestimo{}
		}
		return detalhes
}

func PegarDetalheEmprestimoPorIdDoAluno(idDoAluno int) []modelos.DetalheEmprestimo {
	conexao := PegarConexao();
	detalhes := make([]modelos.DetalheEmprestimo, 0)
	var detalhe modelos.DetalheEmprestimo
	var dataHora interface{}
	rows, _ := conexao.Query(
		context.Background(), `
		select
		id_detalhe_emprestimo,
		usuario,
		emprestimo,
		to_char(data_hora, 'yyyy-mm-dd'),
		acao,
		detalhe
		from detalhe_emprestimo
		where usuario = $1;	`,
		idDoAluno,
	)
	if _, erro := pgx.ForEachRow(
				rows,	
				[]any{
					&detalhe.IdDetalheEmprestimo,
					&detalhe.Usuario.IdDoUsuario,
					&detalhe.Emprestimo.IdDoEmprestimo,
					&dataHora,
					&detalhe.Acao,
					&detalhe.Detalhe,
				},	
				func () error {
					if dataHora != nil {
						detalhe.DataHora, _ = dataHora.(string)	
					}
detalhes = append(detalhes, detalhe)
					return nil
				},
		);  erro != nil {
				fmt.Println(erro)
				return []modelos.DetalheEmprestimo{}
		}
		return detalhes
}
