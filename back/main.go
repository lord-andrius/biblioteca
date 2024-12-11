package main

import (
	"biblioteca/banco"
	"biblioteca/rotas"
	"biblioteca/servicos"
	"fmt"
	"log"
	"net/http"

	"github.com/joho/godotenv"
)

func main() {

	ip := "localhost"
	porta := "9090"

	if err := godotenv.Load(); err != nil {
		log.Fatal("Erro ao carregar variáveis de ambiente!")
	}
	servicos.InicializarServicoEmail()
	banco.Inicializar()
	defer banco.Finalizar()
	http.HandleFunc("/login", rotas.Login)
	http.HandleFunc("/usuario", rotas.Usuario)
	http.HandleFunc("/autor", rotas.Autor)
	http.HandleFunc("/recuperarsenha", rotas.RecuperarSenha)
	http.HandleFunc("/livro", rotas.Livro)
	http.HandleFunc("/turnos", rotas.Turnos)
	http.HandleFunc("/series", rotas.Series)
	http.HandleFunc("/turmas", rotas.Turma)
	fmt.Printf("Api está rodando em http://%s:%s\n", ip, porta)
	http.ListenAndServe(fmt.Sprintf(":%s", porta), nil)
}
