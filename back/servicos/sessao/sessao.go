package sessao

import (
	"biblioteca/banco"
	"math"
	"math/rand"
	"time"
)

type Sessao map[uint64]struct {
	TempoDaSessao time.Time
	Login         string
	Permissao     uint64
}

var _sessao Sessao

const _TEMPO_LIMITE_DA_SESSAO_EM_STRING = "8h"

const (
	VALIDO          = iota // Está presente no hashmap e está dentro do limite de tempo
	EXPIRADO               // Está presente no hashmap no entanto está fora do limite do tempo
	INVALIDO               //  Não está presente no hashmap
	SESSAO_INVALIDA        // Login não bate com a sessão
)

func init() {
	_sessao = make(Sessao)
}

func verificaSeTempoDaSessaoEValido(tempoDaSessao time.Time) bool { // eu preciso da duração da sessão em DURATION
	limite, _ := time.ParseDuration(_TEMPO_LIMITE_DA_SESSAO_EM_STRING)
	duracaoTempoDaSessao := time.Since(tempoDaSessao)
	return limite.Nanoseconds() > duracaoTempoDaSessao.Nanoseconds()

}

func PegarSessaoAtual() Sessao {
	return _sessao
}

func VerificaSeIdDaSessaoEValido(idDaSessao uint64, loginDoUsuario string) int {
	if sessao, ok := _sessao[idDaSessao]; ok {
		if sessao.Login != loginDoUsuario {
			return SESSAO_INVALIDA
		}

		if verificaSeTempoDaSessaoEValido(sessao.TempoDaSessao) {
			return VALIDO
		}
		// Já que o tempo expirou vamos excluir essa sessão
		delete(_sessao, idDaSessao)
		return EXPIRADO
	}
	return INVALIDO
}

// OBS: o id zero vai ser reservado para quando o front não tenha um id
func CriarNovaSessao(login string) (uint64, bool) { // o bool e para dizer se foi possível criar ou não a sessão
	idDaSessaoNova := uint64(rand.Int63n(math.MaxUint32))
	if VerificaSeIdDaSessaoEValido(idDaSessaoNova, login) == INVALIDO && idDaSessaoNova != 0 {

		novaSessao := _sessao[idDaSessaoNova]
		novaSessao.Login = login
		novaSessao.TempoDaSessao = time.Now()
		novaSessao.Permissao = pegarPermissao(novaSessao.Login)
		_sessao[idDaSessaoNova] = novaSessao

		//fmt.Println(_sessao)
		return idDaSessaoNova, true
	}
	return 0, false
}

func pegarPermissao(login string) uint64 {
	return banco.PegarPermissao(login)
}
