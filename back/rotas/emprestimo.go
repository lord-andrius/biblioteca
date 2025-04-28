package rotas

import (
	"biblioteca/modelos"
	"biblioteca/servicos"
	//servicoUsuario "biblioteca/servicos/usuario"
	"encoding/json"
	"io"
	"net/http"
	"fmt"
)

func erroServicoEmprestimoParaErrHttp(erro servicos.ErroServicoDoEmprestimo, resposta http.ResponseWriter) {
	switch erro {
			case servicos.ErroServicoEmprestimoExemplarNaoEncontrado:
				resposta.WriteHeader(http.StatusNotFound)			
				fmt.Fprintf(resposta, "Exemplar não encontrar")
			case servicos.ErroServicoEmprestimoExemplarEmprestado:
				resposta.WriteHeader(http.StatusBadRequest)
				fmt.Fprintf(resposta, "Exemplar já emprestado")
			case servicos.ErroServicoEmprestimoExemplarIndisponivel:
				resposta.WriteHeader(http.StatusBadRequest)
				fmt.Fprintf(resposta, "Exemplar indisponível")
			case servicos.ErroServicoEmprestimoUsuarioNaoEncontrado:
				resposta.WriteHeader(http.StatusNotFound)
				fmt.Fprintf(resposta, "Usuário nã́o encontrado")
			case servicos.ErroServicoEmprestimoObservacaoInvalida:
				resposta.WriteHeader(http.StatusBadRequest)
				fmt.Fprintf(resposta, "Observação inválida")
			case servicos.ErroServicoEmprestimoSessaoInvalida:
				resposta.WriteHeader(http.StatusUnauthorized)
				fmt.Fprintf(resposta, "Sessão inválida")
			case servicos.ErroServicoEmprestimoUsuarioSemPermissao:
				resposta.WriteHeader(http.StatusForbidden)
				fmt.Fprintf(resposta, "Usuário sem permissão")
	}	
}

type requisicaoEmprestimoPost struct {
	IdDaSessao uint64
	LoginDoUsuario string
	IdDoAluno int
	IdsExemplares []int
}

type requisicaoEmprestimoGet struct {
	IdDaSessao            uint64
	LoginDoUsuario        string
	IdDoEmprestimo        int
	IdDoExemplar          int
	IdDoUsuarioEmprestimo int
	IdDoUsuarioAluno      int
}

type Detalhe struct {
	IdDetalheEmprestimo int
	Usuario modelos.Usuario // Esse usuário é quem faz o empréstimo
	DataHora string
	Acao int
	Detalhe string
	Observacao string

}

type respostaEmprestimo struct {
	modelos.Emprestimo
	Detalhes []Detalhe
}

func requisicaoEmprestimoPostParaEmprestimoEDetalheEmprestimo(r requisicaoEmprestimoPost) ([]modelos.Emprestimo, []modelos.DetalheEmprestimo) {
	emprestimos := make([]modelos.Emprestimo, 0)
	detalhes := make([]modelos.DetalheEmprestimo, 0)
	
	for _, idExemplar := range r.IdsExemplares {
		var emprestimo modelos.Emprestimo
		emprestimo.Exemplar.IdDoExemplarLivro = idExemplar
		emprestimo.Usuario.Login = r.LoginDoUsuario
		var detalheEmprestimo modelos.DetalheEmprestimo
		detalheEmprestimo.Usuario.IdDoUsuario = r.IdDoAluno
		emprestimos = append(emprestimos, emprestimo)	
		detalhes = append(detalhes, detalheEmprestimo)	
	} 
	
	return emprestimos, detalhes
	
}

// NOTA: pensar melhor e ver se tem um algorítimo melhor
func paraRespostaEmprestimo(emprestimos []modelos.Emprestimo, detalhes []modelos.DetalheEmprestimo) []respostaEmprestimo {
	respostas := make([]respostaEmprestimo, 0, len(emprestimos))	
	for	_, emprestimo := range emprestimos {
		var resposta respostaEmprestimo
		resposta.Emprestimo = emprestimo	
		resposta.Detalhes = make([]Detalhe, 0)
		for _, detalhe := range detalhes {
			if detalhe.Emprestimo.IdDoEmprestimo	== emprestimo.IdDoEmprestimo {
				resposta.Detalhes = append(resposta.Detalhes, Detalhe{
					detalhe.IdDetalheEmprestimo,
					detalhe.Usuario,
					detalhe.DataHora,
					detalhe.Acao, 
					detalhe.Detalhe,
					detalhe.Observacao,
				})
			}
		}	
		respostas = append(respostas, resposta)
	}
	return respostas	
}



func Emprestimo(resposta http.ResponseWriter, requisicao *http.Request) {
		corpoDaRequisicao, erro := io.ReadAll(requisicao.Body)

		if  erro != nil {
			resposta.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(resposta, "A requisição para a rota de empréstimo foi mal feita")
			return
		}

		switch requisicao.Method {
			case "POST":
				var requisicaoEmprestimoPost requisicaoEmprestimoPost
				if erro := json.Unmarshal(corpoDaRequisicao, &requisicaoEmprestimoPost); erro != nil {
					resposta.WriteHeader(http.StatusBadRequest)
					fmt.Println(erro)
					fmt.Fprintf(resposta, "A requisição para a rota de empréstimo foi mal feita")	
					return
				}	
				
				if len(requisicaoEmprestimoPost.IdsExemplares) == 0 {
					resposta.WriteHeader(http.StatusBadRequest)
					fmt.Fprintf(resposta, "A requisição para a rota de empréstimo foi mal feita")
					return
				}
				
				emprestimos, detalhes := requisicaoEmprestimoPostParaEmprestimoEDetalheEmprestimo(requisicaoEmprestimoPost)


				emprestimos, detalhes, erro := servicos.CriarEmprestimo(
					requisicaoEmprestimoPost.IdDaSessao,
					requisicaoEmprestimoPost.LoginDoUsuario,
					emprestimos,
					detalhes,
				)

				if erro != servicos.ErroServicoEmprestimoNenhum {
					erroServicoEmprestimoParaErrHttp(erro, resposta) 
					return
				}

				respostaEmprestimo := paraRespostaEmprestimo(emprestimos, detalhes)
				respostaTexto, _ := json.Marshal(&respostaEmprestimo)
				
				fmt.Fprintf(resposta, "%s", respostaTexto)

			case "GET":
				var requisicaoEmprestimoGet requisicaoEmprestimoGet
				if erro := json.Unmarshal(corpoDaRequisicao, &requisicaoEmprestimoGet); erro != nil {
					resposta.WriteHeader(http.StatusBadRequest)
					fmt.Println(erro)
					fmt.Fprintf(resposta, "A requisição para a rota de empréstimo foi mal feita")	
					return
				}	
				
				emprestimos, detalhes, erro := servicos.PesquisarEmprestimo(
					requisicaoEmprestimoGet.IdDaSessao,
					requisicaoEmprestimoGet.LoginDoUsuario,
					requisicaoEmprestimoGet.IdDoEmprestimo,
					requisicaoEmprestimoGet.IdDoExemplar,
					requisicaoEmprestimoGet.IdDoUsuarioEmprestimo,
					requisicaoEmprestimoGet.IdDoUsuarioAluno,
				)

				if erro != servicos.ErroServicoEmprestimoNenhum {
					erroServicoEmprestimoParaErrHttp(erro, resposta) 
					return
				}			
				
				respostaEmprestimo := paraRespostaEmprestimo(emprestimos, detalhes)	
				respostaTexto, _ := json.Marshal(&respostaEmprestimo)
				
				fmt.Fprintf(resposta, "%s", respostaTexto)	
		}
}
