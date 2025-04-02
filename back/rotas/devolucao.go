package rotas

import (
	"biblioteca/servicos"
	"encoding/json"
	"net/http"
)

type requisicaoDevolucao struct {
	IdDaSessao               uint64 `json:"sessao"`
	LoginDoUsuarioRequerente string `json:"login"`
	IdDoExemplarLivro        uint64 `json:"id_exemplar_livro"`
}

func Devolucao(resposta http.ResponseWriter, requisicao *http.Request) {

	var requisicaoDevolucao requisicaoExemplar
	if erro := json.NewDecoder(requisicao.Body).Decode(&requisicaoDevolucao); erro != nil {
		http.Error(resposta, "A requisição para a rota de devolução foi mal feita", http.StatusBadRequest)
	}
	switch requisicao.Method {
	case http.MethodGet:
	case http.MethodPost:
		if requisicaoDevolucao.IdDoExemplarLivro == 0 {
			http.Error(resposta, "O campo id_exemplar_livro é um campo obrigatório", http.StatusBadRequest)
			return
		}

		exemplarLivroDevolucao, erro := servicos.RealizarDevolucao(requisicaoDevolucao.IdDaSessao, requisicaoDevolucao.LoginDoUsuarioRequerente, requisicaoDevolucao.IdDoExemplarLivro)
		if erro != nil {
			switch erro {
			case servicos.ErroDevolucaoUsuarioSemPermissao:
				http.Error(resposta, "Usuário sem permissão", http.StatusUnauthorized)
			case servicos.ErroDevolucaoExeplarLivroNaoExiste:
				http.Error(resposta, "O exemplar do livro não existe", http.StatusNotFound)
			case servicos.ErroDevolucaoPossuiStatusIncompativel:
				http.Error(resposta, "O exemplar do livro possui status incompatível", http.StatusConflict)
			}
		}
		resposta.WriteHeader(http.StatusOK)
		resposta.Header().Set("Content-Type", "application/json")
		json.NewEncoder(resposta).Encode(exemplarLivroDevolucao)
	default:
		http.Error(resposta, "Método não permitido", http.StatusMethodNotAllowed)
	}
}
