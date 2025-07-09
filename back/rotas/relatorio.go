package rotas

import (
	servicoRelatorio "biblioteca/servicos/relatorio"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type RequisicaoRelatorio struct {
	IdDaSessao         uint64
	LoginDoUsuario     string
	DominioDoRelatorio string
	Filtros            []map[string]string
}

func erroServicoRelatorioParaErroHttp(erro servicoRelatorio.ErroServicoRelatorio, resposta http.ResponseWriter) {

}

func Relatorio(resposta http.ResponseWriter, requisicao *http.Request) {

	corpoDaRequisicao, erro := io.ReadAll(requisicao.Body)

	if erro != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de Relatório foi mal feita")
		return

	}

	var requisicaoRelatorio RequisicaoRelatorio
	if json.Unmarshal(corpoDaRequisicao, &requisicaoRelatorio) != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de Relatório foi mal feita")
		return
	}

	if len(requisicaoRelatorio.LoginDoUsuario) == 0 {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de Relatório foi mal feita")
		return

	}

	switch requisicao.Method {
	case "GET":
		relatorio, erro := servicoRelatorio.Relatorio(
			requisicaoRelatorio.IdDaSessao,
			requisicaoRelatorio.LoginDoUsuario,
			requisicaoRelatorio.DominioDoRelatorio,
			requisicaoRelatorio.Filtros,
		)
		if erro != servicoRelatorio.ErroServicoRelatorioNenhum {

			erroServicoRelatorioParaErroHttp(erro, resposta)
			return
		}

		resposta.Header().Set("Content-Type", "application/pdf")
		resposta.Header().Set("Content-Disposition", "inline; filename=relatorio_usuarios.pdf")

		resposta.Write(relatorio)

	default:
		resposta.WriteHeader(http.StatusMethodNotAllowed)
		fmt.Fprintf(resposta, "Metódo não permitido")

	}
}
