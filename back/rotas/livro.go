package rotas

import (
	"biblioteca/modelos"
	servicoLivro "biblioteca/servicos/livro"
	servicoUsuario "biblioteca/servicos/usuario"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type requisicaoLivro struct {
	IdDaSessao               uint64   `validate:"required"`
	LoginDoUsuarioRequerente string   `validate:"required"`
	Id                       int      `validate:"optional"`
	Isbn                     string   `validate:"optional"`
	Titulo                   string   `validate:"optional"`
	AnoPublicao              string   `validate:"optional"`
	Editora                  string   `validate:"optional"`
	Pais                     int      `validate:"optional"`
	NomeDosAutores           []string `validate:"optional"`
	TextoDeBusca             string   `validate:"optional"`
}

type respostaPesquisaLivro struct {
	Id          int      `validate:"optional"`
	Isbn        string   `validate:"optional"`
	Titulo      string   `validate:"optional"`
	AnoPublicao string   `validate:"optional"`
	Editora     string   `validate:"optional"`
	Pais        int      `validate:"optional"`
	NomeAutores []string `validate:"optional"`
}

type respostaLivro struct {
	LivrosAtingidos []modelos.Livro
}

func erroServicoLivroParaErrHttp(erro servicoLivro.ErroDeServicoDoLivro, resposta http.ResponseWriter) {
	switch erro {
	case servicoLivro.ErroDeServicoDoLivroIsbnDuplicado:
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "Isbn duplicado")
		return
	case servicoLivro.ErroDeServicoDoLivroIsbnInvalido:
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "Isbn inválido, o Isbn deve seguir a formatação prevista para ISBN-10 e ISBN-13")
		return
	case servicoLivro.ErroDeServicoDoLivroSemPermisao:
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "Este usuário não tem permissão para essa operação")
		return
	case servicoLivro.ErroDeServicoDoLivroAnoPublicaoInvalida:
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "Ano de Publicação inválido")
		return
	case servicoLivro.ErroDeServicoDoLivroSessaoInvalida:
		resposta.WriteHeader(http.StatusUnauthorized)
		fmt.Fprintf(resposta, "Este usuário não está autorizado(logado). Sessão inválida?")
		return
	}
}

func Livro(resposta http.ResponseWriter, requisicao *http.Request) {

	corpoDaRequisicao, erro := io.ReadAll(requisicao.Body)

	if erro != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de livro foi mal feita")
		return
	}

	var requisicaoLivro requisicaoLivro
	if json.Unmarshal(corpoDaRequisicao, &requisicaoLivro) != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de livro foi mal feita")
		return
	}

	if requisicaoLivro.LoginDoUsuarioRequerente == "" {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de livro foi mal feita")
		return
	}

	switch requisicao.Method {
	case "POST":
		if len(requisicaoLivro.Titulo) < 1 ||
			len(requisicaoLivro.AnoPublicao) < 1 ||
			len(requisicaoLivro.Editora) < 1 {
			resposta.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(resposta, "Algum campo necessário para o cadastro não foi fornecido")
			return
		}

		var novoLivro modelos.Livro
		novoLivro.Isbn = requisicaoLivro.Isbn
		novoLivro.Titulo = requisicaoLivro.Titulo
		novoLivro.AnoPublicao = requisicaoLivro.AnoPublicao
		novoLivro.Editora = requisicaoLivro.Editora
		novoLivro.Pais = requisicaoLivro.Pais

		erro := servicoLivro.CriarLivro(requisicaoLivro.IdDaSessao, requisicaoLivro.LoginDoUsuarioRequerente, novoLivro, requisicaoLivro.NomeDosAutores)

		if erro != servicoLivro.ErroDeServicoDoLivroNenhum {
			erroServicoLivroParaErrHttp(erro, resposta)
			return
		}

		novoLivro.IdDoLivro = servicoLivro.PegarIdLivro(novoLivro.Isbn)

		respostaLivro := respostaLivro{
			[]modelos.Livro{
				novoLivro,
			},
		}

		respostaLivroJson, _ := json.Marshal(&respostaLivro)

		fmt.Fprintf(resposta, "%s", respostaLivroJson)

		return
	case "GET":
		livrosEncontrados, erro := servicoLivro.BuscarLivro(requisicaoLivro.IdDaSessao, requisicaoLivro.LoginDoUsuarioRequerente, requisicaoLivro.TextoDeBusca)
		if erro == servicoLivro.ErroDeServicoDoLivroSemPermisao {
			resposta.WriteHeader(http.StatusForbidden)
			fmt.Fprintf(resposta, "Este usuário não tem permissão para essa operação")
			return
		} else if erro == servicoLivro.ErroDeServicoDoLivroFalhaNaBusca {
			resposta.WriteHeader(http.StatusInternalServerError)
			fmt.Fprint(resposta, "Houve um erro interno enquanto se fazia a busca! Provavelmente é um bug na api!")
			return
		}
		respostaLivro := respostaLivro{
			livrosEncontrados,
		}
		respostaLivroJson, _ := json.Marshal(&respostaLivro)

		fmt.Fprintf(resposta, "%s", respostaLivroJson)

	case "PUT":
		if len(requisicaoLivro.Titulo) < 1 ||
			len(requisicaoLivro.AnoPublicao) < 1 ||
			len(requisicaoLivro.Editora) < 1 {
			resposta.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(resposta, "Algum campo necessário para o cadastro não foi fornecido")
			return
		}

		var livroComDadosAtualizados modelos.Livro
		livroComDadosAtualizados.IdDoLivro = requisicaoLivro.Id
		livroComDadosAtualizados.Isbn = requisicaoLivro.Isbn
		livroComDadosAtualizados.Titulo = requisicaoLivro.Titulo
		livroComDadosAtualizados.AnoPublicao = requisicaoLivro.AnoPublicao
		livroComDadosAtualizados.Editora = requisicaoLivro.Editora
		livroComDadosAtualizados.Pais = requisicaoLivro.Pais

		livroAtualizado, erro := servicoLivro.AtualizarLivro(requisicaoLivro.IdDaSessao, requisicaoLivro.LoginDoUsuarioRequerente, livroComDadosAtualizados, requisicaoLivro.NomeDosAutores)

		if erro != servicoLivro.ErroDeServicoDoLivroNenhum {
			erroServicoLivroParaErrHttp(erro, resposta)
			return
		}

		respostaLivro := respostaLivro{
			[]modelos.Livro{
				livroAtualizado,
			},
		}
		respostaLivroJson, _ := json.Marshal(&respostaLivro)

		fmt.Fprintf(resposta, "%s", respostaLivroJson)

	case "DELETE":
		if requisicaoLivro.Id == 0 {
			resposta.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(resposta, "É necessário informar o Id do livro que deseja excluir")
			return
		}

		if erro := servicoLivro.DeletarLivro(requisicaoLivro.IdDaSessao, requisicaoLivro.LoginDoUsuarioRequerente, requisicaoLivro.Id); erro != servicoUsuario.ErroDeServicoDoUsuarioNenhum {
			erroServicoLivroParaErrHttp(erro, resposta)
		}

		resposta.WriteHeader(http.StatusNoContent)
		fmt.Fprintf(resposta, "Usuário excluído com sucesso")
	}

}
