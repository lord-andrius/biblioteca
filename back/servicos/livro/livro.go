package livro

import (
	"biblioteca/banco"
	"biblioteca/modelos"
	"biblioteca/servicos/sessao"
	"biblioteca/utilidades"
	"fmt"
	"time"
)

type ErroDeServicoDoLivro int

const (
	ErroDeServicoDoLivroNenhum = iota
	ErroDeServicoDoLivroIsbnDuplicado
	ErroDeServicoDoLivroErroDesconhecido
	ErroDeServicoDoLivroIsbnInvalido
	ErroDeServicoDoLivroSemPermisao
	ErroDeServicoDoLivroSessaoInvalida
	ErroDeServicoDoLivroAnoPublicaoInvalida
	ErroDeServicoDoLivroFalhaNaBusca
	ErroDeServicoDoLivroLivroInexistente
)

func erroDoBancoParaErroDeServicoDoLivro(erro banco.ErroBancoLivro) ErroDeServicoDoLivro {
	switch erro {
	case banco.ErroIsbnDuplicado:
		return ErroDeServicoDoLivroIsbnDuplicado
	default:
		return ErroDeServicoDoLivroNenhum
	}
}

func CriarLivro(idDaSessao uint64, loginUsuarioCriador string, novoLivro modelos.Livro, nomeDosAutores []string) ErroDeServicoDoLivro {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginUsuarioCriador) != sessao.VALIDO {
		return ErroDeServicoDoLivroSessaoInvalida
	}

	permissaoDoUsuarioCriador := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissaoDoUsuarioCriador&utilidades.PermissaoCriarUsuario != utilidades.PermissaoCriarUsuario {
		return ErroDeServicoDoLivroSemPermisao
	}

	if _, erro := time.Parse(time.DateOnly, novoLivro.AnoPublicao); erro != nil {
		return ErroDeServicoDoLivroAnoPublicaoInvalida
	}

	if !utilidades.ValidarISBN(novoLivro.Isbn) {
		return ErroDeServicoDoLivroIsbnInvalido
	}

	return erroDoBancoParaErroDeServicoDoLivro(banco.CriarLivro(novoLivro, nomeDosAutores))
}

func BuscarLivro(idDaSessao uint64, loginDoUsuarioBuscador string, textoDaBusca string) ([]modelos.Livro, ErroDeServicoDoLivro) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioBuscador) != sessao.VALIDO {
		return nil, ErroDeServicoDoLivroSessaoInvalida
	}

	permissaoDoUsuarioBuscador := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	fmt.Println(textoDaBusca)
	if textoDaBusca == "" {
		livros := banco.PegarTodosLivros()
		return livros, ErroDeServicoDoLivroNenhum
	}

	if permissaoDoUsuarioBuscador&utilidades.PermssaoLerUsuario != utilidades.PermssaoLerUsuario {
		return nil, ErroDeServicoDoLivroSemPermisao
	}

	livrosEncontrados := banco.PesquisarLivro(textoDaBusca)

	return livrosEncontrados, ErroDeServicoDoLivroNenhum
}

func AtualizarLivro(idDaSessao uint64, loginDoUsuarioRequerente string, livroComDadosAtualizados modelos.Livro, nomeDosAutores []string) (modelos.Livro, ErroDeServicoDoLivro) {

	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioRequerente) != sessao.VALIDO {
		return livroComDadosAtualizados, ErroDeServicoDoLivroSessaoInvalida
	}

	permissaoDoUsuarioRequerente := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	livroComDadosAntigos, achou := banco.PegarLivroPeloId(livroComDadosAtualizados.IdDoLivro)
	if !achou {
		return livroComDadosAtualizados, ErroDeServicoDoLivroLivroInexistente
	}

	if permissaoDoUsuarioRequerente&utilidades.PermissaoAtualizarUsuario != utilidades.PermissaoAtualizarUsuario {
		return livroComDadosAtualizados, ErroDeServicoDoLivroSemPermisao
	}

	if _, erro := time.Parse(time.DateOnly, livroComDadosAtualizados.AnoPublicao); erro != nil {
		return livroComDadosAtualizados, ErroDeServicoDoLivroAnoPublicaoInvalida
	}

	if !utilidades.ValidarISBN(livroComDadosAtualizados.Isbn) {
		return livroComDadosAtualizados, ErroDeServicoDoLivroIsbnInvalido
	}

	return livroComDadosAtualizados, erroDoBancoParaErroDeServicoDoLivro(banco.AtualizarLivro(livroComDadosAntigos, livroComDadosAtualizados, nomeDosAutores))
}

func DeletarLivro(idDaSessao uint64, loginDoUsuarioRequerente string, idDoLivroQueDesejaExcluir int) ErroDeServicoDoLivro {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioRequerente) != sessao.VALIDO {
		return ErroDeServicoDoLivroSessaoInvalida
	}

	permissaoDoUsuarioRequerente := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissaoDoUsuarioRequerente&utilidades.PermissaoDeletarUsuario != utilidades.PermissaoDeletarUsuario {
		return ErroDeServicoDoLivroSemPermisao
	}

	return erroDoBancoParaErroDeServicoDoLivro(banco.ExcluirLivro(idDoLivroQueDesejaExcluir))
}

func PegarIdLivro(isbn string) int {
	return banco.PegarIdLivro(isbn)
}

func PegarLivroPeloId(id int) (modelos.Livro, bool) {
	return banco.PegarLivroPeloId(id)
}
