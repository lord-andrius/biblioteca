import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
import 'package:biblioteca/data/providers/livro_provider.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:biblioteca/widgets/tables/exemplar_table_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PesquisarLivro extends StatefulWidget {
  const PesquisarLivro({super.key});

  @override
  State<PesquisarLivro> createState() => _PesquisarLivroState();
}

class _PesquisarLivroState extends State<PesquisarLivro> {
  late TextEditingController _searchController;
  late List<Livro> filteredBooks = [];
  late Livro? selectBook;
  late bool search = false;
  late ExemplarProvider providerExemplar;
  late List<Exemplar> exemplares;
  late List<Exemplar> filteredExemplares;

  // Variáveis para tabela de livros
  int rowsPerPage = 10;
  final List<int> rowsPerPageOptions = [5, 10, 15, 20];
  int currentPage = 1;
  String _tableFilterText = '';
  final TextEditingController _tableFilterController = TextEditingController();

  String _sortColumn = 'titulo'; // ou 'isbn', 'autor', 'ano', 'qtd'
  bool _isAscending = true;

  // Variáveis para tabela de exemplares
  int rowsPerPageExemplares = 10;
  final List<int> rowsPerPageOptionsExemplares = [5, 10, 15, 20];
  int currentPageExemplares = 1;
  String _tableFilterTextExemplares = '';
  final TextEditingController _tableFilterControllerExemplares =
      TextEditingController();
  String _sortColumnExemplares =
      'tombamento'; // 'tombamento', 'titulo', 'situacao', 'estado', 'cativo'
  bool _isAscendingExemplares = true;

  @override
  void initState() {
    super.initState();
    providerExemplar = Provider.of<ExemplarProvider>(context, listen: false);
    _searchController = TextEditingController();
    filteredExemplares = [];
    if (providerExemplar.exemplares.isEmpty) {
      Provider.of<ExemplarProvider>(context, listen: false)
          .loadExemplares()
          .then((_) {
        setState(() {});
      });
    }
  }

  scafoldMsg(String msg, int tipo) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: tipo == 1
          ? Colors.red
          : (tipo == 2)
              ? Colors.orange
              : Colors.green,
      content: Text(
        msg,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 2),
    ));
  }

  void SearchExemplares(int idDoLivro) {
    filteredExemplares =
        exemplares.where((exemplar) => exemplar.idLivro == idDoLivro).toList();
    filteredExemplares.sort((a, b) => a.id.compareTo(b.id));
  }

  void searchBooks() async {
    final searchQuery = _searchController.text;
    selectBook = null;
    if (searchQuery.isNotEmpty) {
      try {
        final resposta =
            await Provider.of<LivroProvider>(context, listen: false)
                .searchLivros(searchQuery);
        setState(() {
          search = true;
          print(resposta);
          filteredBooks = resposta;
        });
      } catch (e) {
        print(e.toString());
        scafoldMsg(
            'Erro ao realizar a pesquisa de livros. Tente novamente mais tarde.',
            1);
      }
    }
  }

  void _abrirExemplares(Livro livro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExemplaresPage(
          book: livro,
          ultimaPagina: "Pesquisar Livro",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    exemplares = providerExemplar.exemplares;
    // Filtro da tabela
    List<Livro> filteredTableBooks = filteredBooks;
    if (_tableFilterText.isNotEmpty) {
      filteredTableBooks = filteredBooks.where((livro) {
        final isbnMatch = livro.isbn.toLowerCase().contains(_tableFilterText);
        final tituloMatch =
            livro.titulo.toLowerCase().contains(_tableFilterText);
        final autorMatch = livro.autores.isNotEmpty
            ? (livro.autores[0] is Map<String, dynamic>
                ? (livro.autores[0]['nome'] ?? '')
                    .toLowerCase()
                    .contains(_tableFilterText)
                : livro.autores[0]
                    .toString()
                    .toLowerCase()
                    .contains(_tableFilterText))
            : false;
        final anoMatch =
            livro.anoPublicacao.toString().contains(_tableFilterText);
        final qtdExemplaresMatch = providerExemplar
            .qtdExemplaresLivro(livro.idDoLivro)
            .toString()
            .contains(_tableFilterText);
        return isbnMatch ||
            tituloMatch ||
            autorMatch ||
            anoMatch ||
            qtdExemplaresMatch;
      }).toList();
    }

    // Ordenação
    filteredTableBooks.sort((a, b) {
      int cmp = 0;
      switch (_sortColumn) {
        case 'isbn':
          cmp = a.isbn.toLowerCase().compareTo(b.isbn.toLowerCase());
          break;
        case 'titulo':
          cmp = a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
          break;
        case 'autor':
          cmp = a.autores[0]['nome']
              .toLowerCase()
              .compareTo(b.autores[0]['nome'].toLowerCase());
          break;
        case 'ano':
          cmp = a.anoPublicacao.compareTo(b.anoPublicacao);
          break;
        case 'qtd':
          cmp = providerExemplar
              .qtdExemplaresLivro(a.idDoLivro)
              .compareTo(providerExemplar.qtdExemplaresLivro(b.idDoLivro));
          break;
      }
      return _isAscending ? cmp : -cmp;
    });

    // Paginação
    int totalPages = (filteredTableBooks.length / rowsPerPage).ceil();
    int startIndex = (currentPage - 1) * rowsPerPage;
    int endIndex = (startIndex + rowsPerPage) < filteredTableBooks.length
        ? (startIndex + rowsPerPage)
        : filteredTableBooks.length;
    List<Livro> paginatedBooks =
        filteredTableBooks.sublist(startIndex, endIndex);

    // Filtro da tabela de exemplares
    List<Exemplar> filteredTableExemplares = filteredExemplares;
    if (_tableFilterTextExemplares.isNotEmpty) {
      filteredTableExemplares = filteredExemplares.where((exemplar) {
        final tombamentoMatch =
            exemplar.id.toString().contains(_tableFilterTextExemplares);
        final tituloMatch =
            exemplar.titulo.toLowerCase().contains(_tableFilterTextExemplares);
        final situacaoMatch = exemplar.getStatus
            .toLowerCase()
            .contains(_tableFilterTextExemplares);
        final estadoMatch = exemplar.getEstado
            .toLowerCase()
            .contains(_tableFilterTextExemplares);
        final cativoMatch = (exemplar.cativo ? 'sim' : 'não')
            .contains(_tableFilterTextExemplares);
        return tombamentoMatch ||
            tituloMatch ||
            situacaoMatch ||
            estadoMatch ||
            cativoMatch;
      }).toList();
    }

    // Ordenação dos exemplares
    filteredTableExemplares.sort((a, b) {
      int cmp = 0;
      switch (_sortColumnExemplares) {
        case 'tombamento':
          cmp = a.id.compareTo(b.id);
          break;
        case 'titulo':
          cmp = a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
          break;
        case 'situacao':
          cmp = a.getStatus.toLowerCase().compareTo(b.getStatus.toLowerCase());
          break;
        case 'estado':
          cmp = a.getEstado.toLowerCase().compareTo(b.getEstado.toLowerCase());
          break;
        case 'cativo':
          cmp = a.cativo.toString().compareTo(b.cativo.toString());
          break;
      }
      return _isAscendingExemplares ? cmp : -cmp;
    });

    // Paginação dos exemplares
    int totalPagesExemplares =
        (filteredTableExemplares.length / rowsPerPageExemplares).ceil();
    int startIndexExemplares =
        (currentPageExemplares - 1) * rowsPerPageExemplares;
    int endIndexExemplares = (startIndexExemplares + rowsPerPageExemplares) <
            filteredTableExemplares.length
        ? (startIndexExemplares + rowsPerPageExemplares)
        : filteredTableExemplares.length;
    List<Exemplar> paginatedExemplares = filteredTableExemplares.sublist(
        startIndexExemplares, endIndexExemplares);

    return Material(
      child: Column(
        children: [
          const BreadCrumb(
              breadcrumb: ['Início', 'Pesquisar Livro'], icon: Icons.search),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 35, right: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pesquisa De Livro",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color.fromRGBO(38, 42, 79, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 800,
                          maxHeight: 40,
                          minWidth: 200,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            labelText: "Insira os dados do livro",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onSubmitted: (value) {
                            searchBooks();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(
                            top: 16,
                            bottom: 16,
                            left: 16,
                            right: 20,
                          ),
                          backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: searchBooks,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              "Pesquisar",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.5,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 40),
                if (search)
                  if (filteredBooks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Nenhum livro encontrado',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  else if (selectBook == null)
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1210,
                        minWidth: 800,
                      ),
                      child: Column(
                        children: [
                          // Filtro e seleção de registros por página
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 16.0, top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Registros por página
                                Row(
                                  children: [
                                    const Text('Exibir'),
                                    const SizedBox(width: 8),
                                    DropdownButton<int>(
                                      value: rowsPerPage,
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            rowsPerPage = value;
                                            currentPage = 1;
                                          });
                                        }
                                      },
                                      items:
                                          rowsPerPageOptions.map((int value) {
                                        return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(value.toString()));
                                      }).toList(),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('registros por página'),
                                  ],
                                ),
                                // Campo de filtro
                                SizedBox(
                                  width: 300,
                                  child: TextField(
                                    controller: _tableFilterController,
                                    decoration: const InputDecoration(
                                      labelText: 'Pesquisar',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 12),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _tableFilterText = value.toLowerCase();
                                        currentPage = 1;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tabela
                          Table(
                            border: TableBorder.all(
                              color: const Color.fromARGB(215, 200, 200, 200),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(0.13),
                              1: FlexColumnWidth(0.30),
                              2: FlexColumnWidth(0.20),
                              3: FlexColumnWidth(0.14),
                              4: FlexColumnWidth(0.13),
                              5: FlexColumnWidth(0.12),
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(38, 42, 79, 1),
                                ),
                                children: [
                                  // ISBN
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumn == 'isbn') {
                                            _isAscending = !_isAscending;
                                          } else {
                                            _sortColumn = 'isbn';
                                            _isAscending = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'ISBN',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumn == 'isbn'
                                                ? (_isAscending
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Título
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumn == 'titulo') {
                                            _isAscending = !_isAscending;
                                          } else {
                                            _sortColumn = 'titulo';
                                            _isAscending = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Titulo',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumn == 'titulo'
                                                ? (_isAscending
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Autor
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumn == 'autor') {
                                            _isAscending = !_isAscending;
                                          } else {
                                            _sortColumn = 'autor';
                                            _isAscending = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Autor',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumn == 'autor'
                                                ? (_isAscending
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Ano de Publicação
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumn == 'ano') {
                                            _isAscending = !_isAscending;
                                          } else {
                                            _sortColumn = 'ano';
                                            _isAscending = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Ano de Publicação',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumn == 'ano'
                                                ? (_isAscending
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Qtd. Exemplares
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumn == 'qtd') {
                                            _isAscending = !_isAscending;
                                          } else {
                                            _sortColumn = 'qtd';
                                            _isAscending = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Qtd. Exemplares',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumn == 'qtd'
                                                ? (_isAscending
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Ação (não ordenável né)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Ação',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                              for (int x = 0; x < paginatedBooks.length; x++)
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: x % 2 == 0
                                        ? Color.fromRGBO(233, 235, 238, 75)
                                        : Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13, horizontal: 8),
                                      child: Text(
                                        paginatedBooks[x].isbn,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13, horizontal: 8),
                                      child: Text(
                                        paginatedBooks[x].titulo,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13, horizontal: 8),
                                      child: Text(
                                        paginatedBooks[x].autores[0]["nome"],
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13, horizontal: 8),
                                      child: Text(
                                        '${paginatedBooks[x].anoPublicacao}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13, horizontal: 8),
                                      child: Text(
                                        '${providerExemplar.qtdExemplaresLivro(paginatedBooks[x].idDoLivro)}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 14,
                                      ),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 45, 106, 79),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectBook = paginatedBooks[x];
                                            SearchExemplares(
                                                selectBook!.idDoLivro);
                                          });
                                        },
                                        child: const Text(
                                          'Selecionar',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 250, 244, 244),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          // Paginação
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: currentPage > 1
                                      ? () {
                                          setState(() {
                                            currentPage--;
                                          });
                                        }
                                      : null,
                                ),
                                for (int i = 1; i <= totalPages; i++)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        currentPage = i;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: i == currentPage
                                            ? const Color.fromARGB(
                                                255, 38, 42, 79)
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Text(
                                        i.toString(),
                                        style: TextStyle(
                                          color: i == currentPage
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: currentPage < totalPages
                                      ? () {
                                          setState(() {
                                            currentPage++;
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: 1150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.book,
                                      color: Color.fromRGBO(38, 42, 79, 1),
                                      size: 23,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      "Livro Selecionado",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.3,
                                            color:
                                                Color.fromRGBO(38, 42, 79, 1),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(thickness: 2, color: Colors.grey[400]),
                              const SizedBox(
                                height: 10,
                              ),
                              Table(
                                border: TableBorder.all(
                                  color:
                                      const Color.fromARGB(215, 200, 200, 200),
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(0.05),
                                  1: FlexColumnWidth(0.12),
                                  2: FlexColumnWidth(0.30),
                                  3: FlexColumnWidth(0.20),
                                  4: FlexColumnWidth(0.14),
                                  5: FlexColumnWidth(0.12),
                                },
                                children: [
                                  const TableRow(
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(38, 42, 79, 1),
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Ação',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'ISBN',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Titulo',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Autor',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Ano de Publicação',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Qtd. Exemplares',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(233, 235, 238, 75),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        child: IconButton(
                                          icon: const Icon(
                                              Icons.menu_book_outlined),
                                          tooltip: 'Ver exemplares',
                                          iconSize: 18,
                                          constraints: const BoxConstraints(
                                            minWidth: 25,
                                            minHeight: 25,
                                          ),
                                          onPressed: () =>
                                              _abrirExemplares(selectBook!),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        child: Text(
                                          selectBook!.isbn,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        child: Text(
                                          selectBook!.titulo,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        child: Text(
                                          selectBook!.autores[0]['nome'],
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        child: Text(
                                          selectBook!.anoPublicacao.toString(),
                                          // DateFormat('dd/MM/yyyy')
                                          //     .format(
                                          //   selectBook!.anoPublicacao,
                                          // ),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        child: Text(
                                          '${providerExemplar.qtdExemplaresLivro(selectBook!.idDoLivro)}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 14.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.library_books,
                                  color: Color.fromRGBO(38, 42, 79, 1),
                                  size: 24,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Detalhes Dos Exemplares",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.3,
                                        color: Color.fromRGBO(38, 42, 79, 1),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Divider(thickness: 2, color: Colors.grey[400]),
                          const SizedBox(
                            height: 10,
                          ),
                          // Campo de filtro e seleção de registros por página para exemplares
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 16.0, top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Registros por página
                                Row(
                                  children: [
                                    const Text('Exibir'),
                                    const SizedBox(width: 8),
                                    DropdownButton<int>(
                                      value: rowsPerPageExemplares,
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            rowsPerPageExemplares = value;
                                            currentPageExemplares = 1;
                                          });
                                        }
                                      },
                                      items: rowsPerPageOptionsExemplares
                                          .map((int value) {
                                        return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(value.toString()));
                                      }).toList(),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('registros por página'),
                                  ],
                                ),
                                // Campo de filtro
                                SizedBox(
                                  width: 300,
                                  child: TextField(
                                    controller:
                                        _tableFilterControllerExemplares,
                                    decoration: const InputDecoration(
                                      labelText: 'Pesquisar',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 12),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _tableFilterTextExemplares =
                                            value.toLowerCase();
                                        currentPageExemplares = 1;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Table(
                            border: TableBorder.all(
                              color: const Color.fromARGB(215, 200, 200, 200),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(0.12),
                              1: FlexColumnWidth(0.30),
                              2: FlexColumnWidth(0.16),
                              3: FlexColumnWidth(0.15),
                              4: FlexColumnWidth(0.10),
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(38, 42, 79, 1),
                                ),
                                children: [
                                  // Tombamento
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumnExemplares ==
                                              'tombamento') {
                                            _isAscendingExemplares =
                                                !_isAscendingExemplares;
                                          } else {
                                            _sortColumnExemplares =
                                                'tombamento';
                                            _isAscendingExemplares = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Tombamento',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumnExemplares ==
                                                    'tombamento'
                                                ? (_isAscendingExemplares
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Título
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumnExemplares ==
                                              'titulo') {
                                            _isAscendingExemplares =
                                                !_isAscendingExemplares;
                                          } else {
                                            _sortColumnExemplares = 'titulo';
                                            _isAscendingExemplares = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Titulo',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumnExemplares == 'titulo'
                                                ? (_isAscendingExemplares
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Situação
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumnExemplares ==
                                              'situacao') {
                                            _isAscendingExemplares =
                                                !_isAscendingExemplares;
                                          } else {
                                            _sortColumnExemplares = 'situacao';
                                            _isAscendingExemplares = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Situação',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumnExemplares == 'situacao'
                                                ? (_isAscendingExemplares
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Estado Físico
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumnExemplares ==
                                              'estado') {
                                            _isAscendingExemplares =
                                                !_isAscendingExemplares;
                                          } else {
                                            _sortColumnExemplares = 'estado';
                                            _isAscendingExemplares = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Estado Físico',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumnExemplares == 'estado'
                                                ? (_isAscendingExemplares
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Cativo
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_sortColumnExemplares ==
                                              'cativo') {
                                            _isAscendingExemplares =
                                                !_isAscendingExemplares;
                                          } else {
                                            _sortColumnExemplares = 'cativo';
                                            _isAscendingExemplares = true;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Cativo',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          Icon(
                                            _sortColumnExemplares == 'cativo'
                                                ? (_isAscendingExemplares
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward)
                                                : Icons.unfold_more,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              for (int x = 0;
                                  x < paginatedExemplares.length;
                                  x++)
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: x % 2 == 0
                                        ? Color.fromRGBO(233, 235, 238, 75)
                                        : Color.fromRGBO(255, 255, 255, 1),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 8),
                                      child: Text(
                                        paginatedExemplares[x].id.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 8),
                                      child: Text(
                                        paginatedExemplares[x].titulo,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            paginatedExemplares[x]
                                                        .statusCodigo ==
                                                    1
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: paginatedExemplares[x]
                                                        .statusCodigo ==
                                                    1
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            paginatedExemplares[x].getStatus,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 8),
                                      child: Text(
                                        paginatedExemplares[x].getEstado,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 8),
                                      child: Text(
                                        paginatedExemplares[x].cativo
                                            ? 'Sim'
                                            : 'Não',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14.5),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          // Paginação dos exemplares
                          if (totalPagesExemplares > 0)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: currentPageExemplares > 1
                                        ? () {
                                            setState(() {
                                              currentPageExemplares--;
                                            });
                                          }
                                        : null,
                                  ),
                                  for (int i = 1;
                                      i <= totalPagesExemplares;
                                      i++)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentPageExemplares = i;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: i == currentPageExemplares
                                              ? const Color.fromARGB(
                                                  255, 38, 42, 79)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Text(
                                          i.toString(),
                                          style: TextStyle(
                                            color: i == currentPageExemplares
                                                ? Colors.white
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: currentPageExemplares <
                                            totalPagesExemplares
                                        ? () {
                                            setState(() {
                                              currentPageExemplares++;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
              ],
            ),
          )
        ],
      ),
    );
  }
}
