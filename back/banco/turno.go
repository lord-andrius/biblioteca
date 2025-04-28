package banco

import (
	//"log"
	"biblioteca/modelos"
	"context"

	"github.com/jackc/pgx/v5"
)

func PegarTodosOsTurnos() []modelos.Turno {
	conexao := PegarConexao()
	textoQuery := "select id_turno, descricao from turno t"
	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		return []modelos.Turno{}
	}
	turnosEncontrados := make([]modelos.Turno, 0, 4)
	var turnoTemporario modelos.Turno
	_, erro = pgx.ForEachRow(linhas, []any{&turnoTemporario.IdTurno, &turnoTemporario.Descricao}, func() error {
		turnosEncontrados = append(turnosEncontrados, turnoTemporario)
		return nil
	})
	if erro != nil {
		return []modelos.Turno{}
	}
	return turnosEncontrados
}

/*
func PegarTurnoPorId(idTurno int) (modelos.Turno, bool) {
	conexao := PegarConexao()
	textoQuery := "select id_turno, descricao from turno t where id_turno = $1"
	var turno modelos.Turno
	erro := conexao.QueryRow(context.Background(), textoQuery, idTurno).Scan(
		&Turno.
	)
	if erro != nil {
		return modelos.Turno{}, false
	}
	var turno modelos.Turno
}
*/

