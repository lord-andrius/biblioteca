package servicos

import (
	"biblioteca/banco"
	"biblioteca/modelos"
	"biblioteca/servicos/sessao"
	"biblioteca/utilidades"
)

type ErroServicoExemplar int

const (
	ErroServicoExemplarNenhum = iota
	ErroServicoExemplarLivroInexistente
	ErroServicoExemplarStatusInvalido
	ErroServicoExemplarEstadoInvalido
	ErroServicoExemplarMudouLivro
	ErroServicoExemplarExemplarInexistente
	ErroServicoExemplarSemPermissao
	ErroServicoExemplarSessaoInvalida
)

func erroBancoExemplarParaErroServicoExemplar(erro banco.ErroBancoExemplar) ErroServicoExemplar {
	switch erro {
	case banco.ErroBancoExemplarLivroInexistente:
		return ErroServicoExemplarLivroInexistente
	case banco.ErroBancoExemplarMudouLivro:
		return ErroServicoExemplarMudouLivro
	default:
		return ErroServicoExemplarNenhum

	}
}

func CriarExemplar(idDaSessao uint64,loginDoUsuarioCriador string,  novoExemplar modelos.ExemplarLivro) (modelos.ExemplarLivro, ErroServicoExemplar) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioCriador) != sessao.VALIDO {
		return modelos.ExemplarLivro{}, ErroServicoExemplarSessaoInvalida
	}
	permissaoDoUsuarioQueEstaCadastrando := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissaoDoUsuarioQueEstaCadastrando & utilidades.PermissaoCriarExemplar != utilidades.PermissaoCriarExemplar {
		return modelos.ExemplarLivro{}, ErroServicoExemplarSemPermissao
	}

	if novoExemplar.Status < modelos.StatusExemplarLivroEmprestado || novoExemplar.Status > modelos.StatusExemplarLivroIndisponivel {
		return modelos.ExemplarLivro{}, ErroServicoExemplarStatusInvalido
	}

	if novoExemplar.Estado < modelos.EstadoExemplarBom || novoExemplar.Estado > modelos.EstadoExemplarDanificado {
		return modelos.ExemplarLivro{}, ErroServicoExemplarEstadoInvalido
	}

	novoExemplar, erro := banco.CadastrarExemplar(novoExemplar)
	return novoExemplar, erroBancoExemplarParaErroServicoExemplar(erro)
}

func PesquisarExemplares(idDaSessao uint64, loginDoUsuarioPesquisador string, exemplar modelos.ExemplarLivro) ([]modelos.ExemplarLivro, ErroServicoExemplar) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioPesquisador) != sessao.VALIDO {
		return []modelos.ExemplarLivro{}, ErroServicoExemplarSessaoInvalida
	}
	return banco.BuscarExemplares(exemplar), ErroServicoExemplarNenhum
}

func AtualizarExemplar(idDaSessao uint64, loginDoUsuarioRequerente string,exemplarComDadosAtualizados modelos.ExemplarLivro) (modelos.ExemplarLivro, ErroServicoExemplar){
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioRequerente) != sessao.VALIDO {
		return modelos.ExemplarLivro{}, ErroServicoExemplarSessaoInvalida
	}
	permissaoDoUsuarioQueEstaAtualizando := sessao.PegarSessaoAtual()[idDaSessao].Permissao	
	if permissaoDoUsuarioQueEstaAtualizando & utilidades.PermissaoAtualizarExemplar != utilidades.PermissaoAtualizarExemplar {
		return modelos.ExemplarLivro{}, ErroServicoExemplarSemPermissao
	}
	if exemplarComDadosAtualizados.Status < modelos.StatusExemplarLivroEmprestado || exemplarComDadosAtualizados.Status > modelos.StatusExemplarLivroIndisponivel {
		return modelos.ExemplarLivro{}, ErroServicoExemplarStatusInvalido
	}

	if exemplarComDadosAtualizados.Estado < modelos.EstadoExemplarBom || exemplarComDadosAtualizados.Estado > modelos.EstadoExemplarDanificado {
		return modelos.ExemplarLivro{}, ErroServicoExemplarEstadoInvalido
	}

	exemplarComDadosAntigos, achou := banco.PegarExemplarPorId(exemplarComDadosAtualizados.IdDoExemplarLivro)
	if (!achou) {
		return	modelos.ExemplarLivro{}, ErroServicoExemplarExemplarInexistente
	}
	exemplarComDadosAtualizados, _ = banco.PegarExemplarPorId(exemplarComDadosAtualizados.IdDoExemplarLivro)
	return exemplarComDadosAtualizados,  erroBancoExemplarParaErroServicoExemplar(banco.AtualizarExemplar(exemplarComDadosAntigos, exemplarComDadosAtualizados))

}

func DeletarExemplar(idDaSessao uint64,loginDoUsuarioRequerente string ,idDoExemplar int) (modelos.ExemplarLivro, ErroServicoExemplar) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioRequerente) != sessao.VALIDO {
		return modelos.ExemplarLivro{}, ErroServicoExemplarSessaoInvalida
	}
	permissaoDoUsuarioQueEstaDeletando := sessao.PegarSessaoAtual()[idDaSessao].Permissao	
	if permissaoDoUsuarioQueEstaDeletando & utilidades.PermissaoDeletarExemplar != utilidades.PermissaoDeletarExemplar {
		return modelos.ExemplarLivro{}, ErroServicoExemplarSemPermissao
	}
	exemplarASerExcluido, achou := banco.PegarExemplarPorId(idDoExemplar)
	if (!achou) {
		return	modelos.ExemplarLivro{}, ErroServicoExemplarExemplarInexistente
	}

	erro := erroBancoExemplarParaErroServicoExemplar(banco.DeletarExemplar(exemplarASerExcluido))
	if erro != ErroServicoExemplarNenhum {
		return modelos.ExemplarLivro{}, erro
	}
	
	exemplarExcluido := exemplarASerExcluido
	exemplarExcluido.Ativo = false 
					  
	return exemplarExcluido, erro
}

func PegarExemplarPeloId(idDoExemplar int) (modelos.ExemplarLivro, bool) {
	return banco.PegarExemplarPorId(idDoExemplar)
}
