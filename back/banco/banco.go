package banco

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/jackc/pgerrcode"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5"
)

// constantes de erros

const (
	ErroNenhum = iota
	ErroLoginDuplicado
	ErroCpfDuplicado
	ErroEmailDuplicado
	ErroUsuarioInexistente
	ErroLivroInexistente
	ErroIsbnDuplicado
)

var dbpool *pgxpool.Pool

func ErroSemLinhasRetornadas(e error) bool {
	stringDoErro := fmt.Sprint(e)
	return strings.Contains(stringDoErro, "no rows")
}

// talvez vá ser util
func ErroDeConexao(e error) bool {
	stringDoErro := fmt.Sprint(e)

	return strings.Contains(stringDoErro, pgerrcode.ConnectionException) ||
		strings.Contains(stringDoErro, pgerrcode.ConnectionDoesNotExist) ||
		strings.Contains(stringDoErro, pgerrcode.ConnectionFailure) ||
		strings.Contains(stringDoErro, pgerrcode.SQLClientUnableToEstablishSQLConnection) ||
		strings.Contains(stringDoErro, pgerrcode.SQLServerRejectedEstablishmentOfSQLConnection) ||
		strings.Contains(stringDoErro, pgerrcode.TransactionResolutionUnknown) ||
		strings.Contains(stringDoErro, pgerrcode.ProtocolViolation)
}

func Inicializar() {
	var erro error
	dbpool, erro = pgxpool.New(context.Background(), os.Getenv("DB_URL"))
	if erro != nil {
		log.Fatal("Não foi Possível se conectar no banco de dados")
	}
}

func PegarConexao() *pgxpool.Pool {
	return dbpool
}

func CriarTransacao() (pgx.Tx, error) {
	return PegarConexao().Begin(context.Background())
}

func Finalizar() {
	if dbpool != nil {
		dbpool.Close()
	}
}
