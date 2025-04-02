package servicos

import (
	"biblioteca/banco"
	"biblioteca/modelos"
	"biblioteca/servicos/sessao"
	"biblioteca/utilidades"
)

type ErroServicoDevolucao int

const (
	ErroServicoDevolucaoNenhum ErroServicoDevolucao = iota
	ErroServicoDevolucaoSessaoInvalida
	ErroServicoDevolucaoUsuarioSemPermissao
	ErroServicoDevolucaoExemplarInexistente
	ErroServicoDevolucaoPossuiStatusIncompativel
	ErroServicoDevolucaoErroInterno
)

// func erroBancoDevolucaoParaErroServicoDevolucao(erro banco.ErroBancoExemplar) ErroServicoDevolucao {
// 	switch erro {
// 	case banco.ErroBancoDevolucaoSessaoInvalida:
// 		return ErroServicoDevolucaoSessaoInvalida
// 	case banco.ErroBancoDevolucaoUsuarioSemPermissao:
// 		return ErroServicoDevolucaoUsuarioSemPermissao
// 	case banco.ErroBancoDevolucaoExemplarInexistente:
// 		return ErroServicoDevolucaoExemplarInexistente
// 	case banco.ErroBancoDevolucaoPossuiStatusIncompativel:
// 		return ErroServicoDevolucaoPossuiStatusIncompativel
// 	case banco.ErroBancoDevolucaoErroInterno:
// 		return ErroServicoDevolucaoErroInterno
// 	default:
// 		return ErroServicoDevolucaoNenhum
// 	}
// }

func RealizarDevolucao(idDaSessao uint64, loginDoUsuarioRequerente string, idExemplarLivro modelos.ExemplarLivro) (modelos.ExemplarLivro, ErroServicoDevolucao) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioRequerente) != sessao.VALIDO {
		return modelos.ExemplarLivro{}, ErroServicoDevolucaoSessaoInvalida
	}
	permissaoDoUsuarioQueEstaAtualizando := sessao.PegarSessaoAtual()[idDaSessao].Permissao
	if permissaoDoUsuarioQueEstaAtualizando&utilidades.PermissaoAtualizarExemplar != utilidades.PermissaoAtualizarExemplar {
		return modelos.ExemplarLivro{}, ErroServicoDevolucaoUsuarioSemPermissao
	}

	exemplarLivro, achou := banco.PegarExemplarPorId(idExemplarLivro.IdDoExemplarLivro)
	if !achou || exemplarLivro.IdDoExemplarLivro == 0 {
		return modelos.ExemplarLivro{}, ErroServicoDevolucaoExemplarInexistente
	}

	if exemplarLivro.Status != modelos.StatusExemplarLivroEmprestado {
		return modelos.ExemplarLivro{}, ErroServicoExemplarStatusInvalido
	}
}
