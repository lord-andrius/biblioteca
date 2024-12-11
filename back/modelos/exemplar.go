package modelos

type StatusExemplarLivro int
type EstadoExemplarLivro int

const (
	StatusModelosLivroEmprestado = iota
	StatusModelosLivroDisponivel
	StatusModelosLivroReservado
)

const (
	EstadoModeloLivroNovo = iota
	EstadoModeloLivroUsado
	EstadoModeloLivroDanificado
)

type ExemplarLivro struct {
	IdDoExemplarLivro int
	Cativo            bool
	Status            StatusExemplarLivro
	Estado            EstadoExemplarLivro
}
