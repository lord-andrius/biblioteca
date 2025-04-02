package servicos

import (
	"biblioteca/banco"
	"biblioteca/modelos"
	"biblioteca/servicos/sessao"
	"biblioteca/utilidades"
	"fmt"
)

type ErroDeServicoDaCategoria int

const (
	ErroDeServicoDaCategoriaNenhum = iota
	ErroDeServicoDaCategoriaDescricaoDuplicada
	ErroDeServicoDaCategoriaInexistente
	ErroDeServicoDaCategoriaExcutarCriacao
	ErroDeServicoDaCategoriaExcutarAtualizacao
	ErroDeServicoDaCategoriaExcutarExclusao
	ErroDeServicoDaCategoriaSessaoInvalida
	ErroDeServicoDaCategoriaSemPermisao
	ErroDeServicoDaCategoriaFalhaNaBusca
)

func erroDoBancoParaErroDeServicoDaCategoria(erro banco.ErroBancoCategoria) ErroDeServicoDaCategoria {
	switch erro {
	case banco.CategoriaErroNenhum:
		return ErroDeServicoDaCategoriaNenhum
	case banco.ErroCategoriaDescricaoDuplicada:
		return ErroDeServicoDaCategoriaDescricaoDuplicada
	case banco.ErroCategoriaInexistente:
		return ErroDeServicoDaCategoriaInexistente
	case banco.ErroCategoriaExecutarCriacao:
		return ErroDeServicoDaCategoriaExcutarCriacao
	case banco.ErroCategoriaExecutarAtualizacao:
		return ErroDeServicoDaCategoriaExcutarAtualizacao
	case banco.ErroCategoriaExecutarExclusao:
		return ErroDeServicoDaCategoriaExcutarExclusao
	default:
		return ErroDeServicoDaCategoriaNenhum
	}
}

func CriarCategoria(idDaSessao uint64, loginUsuarioCriador string, novaCategoria modelos.Categoria) ErroDeServicoDaCategoria {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginUsuarioCriador) != sessao.VALIDO {
		return ErroDeServicoDaCategoriaSessaoInvalida
	}

	permissaoDoUsuarioCriador := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissaoDoUsuarioCriador&utilidades.PermissaoCriarUsuario != utilidades.PermissaoCriarUsuario {
		return ErroDeServicoDaCategoriaSemPermisao
	}

	idCategoriaComAMesmaDescricao := PegarIdCategoria(novaCategoria.Descricao)

	if idCategoriaComAMesmaDescricao != 0 {
		return ErroDeServicoDaCategoriaDescricaoDuplicada
	}

	return erroDoBancoParaErroDeServicoDaCategoria(banco.CriarCategoria(novaCategoria))
}

func BuscarCategoria(idDaSessao uint64, loginDoUsuarioBuscador string, textoDaBusca string) ([]modelos.Categoria, ErroDeServicoDaCategoria) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioBuscador) != sessao.VALIDO {
		return nil, ErroDeServicoDaCategoriaSessaoInvalida
	}

	permissaoDoUsuarioBuscador := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissaoDoUsuarioBuscador&utilidades.PermssaoLerUsuario != utilidades.PermssaoLerUsuario {
		return nil, ErroDeServicoDaCategoriaSemPermisao
	}

	if textoDaBusca == "" {
		categorias := banco.PegarTodasCategorias()
		return categorias, ErroDeServicoDaCategoriaNenhum
	}

	categoriasEncontrados := banco.PesquisarCategoria(textoDaBusca)

	return categoriasEncontrados, ErroDeServicoDaCategoriaNenhum
}

func AtualizarCategoria(idDaSessao uint64, loginDoUsuarioRequerente string, categoriaComDadosAtualizados modelos.Categoria) (modelos.Categoria, ErroDeServicoDaCategoria) {

	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioRequerente) != sessao.VALIDO {
		return categoriaComDadosAtualizados, ErroDeServicoDaCategoriaSessaoInvalida
	}

	permissaoDoUsuarioRequerente := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissaoDoUsuarioRequerente&utilidades.PermissaoAtualizarUsuario != utilidades.PermissaoAtualizarUsuario {
		return categoriaComDadosAtualizados, ErroDeServicoDaCategoriaSemPermisao
	}

	_, achou := PegarCategoriaPeloId(categoriaComDadosAtualizados.IdDaCategoria)

	if !achou {
		return categoriaComDadosAtualizados, ErroDeServicoDaCategoriaInexistente
	}

	idCategoriaComAMesmaDescricao := PegarIdCategoria(categoriaComDadosAtualizados.Descricao)

	fmt.Println(idCategoriaComAMesmaDescricao)

	// Caso idCategoriaComAMesmaDescricao seja igual a 0 significa que não existem registros cadastrados
	if idCategoriaComAMesmaDescricao != 0 && idCategoriaComAMesmaDescricao != categoriaComDadosAtualizados.IdDaCategoria {
		return categoriaComDadosAtualizados, ErroDeServicoDaCategoriaDescricaoDuplicada
	}

	return categoriaComDadosAtualizados, erroDoBancoParaErroDeServicoDaCategoria(banco.AtualizarCategoria(categoriaComDadosAtualizados))
}

func DeletarCategoria(idDaSessao uint64, loginDoUsuarioRequerente string, idDaCategoriaQueDesejaExcluir uint64) ErroDeServicoDaCategoria {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioRequerente) != sessao.VALIDO {
		return ErroDeServicoDaCategoriaSessaoInvalida
	}

	permissaoDoUsuarioRequerente := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissaoDoUsuarioRequerente&utilidades.PermissaoDeletarUsuario != utilidades.PermissaoDeletarUsuario {
		return ErroDeServicoDaCategoriaSemPermisao
	}

	_, achou := PegarCategoriaPeloId(idDaCategoriaQueDesejaExcluir)

	if !achou {
		return ErroDeServicoDaCategoriaInexistente
	}

	return erroDoBancoParaErroDeServicoDaCategoria(banco.ExcluirCategoria(idDaCategoriaQueDesejaExcluir))
}

func PegarIdCategoria(descricao string) uint64 {
	return banco.PegarIdCategoria(descricao)
}

func PegarCategoriaPeloId(id uint64) (modelos.Categoria, bool) {
	return banco.PegarCategoriaPeloId(id)
}
