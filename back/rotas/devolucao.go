package rotas

import (
	"biblioteca/servicos"
	"encoding/json"
	"fmt"
	"net/http"
)

func erroServicoDevolucaoParaErrHttp(erro servicos.ErroServicoDevolucao, resposta http.ResponseWriter) {
	switch erro {
	case servicos.ErroServicoDevolucaoSessaoInvalida:
		http.Error(resposta, "Sessão inválida", http.StatusUnauthorized) // 401
	case servicos.ErroServicoDevolucaoUsuarioSemPermissao:
		http.Error(resposta, "Usuário não possui permissão para executar essa ação", http.StatusForbidden) // 403
	case servicos.ErroServicoDevolucaoExemplarInexistente:
		http.Error(resposta, "Exemplar inexistente", http.StatusNotFound) // 404
	case servicos.ErroServicoDevolucaoEmprestimoInexistente:
		http.Error(resposta, "Emprestimo inexistente", http.StatusNotFound) // 404
	case servicos.ErroServicoDevolucaoEmprestimoPossuiStatusIncompativel:
		http.Error(resposta, "Emprestimo possui status incompatível", http.StatusConflict) // 409
	case servicos.ErroServicoDevolucaoExemplarPossuiStatusIncompativel:
		http.Error(resposta, "Exemplar possui status incompatível", http.StatusConflict) // 409
	case servicos.ErroServicoDevolucaoErroInterno:
		http.Error(resposta, "Erro interno", http.StatusInternalServerError) // 500
	default:
		http.Error(resposta, "Erro desconhecido", http.StatusInternalServerError) // 500 para casos inesperados
	}
}

type requisicaoDevolucao struct {
	IdDaSessao               uint64 `json:"sessao"`
	LoginDoUsuarioRequerente string `json:"login"`
	IdDoEmprestimo           int    `json:"idEmprestimo"`
}

func Devolucao(resposta http.ResponseWriter, requisicao *http.Request) {

	var requisicaoDevolucao requisicaoDevolucao
	if erro := json.NewDecoder(requisicao.Body).Decode(&requisicaoDevolucao); erro != nil {
		http.Error(resposta, "A requisição para a rota de devolução foi mal feita", http.StatusBadRequest)
	}
	switch requisicao.Method {
	case http.MethodGet:
		http.Error(resposta, "Metódo ainda não implementado", http.StatusNotImplemented)
	case http.MethodPost:
		if requisicaoDevolucao.IdDoEmprestimo == 0 {
			http.Error(resposta, "O campo idEmprestimo é um campo obrigatório", http.StatusBadRequest)
			return
		}

		emprestimoResposta, erro := servicos.RealizarDevolucao(
			requisicaoDevolucao.IdDaSessao,
			requisicaoDevolucao.LoginDoUsuarioRequerente,
			int(requisicaoDevolucao.IdDoEmprestimo),
		)
		if erro != servicos.ErroServicoDevolucaoNenhum {
			fmt.Println("erro servico: ", erro)
			erroServicoDevolucaoParaErrHttp(erro, resposta)
			return
		}
		resposta.WriteHeader(http.StatusOK)
		resposta.Header().Set("Content-Type", "application/json")
		json.NewEncoder(resposta).Encode(emprestimoResposta)
	default:
		http.Error(resposta, "Método não permitido", http.StatusMethodNotAllowed)
	}
}
