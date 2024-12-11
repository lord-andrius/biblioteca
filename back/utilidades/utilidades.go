package utilidades

import (
	"regexp"
	"strconv"
	"strings"
	"unicode"
)

const emailRegex = `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`

func calcularDigitosVerificadores(cpf string, primeiroDigito bool) int {
	somaDigitos := 0

	for indice, caractere := range cpf {
		if indice < len(cpf)-1 {
			if primeiroDigito {
				somaDigitos += (int(caractere) - int('0')) * (indice + 1)
				if indice == 8 {
					break
				}
			} else {
				somaDigitos += (int(caractere) - int('0')) * indice
			}
		}
	}

	if somaDigitos%11 == 10 {
		return 0
	} else {
		return somaDigitos % 11
	}
}

func ValidarCpf(cpf string) bool {

	if len(cpf) != 11 {
		return false
	}
	primeiroDigitoVerificadorFornecido := 0
	segundoDigitoVerificadorFornecido := 0
	for indice, caractere := range cpf {
		if tamanhoCpf := len(cpf); indice == tamanhoCpf-2 {
			primeiroDigitoVerificadorFornecido = int(caractere) - int('0')
		} else if indice == tamanhoCpf-1 {
			segundoDigitoVerificadorFornecido = int(caractere) - int('0')
		}

	}

	return primeiroDigitoVerificadorFornecido == calcularDigitosVerificadores(cpf, true) && segundoDigitoVerificadorFornecido == calcularDigitosVerificadores(cpf, false)

}

func ValidarEmail(email string) bool {
	deuMatch, erro := regexp.MatchString(emailRegex, email)
	if erro != nil {
		return true
	}
	return deuMatch
}

func StringENumerica(s string) bool {
	for _, c := range s {
		if !unicode.IsDigit(c) {
			return false
		}
	}
	return true
}

func ValidarISBN(isbn string) bool {
	isbn = strings.ReplaceAll(isbn, "-", "")
	isbn = strings.ReplaceAll(isbn, " ", "")

	if len(isbn) == 10 {
		return validarISBN10(isbn)
	} else if len(isbn) == 13 {
		return validarISBN13(isbn)
	}
	return false
}

func validarISBN10(isbn string) bool {
	if len(isbn) != 10 {
		return false
	}

	soma := 0
	for i := 0; i < 9; i++ {
		digito, err := strconv.Atoi(string(isbn[i]))
		if err != nil {
			return false
		}
		soma += digito * (10 - i)
	}

	ultimoCaracter := isbn[9]
	var ultimoDigito int
	if ultimoCaracter == 'X' {
		ultimoDigito = 10
	} else {
		var err error
		ultimoDigito, err = strconv.Atoi(string(ultimoCaracter))
		if err != nil {
			return false
		}
	}

	soma += ultimoDigito
	return soma%11 == 0
}

func validarISBN13(isbn string) bool {
	if len(isbn) != 13 {
		return false
	}

	soma := 0
	for i := 0; i < 13; i++ {
		digito, err := strconv.Atoi(string(isbn[i]))
		if err != nil {
			return false
		}
		if i%2 == 0 {
			soma += digito
		} else {
			soma += digito * 3
		}
	}

	return soma%10 == 0
}
