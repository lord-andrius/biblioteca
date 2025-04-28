package servicos

import (
	"biblioteca/modelos"
	"biblioteca/banco"
	"biblioteca/servicos/sessao"
	"biblioteca/utilidades"
	"context"
)

// Nota: Refatore para que não tenha dependencias cíclicas entre o pacote de
// servico e o pacote de servicos/usuario

type ErroServicoDoEmprestimo int

const (
	ErroServicoEmprestimoNenhum = iota
	ErroServicoEmprestimoExemplarNaoEncontrado
	ErroServicoEmprestimoExemplarEmprestado
	ErroServicoEmprestimoExemplarIndisponivel
	ErroServicoEmprestimoUsuarioNaoEncontrado
	ErroServicoEmprestimoObservacaoInvalida
	ErroServicoEmprestimoSessaoInvalida
	ErroServicoEmprestimoUsuarioSemPermissao
)

func erroBancoEmprestimoParaErroServico(erro banco.ErroBancoEmprestimo) ErroServicoDoEmprestimo {
	switch erro {
		case banco.ErroBancoEmprestimoExemplarEmprestado:
			return ErroServicoEmprestimoExemplarEmprestado
		case banco.ErroBancoEmprestimoExemplarIndisponivel:
			return ErroServicoEmprestimoExemplarIndisponivel
		default:
			return ErroServicoEmprestimoNenhum	
	}
}

func erroBancoDetalheEmprestimoParaErroServico(erro banco.ErroBancoDetalheEmprestimo) ErroServicoDoEmprestimo {
	switch erro {
		case banco.ErroBancoDetalheEmprestimoObservacaoInvalida:
			return ErroServicoEmprestimoObservacaoInvalida		
		default:
			return ErroServicoEmprestimoNenhum	
	}
}


func CriarEmprestimo(idDaSessao uint64, loginDoUsuario string, emprestimos []modelos.Emprestimo, detalhesEmprestimos []modelos.DetalheEmprestimo) ([]modelos.Emprestimo, []modelos.DetalheEmprestimo, ErroServicoDoEmprestimo) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuario) != sessao.VALIDO	 {
			return []modelos.Emprestimo{}, []modelos.DetalheEmprestimo{}, ErroServicoEmprestimoSessaoInvalida
	}

	permissoesDoUsuario := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissoesDoUsuario & utilidades.PermissaoEmprestarLivro != utilidades.PermissaoEmprestarLivro {
			return []modelos.Emprestimo{}, []modelos.DetalheEmprestimo{}, ErroServicoEmprestimoUsuarioSemPermissao
	}

	transacao, _ := banco.CriarTransacao()
	defer func () {
		if transacao.Commit(context.Background()) != nil {
			transacao.Rollback(context.Background())
		}
	}()
	
	for indice, emprestimo := range emprestimos {
		exemplar, achou := banco.PegarExemplarPorId(emprestimo.Exemplar.IdDoExemplarLivro);

		if !achou {
			return []modelos.Emprestimo{}, []modelos.DetalheEmprestimo{}, ErroServicoEmprestimoUsuarioNaoEncontrado
		}

		usuario, deu_erro := banco.PesquisarUsuarioPeloLogin(emprestimo.Usuario.Login);		
		if deu_erro {
			return []modelos.Emprestimo{}, []modelos.DetalheEmprestimo{}, ErroServicoEmprestimoUsuarioNaoEncontrado
		}

		emprestimos[indice].Usuario = usuario
		emprestimos[indice].Exemplar = exemplar
	}		

	if erro := banco.CadastroEmprestimo(transacao, emprestimos); erro != banco.ErroBancoEmprestimoNenhum {
			return []modelos.Emprestimo{}, []modelos.DetalheEmprestimo{}, erroBancoEmprestimoParaErroServico(erro)
		}


	// essa pesquisa por usuário é retardada pois todos os empréstimos 
	// são pro mesmo aluno
	// por favor suma com isso quando tiver tempo

	for indice, detalhe := range detalhesEmprestimos {
		usuario, achou := banco.PegarUsuarioPeloId(detalhe.Usuario.IdDoUsuario);		
		if !achou {
			return []modelos.Emprestimo{}, []modelos.DetalheEmprestimo{}, ErroServicoEmprestimoUsuarioNaoEncontrado
		}
		detalhesEmprestimos[indice].Usuario = usuario	
		detalhesEmprestimos[indice].Acao = modelos.AcaoDetalheEmprestimoEmprestar	
		detalhesEmprestimos[indice].Emprestimo = emprestimos[indice]
	}

		if erro := banco.CadastroDetalheEmprestimo(transacao, detalhesEmprestimos); erro != banco.ErroBancoDetalheEmprestimoNenhum {
		return []modelos.Emprestimo{}, []modelos.DetalheEmprestimo{}, erroBancoDetalheEmprestimoParaErroServico(erro)
	}
			
	return emprestimos, detalhesEmprestimos, ErroServicoEmprestimoNenhum	
}

func PesquisarEmprestimo(idDaSessao uint64, loginDoUsuario string, idDoEmprestimo, idDoExemplar, idDoUsuarioEmprestimo, idDoUsuarioAluno int) ([]modelos.Emprestimo, []modelos.DetalheEmprestimo, ErroServicoDoEmprestimo){
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuario) != sessao.VALIDO {
		return []modelos.Emprestimo{}, []modelos.DetalheEmprestimo{}, ErroServicoEmprestimoSessaoInvalida 
	}	

	permissoesDoUsuario := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissoesDoUsuario & utilidades.PermissaoEmprestarLivro != utilidades.PermissaoEmprestarLivro {
		return []modelos.Emprestimo{}, []modelos.DetalheEmprestimo{}, ErroServicoEmprestimoUsuarioSemPermissao
	}

	emprestimos := banco.PesquisarEmprestimo(idDoEmprestimo, idDoExemplar, idDoUsuarioEmprestimo, idDoUsuarioAluno)

	detalhes := make([]modelos.DetalheEmprestimo, 0)

	for indice, emprestimo := range emprestimos {
		usuarioEmprestimo, _ := banco.PegarUsuarioPeloId(emprestimo.Usuario.IdDoUsuario)
		emprestimos[indice].Usuario = usuarioEmprestimo
		exemplarEmprestimo, _ := PegarExemplarPeloId(emprestimo.Exemplar.IdDoExemplarLivro)
		emprestimos[indice].Exemplar = exemplarEmprestimo
		detalhes = append(detalhes, banco.PegarDetalheEmprestimoPorIdDoEmprestimo(emprestimo.IdDoEmprestimo)...)  
	}

	for indice, detalhe := range detalhes {
		usuarioDetalhe, _ := banco.PegarUsuarioPeloId(detalhe.Usuario.IdDoUsuario)
		TurmaUsuarioDetalhe, _ := PegarTurmaPorId(usuarioDetalhe.Turma.IdTurma)
		usuarioDetalhe.Turma = TurmaUsuarioDetalhe
		detalhes[indice].Usuario = usuarioDetalhe
	}

	return emprestimos, detalhes, ErroServicoEmprestimoNenhum
	
}
