package relatorio

import (
	"biblioteca/banco"
	"bytes"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"os"
	"path/filepath"
	"time"

	gofpdf "github.com/jung-kurt/gofpdf/v2"
)

type ErroServicoRelatorio int

const (
	ErroServicoRelatorioNenhum = iota
	ErroServicoRelatorioSessaoInvalida
	ErroServicoRelatorioSemPermissao
	ErroServicoRelatorioDominioInvalido
	ErroServicoRelatorioProblemaAoGerarPDF
)

func nomeDominioFormatado(dominio string) string {
	switch dominio {
	case "autor":
		return "Autor"
	case "categoria":
		return "Categoria"
	case "Detalhe emprestimo":
		return "Detalhe Empréstimo"
	case "emprestimo":
		return "Empréstimo"
	case "exemplar":
		return "Exemplar"
	case "livro":
		return "Livro"
	case "pais":
		return "País"
	case "serie":
		return "Série"
	case "subcategoria":
		return "Subcategoria"
	case "turma":
		return "Turma"
	case "turno":
		return "Turno"
	case "usuario":
		return "Usuário"
	}
	return ""
}

func Relatorio(
	idDaSessao uint64,
	loginDoUsuario string,
	dominioDoRelatorio string,
	filtros []map[string]string,
) ([]byte, ErroServicoRelatorio) {

	// if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuario) != sessao.VALIDO {
	// 	return []byte{}, ErroServicoRelatorioSessaoInvalida
	// }
	// permissaoDoUsuario := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	// // TO DO: mudar permissão
	// if permissaoDoUsuario&utilidades.PermissaoRelatorio != utilidades.PermissaoRelatorio {
	// 	return []byte{}, ErroServicoRelatorioSemPermissao
	// }

	var cabecalhos []string
	var largulaCelulas []float64 // Largura máxima orientação P - 180, L - 280 dividir esse valor entre as colunas selecionadas
	var posicaoCelulas []string
	var orientacao string
	var dados [][]string

	switch dominioDoRelatorio {
	case "autor":
		cabecalhos = []string{"ID", "Nome", "Ano de Nascimento", "Nacionalidade", "Sexo"}
		largulaCelulas = []float64{20.0, 80.0, 30.0, 30.0, 20.0}
		posicaoCelulas = []string{"R", "L", "R", "L", "L"}
		orientacao = "P"
		autorBanco := banco.RelatorioAutor(filtros)
		if len(autorBanco) != 0 {
			dados = make([][]string, len(autorBanco))
			for index, autor := range autorBanco {
				dados[index] = []string{
					autor.IDDoAtuor,
					autor.Nome,
					autor.AnoNascimento,
					autor.Nacionalidade,
					autor.Sexo,
				}
			}
		}
	case "categoria":
		cabecalhos = []string{"ID", "Descrição", "Ativo"}
		largulaCelulas = []float64{20.0, 140.0, 20.0}
		posicaoCelulas = []string{"R", "L", "L"}
		orientacao = "P"
		categoriaBanco := banco.RelatorioCategoria(filtros)
		if len(categoriaBanco) != 0 {
			dados = make([][]string, len(categoriaBanco))
			for index, categoria := range categoriaBanco {
				dados[index] = []string{
					categoria.IdDaCategoria,
					categoria.Descricao,
					categoria.Ativo,
				}
			}
		}
	case "detalhe_emprestimo":
		cabecalhos = []string{"ID", "Descrição"}
		largulaCelulas = []float64{20.0, 160.0}
		posicaoCelulas = []string{"R", "L"}
		orientacao = "P"
		dados = [][]string{{"1", "Ficção Científica"}}
	case "emprestimo":
		cabecalhos = []string{"ID", "ISBN", "Titulo", "Cativo", "Status", "Estado"}
		largulaCelulas = []float64{20.0, 30.0, 70.0, 20.0, 20.0, 20.0}
		posicaoCelulas = []string{"R", "R", "L", "L", "L", "L"}
		orientacao = "P"
		exemplaresBanco := banco.RelatorioExemplar(filtros)

		if len(exemplaresBanco) != 0 {
			dados = make([][]string, len(exemplaresBanco))
			for index, exemplar := range exemplaresBanco {
				dados[index] = []string{
					exemplar.IDDoExemplarLivro,
					exemplar.ISBN,
					exemplar.Titulo,
					exemplar.Cativo,
					exemplar.Status,
					exemplar.Estado,
				}
			}
		}
	case "exemplar":
		cabecalhos = []string{"ID", "ISBN", "Titulo", "Cativo", "Status", "Estado"}
		largulaCelulas = []float64{20.0, 30.0, 70.0, 20.0, 20.0, 20.0}
		posicaoCelulas = []string{"R", "R", "L", "L", "L", "L"}
		orientacao = "P"
		exemplaresBanco := banco.RelatorioExemplar(filtros)

		if len(exemplaresBanco) != 0 {
			dados = make([][]string, len(exemplaresBanco))
			for index, exemplar := range exemplaresBanco {
				dados[index] = []string{
					exemplar.IDDoExemplarLivro,
					exemplar.ISBN,
					exemplar.Titulo,
					exemplar.Cativo,
					exemplar.Status,
					exemplar.Estado,
				}
			}
		}
	case "livro":
		cabecalhos = []string{"ID", "ISBN", "Titulo", "Ano Publicação", "Editora", "País", "Autor", "Categoria", "Subcategoria"}
		largulaCelulas = []float64{20.0, 30.0, 50.0, 20.0, 30.0, 30.0, 50.0, 30.0, 30.0}
		posicaoCelulas = []string{"R", "R", "L", "C", "L", "L", "L", "L", "L"}
		orientacao = "L"
		livrosBanco := banco.RelatorioLivro(filtros)

		if len(livrosBanco) != 0 {
			dados = make([][]string, len(livrosBanco))
			for index, livro := range livrosBanco {
				dados[index] = []string{
					livro.IDDoLivro,
					livro.ISBN,
					livro.Titulo,
					livro.AnoPublicacao,
					livro.Editora,
					livro.Pais,
					livro.Autor,
					livro.Categoria,
					livro.Subcategoria,
				}
			}
		}
	case "pais":
		cabecalhos = []string{"ID", "Descrição"}
		largulaCelulas = []float64{20.0, 160.0}
		posicaoCelulas = []string{"R", "L"}
		orientacao = "P"
		dados = [][]string{{"1", "Ficção Científica"}}
	case "serie":
		cabecalhos = []string{"ID", "Descrição"}
		largulaCelulas = []float64{20.0, 160.0}
		posicaoCelulas = []string{"R", "L"}
		orientacao = "P"
		dados = [][]string{
			{"1", "Ficção Científica"},
		}
	case "subcategoria":
		cabecalhos = []string{"ID", "Descrição", "Ativo"}
		largulaCelulas = []float64{20.0, 140.0, 20.0}
		posicaoCelulas = []string{"R", "L", "L"}
		orientacao = "P"
		subcategoriaBanco := banco.RelatorioSubcategoria(filtros)
		if len(subcategoriaBanco) != 0 {
			dados = make([][]string, len(subcategoriaBanco))
			for index, subcategoria := range subcategoriaBanco {
				dados[index] = []string{
					subcategoria.IdDaCategoria,
					subcategoria.Descricao,
					subcategoria.Ativo,
				}
			}
		}
	case "turma":
		cabecalhos = []string{"ID", "ISBN", "Titulo", "Ano Publicação", "Editora", "País"}
		largulaCelulas = []float64{20.0, 30.0, 50.0, 20.0, 30.0, 30.0}
		posicaoCelulas = []string{"R", "R", "L", "C", "L", "L"}
		orientacao = "P"
		dados = [][]string{
			{"1", "12345", "Senhor dos Aneis", "1999", "Editora A", "Brasil"},
		}
	case "turno":
		cabecalhos = []string{"ID", "ISBN", "Titulo", "Ano Publicação", "Editora", "País"}
		largulaCelulas = []float64{20.0, 30.0, 50.0, 20.0, 30.0, 30.0}
		posicaoCelulas = []string{"R", "R", "L", "C", "L", "L"}
		orientacao = "P"
		dados = [][]string{{"1", "12345", "Senhor dos Aneis", "1999", "Editora A", "Brasil"}}
	case "usuario":
		cabecalhos = []string{"ID", "Login", "CPF", "Nome", "Email", "Telefone", "Data Nascimento", "Turma", "Ativo"}
		largulaCelulas = []float64{20.0, 30.0, 30.0, 50.0, 50.0, 30.0, 30.0, 30.0, 10.0}
		posicaoCelulas = []string{"R", "L", "R", "L", "L", "R", "C", "L", "L"}
		orientacao = "L"
		usuarioBanco := banco.RelatorioUsuario(filtros)
		if len(usuarioBanco) != 0 {
			dados = make([][]string, len(usuarioBanco))
			for index, usuario := range usuarioBanco {
				dados[index] = []string{
					usuario.IdDoUsuario,
					usuario.Login,
					usuario.CPF,
					usuario.Nome,
					usuario.Email,
					usuario.Telefone,
					usuario.DataNascimento,
					usuario.Turma,
					usuario.Ativo,
				}
			}
		}
	}

	relatorio, erro := gerarPDF(dominioDoRelatorio, loginDoUsuario, cabecalhos, largulaCelulas, posicaoCelulas, orientacao, dados)

	if erro != ErroServicoRelatorioNenhum {
		panic(erro)
	}

	return relatorio, ErroServicoRelatorioNenhum

}

func gerarPDF(
	dominioRelatorio string,
	loginDoUsuario string,
	cabecalhos []string,
	largulaCelulas []float64,
	posicaoCelulas []string,
	orientacao string,
	dados [][]string,
) ([]byte, ErroServicoRelatorio) {

	caminhoBase, _ := filepath.Abs("")
	caminhoRelatorio := filepath.Join(caminhoBase, "servicos", "relatorio")

	caminhoFontePadrao := filepath.Join(caminhoRelatorio, "arial.ttf")
	caminhoFontePadraoNegrito := filepath.Join(caminhoRelatorio, "arial-bold.ttf")
	//minhoImagemFundo := filepath.Join(caminhoRelatorio, "fundo.png")
	caminhoImagemLogoEscola := filepath.Join(caminhoRelatorio, "logo.png")
	caminhoImagemLogoSistema := filepath.Join(caminhoRelatorio, "logo2.png")
	caminhoImagemComOpacidade := filepath.Join(caminhoRelatorio, "imagem_opacidade.png")

	// Usa para ajustar a opacidade da imagem de fundo caso ela ainda não possua sido ajustada
	// Irá salvar um arquivo temporário, como esse processo pode custar um pouco fazer isso apenas se
	// não existir uma imagem com a opacidade ajustada
	imagemComOpacidade := ajustarOpacidadeImagem(caminhoImagemLogoSistema, 0.1, caminhoImagemComOpacidade)
	//imagemComOpacidade := caminhoImagemComOpacidade

	pdf := gofpdf.New(orientacao, "mm", "A4", "")

	pdf.AddUTF8Font("padrao", "", caminhoFontePadrao)
	pdf.AddUTF8Font("padrao", "B", caminhoFontePadraoNegrito)

	nomeDominioFormatado := nomeDominioFormatado(dominioRelatorio)

	pdf.SetHeaderFunc(func() {
		cabecalho(pdf, caminhoImagemLogoSistema, caminhoImagemLogoEscola, nomeDominioFormatado, orientacao)
	})

	pdf.SetFooterFunc(func() {
		rodape(pdf, loginDoUsuario, orientacao)
	})

	pdf.AddPage()

	gerarTabela(pdf, imagemComOpacidade, cabecalhos, largulaCelulas, posicaoCelulas, dados)

	var buf bytes.Buffer
	err := pdf.Output(&buf)
	if err != nil {
		return nil, ErroServicoRelatorioProblemaAoGerarPDF
	}
	return buf.Bytes(), ErroServicoRelatorioNenhum
}

func gerarTabela(
	pdf *gofpdf.Fpdf,
	caminhoImagemFundo string,
	cabecalhos []string,
	largulaCelulas []float64,
	posicaoCelulas []string,
	dados [][]string,
) {
	pdf.SetFont("padrao", "", 8)

	var larguraTabela float64

	for _, larguraCelula := range largulaCelulas {
		larguraTabela = larguraTabela + larguraCelula
	}

	//larguraCelula := 40.0
	//larguraTabela := float64(len(cabecalhos)) * larguraCelula

	larguraPagina, _ := pdf.GetPageSize()
	posicaoInicialX := (larguraPagina - larguraTabela) / 2
	pdf.SetX(posicaoInicialX)

	for index, cabecalho := range cabecalhos {
		pdf.SetFillColor(183, 211, 225)
		pdf.SetTextColor(0, 0, 0)
		pdf.CellFormat(largulaCelulas[index], 10, cabecalho, "1", 0, "C", true, 0, "")
	}
	pdf.Ln(-1)

	adicinouImageFundo := false

	for index, linha := range dados {
		if index%2 == 0 {
			pdf.SetFillColor(234, 250, 255)
			pdf.SetTextColor(0, 0, 0)
		} else {
			pdf.SetFillColor(203, 241, 255)
			pdf.SetTextColor(0, 0, 0)
		}

		pdf.SetX(posicaoInicialX)
		for index, celula := range linha {
			pdf.CellFormat(largulaCelulas[index], 10, celula, "1", 0, posicaoCelulas[index], true, 0, "")
		}
		pdf.Ln(-1)

		if pdf.GetY() > 270 {
			adicionarImagemFundo(pdf, caminhoImagemFundo)

			pdf.AddPage()

			adicinouImageFundo = true
		} else {
			adicinouImageFundo = false
		}
	}

	if !adicinouImageFundo {
		adicionarImagemFundo(pdf, caminhoImagemFundo)
	}

}

func cabecalho(pdf *gofpdf.Fpdf, caminhoImagemSistema string, caminhoImagemEscola string, nomeDominio string, orientacao string) {

	imagensPosY := float64(10)
	larguraImagens := float64(25)
	alturaImagens := float64(25)

	imagemSistemaPosX := float64(10)
	var imagemEscolaPosX float64
	if orientacao == "P" {
		imagemEscolaPosX = float64(175)
	} else {
		imagemEscolaPosX = float64(260)
	}

	pdf.ImageOptions(caminhoImagemSistema, imagemSistemaPosX, imagensPosY, larguraImagens, alturaImagens, false, gofpdf.ImageOptions{ImageType: "PNG", ReadDpi: true}, 0, "")
	pdf.ImageOptions(caminhoImagemEscola, imagemEscolaPosX, imagensPosY, larguraImagens, alturaImagens, false, gofpdf.ImageOptions{ImageType: "PNG", ReadDpi: true}, 0, "")

	pdf.SetFont("padrao", "B", 14)

	pdf.SetXY(10, 12)
	pdf.CellFormat(0, 10, "Sistema Pallasys", "", 1, "C", false, 0, "")

	pdf.SetFont("padrao", "B", 12)
	pdf.SetTextColor(0, 0, 255)
	pdf.SetXY(10, 20)
	pdf.CellFormat(0, 10, fmt.Sprintf("Relatório: %s", nomeDominio), "", 1, "C", false, 0, "")
	pdf.SetTextColor(0, 0, 0)

	pdf.SetXY(10, 35)
	pdf.SetFont("padrao", "", 10)

	// pdf.SetFont("padrao", "B", 10)
	// pdf.CellFormat(15, 10, "Filtros:", "", 0, "L", false, 0, "")
	// pdf.SetFont("padrao", "", 10)

	// filtrosPesquisa := []string{
	// 	"Data: 02/02/2024 à 05/05/2024",
	// 	"Usuários com emprestimo atrasados",
	// 	"Usuários ativos",
	// 	"Usuários professores",
	// 	"Usuários alunos",
	// 	"Data: 02/02/2024 à 05/05/2024",
	// 	"Usuários com emprestimo atrasados",
	// }

	// var textoFiltroPesquisa string

	// for _, filtro := range filtrosPesquisa {
	// 	if len(textoFiltroPesquisa) == 0 {
	// 		textoFiltroPesquisa = filtro
	// 	} else {
	// 		textoFiltroPesquisa = textoFiltroPesquisa + " | " + filtro
	// 	}
	// }

	// pdf.SetFont("padrao", "", 10)

	// pdf.MultiCell(0, 10, textoFiltroPesquisa, "", "L", false)

	//espacamentoFiltrosLinha := float64(20)

	// pdf.Ln(espacamentoFiltrosLinha)

	pdf.SetLineWidth(0.5)
	pdf.SetDrawColor(0, 0, 0)
	//pdf.Line(10, 45+espacamentoFiltrosLinha, 200, 45+espacamentoFiltrosLinha)
	if orientacao == "P" {
		pdf.Line(10, 45, 200, 45)
	} else {
		pdf.Line(10, 45, 280, 45)

	}
	pdf.Ln(20)
}

func rodape(pdf *gofpdf.Fpdf, loginDoUsuario string, orientacao string) {
	pdf.SetFont("padrao", "B", 8)
	_, alturaPagina := pdf.GetPageSize()
	margemInferior := 10
	pdf.SetY(float64(alturaPagina) - float64(margemInferior))

	if orientacao == "P" {
		pdf.CellFormat(50, 5, fmt.Sprintf("Data emissão - %v", time.Now().Format("02/01/2006 15:04:05")), "", 0, "L", false, 0, "")
		pdf.CellFormat(100, 5, fmt.Sprintf("Usuário emissão: %s", loginDoUsuario), "", 0, "C", false, 0, "")
	} else {
		pdf.CellFormat(90, 5, fmt.Sprintf("Data emissão - %v", time.Now().Format("02/01/2006 15:04:05")), "", 0, "L", false, 0, "")
		pdf.CellFormat(100, 5, fmt.Sprintf("Usuário emissão: %s", loginDoUsuario), "", 0, "C", false, 0, "")
	}
	pdf.CellFormat(0, 5, "Página "+fmt.Sprintf("%d/%d", pdf.PageNo(), pdf.PageCount()), "", 0, "R", false, 0, "")
}

func adicionarImagemFundo(pdf *gofpdf.Fpdf, caminhoImagem string) {

	larguraPagina, alturaPagina := pdf.GetPageSize()

	larguraImagem := float64(100)
	alturaImagem := float64(100)

	posicaoX := (larguraPagina - larguraImagem) / 2
	posicaoY := (alturaPagina - alturaImagem) / 2

	pdf.ImageOptions(
		caminhoImagem,
		posicaoX, posicaoY, larguraImagem, alturaImagem,
		false,
		gofpdf.ImageOptions{ImageType: "PNG", ReadDpi: true},
		0, "",
	)
}

func ajustarOpacidadeImagem(caminhoImagem string, opacidade float64, caminhoImagemTemporaria string) string {
	arquivo, erro := os.Open(caminhoImagem)
	if erro != nil {
		panic(erro)
	}
	defer arquivo.Close()

	imagem, erro := png.Decode(arquivo)
	if erro != nil {
		panic(erro)
	}

	bounds := imagem.Bounds()
	novaImagem := image.NewRGBA(bounds)
	for y := bounds.Min.Y; y < bounds.Max.Y; y++ {
		for x := bounds.Min.X; x < bounds.Max.X; x++ {
			corOriginal := imagem.At(x, y)
			r, g, b, a := corOriginal.RGBA()
			alpha := uint8(float64(a>>8) * opacidade)
			novaImagem.Set(x, y, color.NRGBA{
				R: uint8(r >> 8),
				G: uint8(g >> 8),
				B: uint8(b >> 8),
				A: alpha,
			})
		}
	}

	arquivoTemporario := caminhoImagemTemporaria
	arquivoGerado, err := os.Create(arquivoTemporario)
	if err != nil {
		panic(err)
	}
	defer arquivoGerado.Close()

	err = png.Encode(arquivoGerado, novaImagem)
	if err != nil {
		panic(err)
	}

	return arquivoTemporario
}
