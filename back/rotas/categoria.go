package rotas

import (
	"biblioteca/modelos"
	"biblioteca/servicos"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type requisicaoCategoria struct {
	IdDaSessao               uint64 `validate:"required"`
	LoginDoUsuarioRequerente string `validate:"required"`
	Id                       uint64 `validate:"optional"`
	Descricao                string `validate:"optional"`
	TextoDeBusca             string `validate:"optional"`
}

type respostaCategoria struct {
	CategoriasAtingidas []modelos.Categoria
}

func erroServicoCategoriaParaErrHttp(erro servicos.ErroDeServicoDaCategoria, resposta http.ResponseWriter) {
	switch erro {

	case servicos.ErroDeServicoDaCategoriaDescricaoDuplicada:
		resposta.WriteHeader(http.StatusConflict)
		fmt.Fprintf(resposta, "A descrição informada já existe na base de dados")
		return
	case servicos.ErroDeServicoDaCategoriaInexistente:
		resposta.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(resposta, "A categória requisitada não existe")
		return
	case servicos.ErroDeServicoDaCategoriaExcutarCriacao:
		resposta.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(resposta, "Aconteceu algum erro na ação de criação na base de dados")
		return
	case servicos.ErroDeServicoDaCategoriaExcutarAtualizacao:
		resposta.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(resposta, "Aconteceu algum erro na ação de atualização na base de dados")
		return
	case servicos.ErroDeServicoDaCategoriaExcutarExclusao:
		resposta.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(resposta, "Aconteceu algum erro na ação de exclusão na base de dados")
		return
	case servicos.ErroDeServicoDaCategoriaSessaoInvalida:
		resposta.WriteHeader(http.StatusUnauthorized)
		fmt.Fprintf(resposta, "Sessão inválida")
		return
	case servicos.ErroDeServicoDaCategoriaSemPermisao:
		resposta.WriteHeader(http.StatusUnauthorized)
		fmt.Fprintf(resposta, "Usuário não possui permissão para executar essa ação")
		return
	case servicos.ErroDeServicoDaCategoriaFalhaNaBusca:
		resposta.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(resposta, "Aconteceu algum erro na ação de buscar os dados de categoria na base de dados")
		return
	default:
		resposta.WriteHeader(http.StatusOK)
		fmt.Fprintf(resposta, "Ação realizada com sucesso")
		return
	}
}

func Categoria(resposta http.ResponseWriter, requisicao *http.Request) {

	corpoDaRequisicao, erro := io.ReadAll(requisicao.Body)

	if erro != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de categoria foi mal feita")
		return
	}

	var requisicaoCategoria requisicaoCategoria
	if json.Unmarshal(corpoDaRequisicao, &requisicaoCategoria) != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de categoria foi mal feita")
		return
	}

	if requisicaoCategoria.LoginDoUsuarioRequerente == "" {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de categoria foi mal feita")
		return
	}

	switch requisicao.Method {
	case "POST":
		if len(requisicaoCategoria.Descricao) < 1 {
			resposta.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(resposta, "Algum campo necessário para o cadastro não foi fornecido")
			return
		}

		var novaCategoria modelos.Categoria
		novaCategoria.Descricao = requisicaoCategoria.Descricao

		erro := servicos.CriarCategoria(requisicaoCategoria.IdDaSessao, requisicaoCategoria.LoginDoUsuarioRequerente, novaCategoria)

		if erro != servicos.ErroDeServicoDaCategoriaNenhum {
			erroServicoCategoriaParaErrHttp(erro, resposta)
			return
		}

		novaCategoria.IdDaCategoria = servicos.PegarIdCategoria(novaCategoria.Descricao)

		respostaCategoria := respostaCategoria{
			[]modelos.Categoria{
				novaCategoria,
			},
		}

		respostaCategoriaJson, _ := json.Marshal(&respostaCategoria)

		fmt.Fprintf(resposta, "%s", respostaCategoriaJson)

		return
	case "GET":
		categoriasEncontradas, erro := servicos.BuscarCategoria(requisicaoCategoria.IdDaSessao, requisicaoCategoria.LoginDoUsuarioRequerente, requisicaoCategoria.TextoDeBusca)
		if erro == servicos.ErroDeServicoDaCategoriaSemPermisao {
			resposta.WriteHeader(http.StatusForbidden)
			fmt.Fprintf(resposta, "Este usuário não tem permissão para essa operação")
			return
		} else if erro == servicos.ErroDeServicoDaCategoriaFalhaNaBusca {
			resposta.WriteHeader(http.StatusInternalServerError)
			fmt.Fprint(resposta, "Houve um erro interno enquanto se fazia a busca! Provavelmente é um bug na api!")
			return
		}
		respostaCategoria := respostaCategoria{
			categoriasEncontradas,
		}
		respostaCategoriaJson, _ := json.Marshal(&respostaCategoria)

		fmt.Fprintf(resposta, "%s", respostaCategoriaJson)

	case "PUT":
		if len(requisicaoCategoria.Descricao) < 1 {
			resposta.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(resposta, "Algum campo necessário para o cadastro não foi fornecido")
			return
		}

		var categoriaComDadosAtualizados modelos.Categoria
		categoriaComDadosAtualizados.IdDaCategoria = requisicaoCategoria.Id
		categoriaComDadosAtualizados.Descricao = requisicaoCategoria.Descricao

		categoriaAtualizado, erro := servicos.AtualizarCategoria(requisicaoCategoria.IdDaSessao, requisicaoCategoria.LoginDoUsuarioRequerente, categoriaComDadosAtualizados)

		if erro != servicos.ErroDeServicoDaCategoriaNenhum {
			erroServicoCategoriaParaErrHttp(erro, resposta)
			return
		}

		respostaCategoria := respostaCategoria{
			[]modelos.Categoria{
				categoriaAtualizado,
			},
		}
		respostaCategoriaJson, _ := json.Marshal(&respostaCategoria)

		fmt.Fprintf(resposta, "%s", respostaCategoriaJson)

	case "DELETE":
		if requisicaoCategoria.Id == 0 {
			resposta.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(resposta, "É necessário informar o Id da categoria que deseja excluir")
			return
		}

		if erro := servicos.DeletarCategoria(requisicaoCategoria.IdDaSessao, requisicaoCategoria.LoginDoUsuarioRequerente, requisicaoCategoria.Id); erro != servicos.ErroDeServicoDaCategoriaNenhum {
			erroServicoCategoriaParaErrHttp(erro, resposta)
			return
		}

		resposta.WriteHeader(http.StatusNoContent)
		fmt.Fprintf(resposta, "Categoria excluído com sucesso")
	}

}
