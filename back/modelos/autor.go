package modelos

// Autor é uma struct que representa a tabela autor do banco de dados, possui os mesmo campos
type Autor struct {
	ID              int    `json:"id"`
	Nome            string `json:"nome"`
	Nacionalidade   uint8  `json:"nacionalidade"`
	Sexo            string `json:"sexo"`
	DataCriacao     string `json:"data_criacao"`
	DataAtualizacao string `json:"data_atualizacao"`
}

// AutorResposta é o retorno dos dados armazenados no banco referente ao autor, é utilizado para exibir informações formatadas para o usuário da api
type AutorResposta struct {
	ID                  int     `json:"id"`
	Nome                string  `json:"nome"`
	Nacionalidade       *string `json:"Nacionalidade,omitempty"`
	NacionalidadeCodigo *uint8  `json:"nacionalidade_codigo,omitempty"`
	Sexo                *string `json:"sexo,omitempty"`
	SexoCodigo          *string `json:"sexo_codigo,omitempty"`
}
