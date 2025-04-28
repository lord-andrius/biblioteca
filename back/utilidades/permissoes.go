package utilidades

const (
	PermissaoCriarUsuario       = 0b1
	PermssaoLerUsuario          = 0b10
	PermissaoAtualizarUsuario   = 0b100
	PermissaoDeletarUsuario     = 0b1000
	PermissaoCriarLivro         = 0b10000
	PermissaoAtualizarLivro     = 0b100000
	PermissaoDeletarLivro       = 0b1000000
	PermissaoCriarExemplar      = 0b10000000
	PermissaoAtualizarExemplar  = 0b100000000
	PermissaoDeletarExemplar    = 0b1000000000
	PermissaoPais               = 0b10000000000
	PermissaoCriarCategoria     = 0b100000000000
	PermissaoAtualizarCategoria = 0b1000000000000
	PermissaoDeletarCategoria   = 0b10000000000000
	PermissaoEmprestarLivro     = 0b10000000000000

	PermissaoCrudUsuario = PermissaoDeletarUsuario | PermissaoAtualizarUsuario | PermssaoLerUsuario | PermissaoCriarUsuario
)
