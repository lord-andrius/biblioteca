package banco

import (
	"context"
	"fmt"
)

func AssociarLivroAutor(idLivro, idAutor int) ErroBancoLivro {
	conexao := PegarConexao()

	_, erroQuery := conexao.Exec(
		context.Background(),
		"insert into livro_autor(id_livro, id_autor, data_criacao) values ($1, $2, current_timestamp) on conflict (id_livro, id_autor) do nothing",
		idLivro,
		idAutor,
	)

	if erroQuery != nil {
		fmt.Println(erroQuery)
		panic("Um erro imprevisto aconteceu na Associação do livro com o autor.")
	}

	return ErroNenhum
}

func DessasociarLivroAutor(idLivro, idAutor int) ErroBancoLivro {
	conexao := PegarConexao()

	_, erroQuery := conexao.Exec(
		context.Background(),
		"delete from livro_autor where id_livro = $1 and id_autor = $2",
		idLivro,
		idAutor,
	)

	if erroQuery != nil {
		fmt.Println(erroQuery)
		panic("Um erro imprevisto aconteceu na Desassociação do livro com o autor.")
	}

	return ErroNenhum
}
