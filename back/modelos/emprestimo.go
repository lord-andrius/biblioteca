package modelos

const (
	StatusEmprestimoEmAndamento = 1
  StatusEmprestimoEntregueComAtraso = 2
  StatusEmprestimoConcluido = 3
)


type Emprestimo struct {
	IdDoEmprestimo        int
	Exemplar              ExemplarLivro
	Usuario               Usuario // Esse usuário é o usuario requerente
	DataEmprestimo        string
	NumeroRenovacoes      int
  DataDeEntregaPrevista string
	DataDeDevolucao       string
	Status                int
}
