package servicos

import (
	"biblioteca/banco"
	"biblioteca/modelos"
	"biblioteca/servicos/sessao"
	"biblioteca/utilidades"
	"fmt"
	"time"
)

type ErroServicoDevolucao int

const (
	ErroServicoDevolucaoNenhum ErroServicoDevolucao = iota
	ErroServicoDevolucaoSessaoInvalida
	ErroServicoDevolucaoUsuarioSemPermissao
	ErroServicoDevolucaoEmprestimoInexistente
	ErroServicoDevolucaoExemplarInexistente
	ErroServicoDevolucaoEmprestimoPossuiStatusIncompativel
	ErroServicoDevolucaoExemplarPossuiStatusIncompativel
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

func RealizarDevolucao(idDaSessao uint64, loginDoUsuarioRequerente string, idEmprestimo int) (modelos.Emprestimo, ErroServicoDevolucao) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioRequerente) != sessao.VALIDO {
		fmt.Println("Erro na sessão")
		return modelos.Emprestimo{}, ErroServicoDevolucaoSessaoInvalida
	}
	permissaoDoUsuarioQueEstaAtualizando := sessao.PegarSessaoAtual()[idDaSessao].Permissao
	if permissaoDoUsuarioQueEstaAtualizando&utilidades.PermissaoAtualizarExemplar != utilidades.PermissaoAtualizarExemplar {
		fmt.Println("Erro na usuário")
		return modelos.Emprestimo{}, ErroServicoDevolucaoUsuarioSemPermissao
	}

	emprestimo, erro := banco.PegarEmprestimoPorId(idEmprestimo)
	if erro != nil {
		fmt.Println("Erro na emprestimo")
		return modelos.Emprestimo{}, ErroServicoDevolucaoEmprestimoInexistente
	}

	fmt.Println("Emprestimo:", emprestimo)

	if emprestimo.Status != modelos.StatusEmprestimoEmAndamento {
		fmt.Println("Erro status emprestimo")
		return modelos.Emprestimo{}, ErroServicoDevolucaoEmprestimoPossuiStatusIncompativel
	}

	dataDeEntregaPrevistaConvertida, erro := time.Parse("2006-01-02", emprestimo.DataDeEntregaPrevista)
	if erro != nil {
		fmt.Println("Erro na converter data: ", erro)
		return modelos.Emprestimo{}, ErroServicoDevolucaoErroInterno
	}

	if dataDeEntregaPrevistaConvertida.After(time.Now()) {
		emprestimo.Status = modelos.StatusEmprestimoEntregueComAtraso
	} else {
		emprestimo.Status = modelos.StatusEmprestimoConcluido
	}

	fmt.Println("id Emprestimo:", emprestimo.Exemplar.IdDoExemplarLivro)

	exemplarLivro, achou := banco.PegarExemplarPorId(emprestimo.Exemplar.IdDoExemplarLivro)

	if !achou || exemplarLivro.IdDoExemplarLivro == 0 {
		fmt.Println("Erro não achou exemplar", !achou, exemplarLivro.IdDoExemplarLivro)
		return modelos.Emprestimo{}, ErroServicoDevolucaoExemplarInexistente
	}

	if exemplarLivro.Status != modelos.StatusExemplarLivroEmprestado {
		fmt.Println("Erro status exemplar")
		return modelos.Emprestimo{}, ErroServicoDevolucaoExemplarPossuiStatusIncompativel
	}

	transacao, erro := banco.CriarTransacao()
	if erro != nil {
		fmt.Println("Erro criar transacao")
		return modelos.Emprestimo{}, ErroServicoDevolucaoErroInterno
	}

	if erro := banco.AtualizarStatusExemplarPorIdTransacao(
		transacao,
		emprestimo.Exemplar.IdDoExemplarLivro,
		modelos.StatusExemplarLivroDisponivel,
	); erro != nil {
		fmt.Println("Erro ataulizar status")
		return modelos.Emprestimo{}, ErroServicoDevolucaoErroInterno
	}

	if erro := banco.AtualizarEmprestimo(
		transacao,
		emprestimo,
	); erro != nil {
		fmt.Println("Erro atualizar emprestimo")
		return modelos.Emprestimo{}, ErroServicoDevolucaoErroInterno
	}

	return emprestimo, ErroServicoDevolucaoNenhum
}
