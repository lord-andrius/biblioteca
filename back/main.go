//go:build !testes
// +build !testes

package main

import (
	"biblioteca/banco"
	"biblioteca/rotas"
	"biblioteca/servicos"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
)

func main() {

	if err := godotenv.Load(); err != nil {
		log.Fatal("Erro ao carregar variáveis de ambiente!")
	}
	ip := "localhost"
	porta := os.Getenv("PORTA_API")
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
	http.HandleFunc("/exemplar", rotas.Exemplar)
	http.HandleFunc("/categoria", rotas.Categoria)
	http.HandleFunc("/subcategoria", rotas.SubCategoria)
	http.HandleFunc("/devolucao", rotas.Devolucao)
	http.HandleFunc("/pais", rotas.Pais)
	http.HandleFunc("/emprestimo", rotas.Emprestimo)
	http.HandleFunc("/dashboard", rotas.Dashboard)
	http.HandleFunc("/relatorio", rotas.Relatorio)
	fmt.Printf("Api está rodando em http://%s:%s\n", ip, porta)
	if erro := http.ListenAndServe(fmt.Sprintf(":%s", porta), nil); erro != nil {
		fmt.Println(erro)
	}
}
