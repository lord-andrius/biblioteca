package modelos

const (
	AcaoDetalheEmprestimoEmprestar = 1
	AcaoDetalheEmprestimoRenovar = 2
	AcaoDetalheEmprestimoDevolver = 3
	
)

func TextoAcaoDetalhe(acaoDetalhe int) string {
	switch acaoDetalhe {
		case AcaoDetalheEmprestimoEmprestar:
			return "Emprestar"
		case AcaoDetalheEmprestimoRenovar:
			return "Renovar"
		default:
			return "Devolver"
	}
}


type DetalheEmprestimo struct {
	IdDetalheEmprestimo int
	Emprestimo Emprestimo
	Usuario Usuario // Esse usuário é quem faz o empréstimo
	DataHora string
	Acao int
  Detalhe string
	Observacao string
}
