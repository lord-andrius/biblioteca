package rotas

import (
	"biblioteca/modelos"
	"biblioteca/servicos"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// Autor gerencia a rota de autor
func Autor(resposta http.ResponseWriter, requisicao *http.Request) {

	body, err := io.ReadAll(requisicao.Body)
	if err != nil {
		http.Error(resposta, "Erro ao ler o corpo da requisição", http.StatusBadRequest)
		return
	}

	var autor modelos.Autor

	switch requisicao.Method {
	case http.MethodGet:

		autores, httpCode, err := servicos.ValidarVisualizarAutores()
		if err != nil {
			http.Error(resposta, fmt.Sprintf("Erro ao tentar usar o servico: %v", err), httpCode)
		}

		resposta.Header().Set("Content-Type", "application/json")
		resposta.WriteHeader(httpCode)

		json.NewEncoder(resposta).Encode(autores)

	case http.MethodPost:

		err = json.Unmarshal(body, &autor)
		if err != nil {
			http.Error(resposta, "Erro ao processar JSON", http.StatusBadRequest)
			return
		}

		httpCode, err := servicos.ValidarCriacaoAutor(autor)
		if err != nil {
			http.Error(resposta, fmt.Sprintf("Erro: %v", err), httpCode)
			return
		}
		resposta.WriteHeader(httpCode)
		fmt.Fprint(resposta, "Autor inserido com sucesso")
	case http.MethodPut:

		err = json.Unmarshal(body, &autor)
		if err != nil {
			http.Error(resposta, "Erro ao processar JSON", http.StatusBadRequest)
			return
		}

		httpCode, err := servicos.ValidarAtualizacaoAutor(autor)
		if err != nil {
			http.Error(resposta, fmt.Sprintf("Erro: %v", err), httpCode)
			return
		}
		resposta.WriteHeader(httpCode)
		fmt.Fprint(resposta, "Autor atualizado com sucesso")
	case http.MethodDelete:

		err = json.Unmarshal(body, &autor)
		if err != nil {
			http.Error(resposta, "Erro ao processar JSON", http.StatusBadRequest)
			return
		}

		httpCode, err := servicos.ValidarExcluicaoAutor(autor)
		if err != nil {
			http.Error(resposta, fmt.Sprintf("Erro: %v", err), httpCode)
			return
		}
		resposta.WriteHeader(httpCode)
		fmt.Fprint(resposta, "Autor Excluído com sucesso")
	default:
		http.Error(resposta, "Erro metódo não permitido", http.StatusMethodNotAllowed)
	}
}
