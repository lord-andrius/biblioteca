package modelos

type RelatorioAutor struct {
	IDDoAtuor     string
	Nome          string
	AnoNascimento string
	Nacionalidade string
	Sexo          string
}

type RelatorioCategoria struct {
	IdDaCategoria string
	Descricao     string
	Ativo         string
}

type RelatorioDetalheEmprestimo struct {
}

type RelatorioEmprestimo struct {
	IdDoEmprestimo        string
	IdDoExemplar          string
	Livro                 string
	ISBN                  string
	Usuario               string
	NumRenovacoes         string
	DataPrevistaDevolucao string
	Status                string
}

type RelatorioExemplar struct {
	IDDoExemplarLivro string
	ISBN              string
	Titulo            string
	Cativo            string
	Status            string
	Estado            string
}

type RelatorioLivro struct {
	IDDoLivro     string
	ISBN          string
	Titulo        string
	AnoPublicacao string
	Editora       string
	Pais          string
	Autor         string
	Categoria     string
	Subcategoria  string
}

type RelatorioPais struct {
	IdDoPais string
	Nome     string
	Sigla    string
	Ativo    string
}

type RelatorioSerie struct {
	IdDaSerie string
	Descricao string
}

type RelatorioSubcategoria struct {
	IdDaCategoria string
	Descricao     string
	Ativo         string
}

type RelatorioTurma struct {
	IdDaTurma string
	Turma     string
	Serie     string
	Turno     string
}

type RelatorioTurno struct {
	IdDoTurno string
	Descricao string
}

type RelatorioUsuario struct {
	IdDoUsuario    string
	Login          string
	CPF            string
	Nome           string
	Email          string
	Telefone       string
	DataNascimento string
	Turma          string
	Ativo          string
}
