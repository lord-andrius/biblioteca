package servicos

import (
	"biblioteca/banco"
	"biblioteca/modelos"
	"net/http"
)

// ValidarVisualizarAutores valida a requisão para recuperar os autores cadastrados
func ValidarVisualizarAutores() ([]modelos.AutorResposta, int, error) {
	var (
		autores []modelos.AutorResposta
		err     error
	)

	autores, err = banco.VisualizarAutores()
	if err != nil {
		return autores, http.StatusInternalServerError, err
	}
	return autores, http.StatusOK, nil
}

// ValidarCriacaoAutor valida os dados recebidos na requisição e caso sejam válidos chama a query do banco de dados
func ValidarCriacaoAutor(a modelos.Autor) (int, error) {
	if err := banco.InserirAutor(a); err != nil {
		return http.StatusInternalServerError, err
	}
	return http.StatusCreated, nil
}

// ValidarAtualizacaoAutor valida os dados recebidos na requisição e caso sejam válidos chama a query do banco de dados
func ValidarAtualizacaoAutor(a modelos.Autor) (int, error) {
	if err := banco.AtualizarAutor(a); err != nil {
		return http.StatusInternalServerError, err
	}
	return http.StatusOK, nil
}

// ValidarExcluicaoAutor valida os dados recebidos na requisição e caso sejam válidos chama a query do banco de dados
func ValidarExcluicaoAutor(a modelos.Autor) (int, error) {
	if err := banco.ExcluirAutor(a); err != nil {
		return http.StatusInternalServerError, err
	}
	return http.StatusNoContent, nil
}
