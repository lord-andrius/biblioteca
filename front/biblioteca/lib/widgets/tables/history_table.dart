// ignore_for_file: use_build_context_synchronously
import 'package:biblioteca/data/models/emprestimos_model.dart';
import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/data/providers/emprestimo_provider.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryTablePage extends StatefulWidget {
  const HistoryTablePage({super.key, this.usuario});
  final Usuario? usuario;

  @override
  HistoryTablePageState createState() => HistoryTablePageState();
}

class HistoryTablePageState extends State<HistoryTablePage> {
  int rowsPerPage = 10;
  final List<int> rowsPerPageOptions = [5, 10, 15, 20];
  int currentPage = 1;

  bool _isLoading = true;
  late List<EmprestimosModel> emprestimos;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  String _sortColumn =
      'tombamento'; // 'tombamento', 'livro', 'dataEmprestimo', 'dataDevolucao', 'status'
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    emprestimos = [];
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (widget.usuario != null) {
      await carregarEmprestimosUsuario(widget.usuario!.idDoUsuario);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : getPage();
  }

  Future<void> carregarEmprestimosUsuario(int idUsuario) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<EmprestimosModel> fetchEmprestimos =
          await Provider.of<EmprestimoProvider>(context, listen: false)
              .fetchEmprestimosUsuario(idUsuario);

      setState(() {
        emprestimos = fetchEmprestimos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        emprestimos = [];
      });
    }
  }

  Material getPage() {
    if (emprestimos.isEmpty) {
      return const Material(
        child: Column(
          children: [
            BreadCrumb(
                breadcrumb: ["Início", "Usuários", "Histórico"],
                icon: Icons.co_present_rounded),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 250, horizontal: 40),
              child: Column(
                children: [
                  Text('Nenhum empréstimo encontrado'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    List<EmprestimosModel> filteredEmprestimos = emprestimos;
    if (_searchText.isNotEmpty) {
      filteredEmprestimos = filteredEmprestimos
          .where((e) =>
              e.exemplarMap['IdDoExemplarLivro']
                  .toString()
                  .contains(_searchText) ||
              (e.exemplarMap['Livro']['Titulo'] as String)
                  .toLowerCase()
                  .contains(_searchText) ||
              _formatDate(e.dataEmprestimo).contains(_searchText) ||
              _formatDate(e.dataDeDevolucao).contains(_searchText) ||
              _getStatusText(e.status).toLowerCase().contains(_searchText))
          .toList();
    }

    // Sorting
    filteredEmprestimos.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'tombamento':
          cmp = a.exemplarMap['IdDoExemplarLivro']
              .toString()
              .compareTo(b.exemplarMap['IdDoExemplarLivro'].toString());
          break;
        case 'livro':
          cmp = (a.exemplarMap['Livro']['Titulo'] as String)
              .toLowerCase()
              .compareTo(
                  (b.exemplarMap['Livro']['Titulo'] as String).toLowerCase());
          break;
        case 'dataEmprestimo':
          cmp = a.dataEmprestimo.compareTo(b.dataEmprestimo);
          break;
        case 'dataDevolucao':
          cmp = a.dataDeDevolucao.compareTo(b.dataDeDevolucao);
          break;
        case 'status':
          cmp = _getStatusText(a.status).compareTo(_getStatusText(b.status));
          break;
        default:
          cmp = 0;
      }
      return _isAscending ? cmp : -cmp;
    });

    int totalPages = (filteredEmprestimos.length / rowsPerPage).ceil();
    int startIndex = (currentPage - 1) * rowsPerPage;
    int endIndex = (startIndex + rowsPerPage) < filteredEmprestimos.length
        ? (startIndex + rowsPerPage)
        : filteredEmprestimos.length;

    List<EmprestimosModel> paginatedEmprestimos =
        filteredEmprestimos.sublist(startIndex, endIndex);

    return Material(
      child: Column(
        children: [
          const BreadCrumb(
              breadcrumb: ["Início", "Usuários", "Histórico"],
              icon: Icons.co_present_rounded),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.usuario != null)
                  Text(
                    'Histórico de ${widget.usuario!.nome}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 38, 42, 79),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.menu_book,
                        color: Color.fromARGB(255, 38, 42, 79)),
                    const SizedBox(width: 6),
                    Text(
                      'Total de empréstimos: ${emprestimos.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 38, 42, 79),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Icon(Icons.schedule, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      'Em andamento: ${emprestimos.where((e) => e.status == 1).length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 38, 42, 79),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      'Concluído: ${emprestimos.where((e) => e.status == 3).length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 38, 42, 79),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 40),
            child: Column(
              children: [
                _buildPaginationControls(),
                const SizedBox(height: 16), // espaçamento padrao via gambiarra
                _buildTable(paginatedEmprestimos),
                _buildPaginationButtons(totalPages),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
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
                items: rowsPerPageOptions.map((int value) {
                  return DropdownMenuItem<int>(
                      value: value, child: Text(value.toString()));
                }).toList(),
              ),
              const SizedBox(width: 8),
              const Text('registros por página'),
            ],
          ),
          // Pesquisar
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                  currentPage = 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<EmprestimosModel> paginatedEmprestimos) {
    return Table(
      border: TableBorder.all(color: const Color.fromARGB(215, 200, 200, 200)),
      columnWidths: const {
        0: FlexColumnWidth(0.10),
        1: FlexColumnWidth(0.35),
        2: FlexColumnWidth(0.15),
        3: FlexColumnWidth(0.15),
        4: FlexColumnWidth(0.15),
      },
      children: [
        TableRow(
          decoration:
              const BoxDecoration(color: Color.fromARGB(255, 38, 42, 79)),
          children: [
            // Tombamento
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_sortColumn == 'tombamento') {
                      _isAscending = !_isAscending;
                    } else {
                      _sortColumn = 'tombamento';
                      _isAscending = true;
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
                      _sortColumn == 'tombamento'
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
            // Livro
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_sortColumn == 'livro') {
                      _isAscending = !_isAscending;
                    } else {
                      _sortColumn = 'livro';
                      _isAscending = true;
                    }
                  });
                },
                child: Row(
                  children: [
                    const Text(
                      'Livro',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 15),
                    ),
                    Icon(
                      _sortColumn == 'livro'
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
            // Data Empréstimo
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_sortColumn == 'dataEmprestimo') {
                      _isAscending = !_isAscending;
                    } else {
                      _sortColumn = 'dataEmprestimo';
                      _isAscending = true;
                    }
                  });
                },
                child: Row(
                  children: [
                    const Text(
                      'Data Empréstimo',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 15),
                    ),
                    Icon(
                      _sortColumn == 'dataEmprestimo'
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
            // Data Devolução
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_sortColumn == 'dataDevolucao') {
                      _isAscending = !_isAscending;
                    } else {
                      _sortColumn = 'dataDevolucao';
                      _isAscending = true;
                    }
                  });
                },
                child: Row(
                  children: [
                    const Text(
                      'Data Devolução',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 15),
                    ),
                    Icon(
                      _sortColumn == 'dataDevolucao'
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
            // Status
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_sortColumn == 'status') {
                      _isAscending = !_isAscending;
                    } else {
                      _sortColumn = 'status';
                      _isAscending = true;
                    }
                  });
                },
                child: Row(
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 15),
                    ),
                    Icon(
                      _sortColumn == 'status'
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
          ],
        ),
        for (int x = 0; x < paginatedEmprestimos.length; x++)
          TableRow(
            decoration: BoxDecoration(
              color: x % 2 == 0
                  ? const Color.fromRGBO(233, 235, 238, 75)
                  : const Color.fromRGBO(255, 255, 255, 1),
            ),
            children: [
              _buildTableCell(paginatedEmprestimos[x]
                  .exemplarMap['IdDoExemplarLivro']
                  .toString()),
              _buildTableCell(
                  paginatedEmprestimos[x].exemplarMap['Livro']['Titulo']),
              _buildDateCell(
                  _formatDate(paginatedEmprestimos[x].dataEmprestimo)),
              _buildDateCell(
                (paginatedEmprestimos[x].status == 2 ||
                            paginatedEmprestimos[x].status == 3) &&
                        paginatedEmprestimos[x].dataDeDevolucao.isNotEmpty
                    ? _formatDate(paginatedEmprestimos[x].dataDeDevolucao)
                    : '-',
              ),
              _buildStatusCell(paginatedEmprestimos[x].status),
            ],
          ),
      ],
    );
  }

  Widget _buildTableCell(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDateCell(String text) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCell(int status) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getStatusColor(status).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            _getStatusText(status),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 14.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButtons(int totalPages) {
    int startPage = currentPage - 4 < 1 ? 1 : currentPage - 4;
    int endPage = startPage + 8 > totalPages ? totalPages : startPage + 8;
    if (endPage - startPage < 8 && startPage > 1) {
      startPage = endPage - 8 < 1 ? 1 : endPage - 8;
    }

    return Padding(
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
          for (int i = startPage; i <= endPage; i++)
            GestureDetector(
              onTap: () {
                setState(() {
                  currentPage = i;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: i == currentPage
                      ? Color.fromARGB(255, 38, 42, 79)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  i.toString(),
                  style: TextStyle(
                    color: i == currentPage ? Colors.white : Colors.grey,
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
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Em Andamento';
      case 2:
        return 'Entregue com Atraso';
      case 3:
        return 'Concluído';
      default:
        return 'Status Desconhecido';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '-';
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}
