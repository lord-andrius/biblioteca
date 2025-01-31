import 'package:biblioteca/data/models/emprestimos_model.dart';
import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
import 'package:biblioteca/data/providers/usuario_provider.dart';

import 'package:flutter/material.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PaginaEmprestimo extends StatefulWidget {
  const PaginaEmprestimo({super.key});

  @override
  State<PaginaEmprestimo> createState() => _PaginaEmprestimoState();
}

class _PaginaEmprestimoState extends State<PaginaEmprestimo> {
  late TextEditingController _searchController;
  late TextEditingController _searchControllerBooks;
  late List<Usuario> _filteredUsers;
  bool search = false;
  bool showSearchBooks = false;
  bool showBooks = false;
  bool showLivrosEmprestados = false;
  int selectOption = -1;
  Exemplar? selectbook;
  Usuario? selectUser;
  late ExemplarProvider providerExemplar;
  late UsuarioProvider providerUsers;
  late String dataDevolucao;
  late String dataEmprestimo;

  late List<Usuario>users;
  late List<Exemplar> exemplares;
  @override
  void initState() {
  super.initState();
  _searchController = TextEditingController();
  _searchControllerBooks = TextEditingController();
  providerExemplar= Provider.of<ExemplarProvider>(context, listen: false);
  providerUsers = Provider.of<UsuarioProvider>(context, listen: false);
  _filteredUsers = [];
  
  // Carregar usuários
  if(providerUsers.users.isEmpty){
      Provider.of<UsuarioProvider>(context, listen: false).loadUsuarios().then((_) {
        setState(() {
        });
      });
    }
    if(providerExemplar.exemplares.isEmpty){
      Provider.of<ExemplarProvider>(context, listen: false).loadExemplares().then((_) {
        setState(() {
        });
      });
    }
}
  @override
  void dispose() {
    _searchController.dispose();
    _searchControllerBooks.dispose();
    super.dispose();
  }

  void searchUsers() {
    final searchQuery = _searchController.text.toLowerCase();
    selectUser = null;
    if(showSearchBooks){
      showBooks = false;
      showSearchBooks = false;
      selectbook = null;
      _searchControllerBooks.text ='';
    }
    setState(() {
      search = true;
      _filteredUsers = users.where((usuario) {
        return usuario.nome.toLowerCase().contains(searchQuery) || usuario.login.contains(searchQuery);
      }).toList();
    });
  }

  void searchBooks() {
  showBooks = true;
  final searchQuery = _searchControllerBooks.text.trim();

  setState(() { 
    if (searchQuery.isEmpty) {
      // Limpa a seleção se o campo estiver vazio
      selectbook = null;
      return;
    }

    final searchId = int.tryParse(searchQuery);
    if (searchId != null) {
      try {
        selectbook = exemplares.firstWhere(
          (exemplar) => exemplar.id == searchId,
        );
      } catch (e) {
        selectbook = null;
      }
     } 
    //Caso aceite busca de exemplar pelo nome
    //else {
    //   // Caso não seja um número, busca por outro critério (ex: nome)
    //   selectbook = exemplares.firstWhere(
    //     (exemplar) => exemplar.titulo.toLowerCase().contains(searchQuery.toLowerCase()),
    //   );
    // }
  });
}
 void getDate(){
  DateTime now = DateTime.now();
  dataEmprestimo = DateFormat('dd/MM/yyyy').format(now);
  
  DateTime dataDevolucaoDate = now.add(const Duration(days: 7));
  dataDevolucao = DateFormat('dd/MM/yyyy').format(dataDevolucaoDate);
 }

String renovar(String dataString) {
  final formato = DateFormat('dd/MM/yyyy');
  final data = formato.parse(dataString);
  final novaData = data.add(const Duration(days: 7));
  return formato.format(novaData);
}
Future<void> msgConfirm(BuildContext context, String msg, EmprestimosModel livro) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Container(
                width: 800,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cabeçalho
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      color: const Color.fromRGBO(38, 42, 79, 1),
                      child: Text(
                        'Confirmação de $msg',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Corpo do diálogo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      child: Column(
                        children: [
                          // Tabela de informações
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(0.08),
                              1: FlexColumnWidth(0.25),
                              2: FlexColumnWidth(0.20),
                              3: FlexColumnWidth(0.20),
                            },
                            border: TableBorder.all(
                              color: const Color.fromARGB(255, 213, 213, 213),
                            ),
                            children: [
                              // Linha de Cabeçalho
                              const TableRow(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 223, 223, 223),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Código',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Nome',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Devolução Prevista',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Situação',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              // Linha de Dados
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 233, 235, 238),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      livro.codigo,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      livro.nome,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      livro.dataDevolucao,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '$msg Realizado!',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Botão de Confirmação
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Fecha o diálogo
                            },
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Botão Fechar
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o diálogo
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    exemplares = providerExemplar.exemplares;
    users = providerUsers.users;
    return Material(
      child: Column(
        children: [
          const BreadCrumb(breadcrumb: ['Início', 'Empréstimo'], icon: Icons.my_library_books_rounded),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 35, right: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pesquisa De Aluno", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 25)),
                const SizedBox(height: 40),
                Row(
                  children: [
                   Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 800,
                          maxHeight: 40,
                          minWidth: 200
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            labelText: "Insira os dados do aluno",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onSubmitted: (value){
                            searchUsers();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: searchUsers,
                      child: const Text("Pesquisar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                if (search)
                  if (_filteredUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nenhum usuário encontrado', style: TextStyle(fontSize: 16)),
                    )
                  
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectUser == null)
                          SizedBox(
                            width: 1100,
                            child: Table(
                              border: TableBorder.all(color: const Color.fromARGB(97, 104, 104, 104)),
                              columnWidths: const {
                                0: FlexColumnWidth(0.42),
                                1: FlexColumnWidth(0.18),
                                2: FlexColumnWidth(0.18),
                                3: FlexColumnWidth(0.36),
                                4: FlexColumnWidth(0.17),
                                5: FlexColumnWidth(0.20),
                              },
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(color:Color.fromARGB(255, 214, 214, 214)),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Nome', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Turma', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Turno', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Email', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Tipo Usuário', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(width: 5),
                                  ],
                                ),
                                for (int x = 0; x < _filteredUsers.length; x++)
                                  TableRow(
                                    decoration: const BoxDecoration(color: Color.fromRGBO(233, 235, 238, 75)),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text(_filteredUsers[x].nome, textAlign: TextAlign.left),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text(_filteredUsers[x].getTurma, textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text(_filteredUsers[x].getTurno, textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text(_filteredUsers[x].email, textAlign: TextAlign.left),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text(_filteredUsers[x].getTipoDeUsuario, textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                          ),
                                          onPressed: () {
                                              showSearchBooks = true;
                                              setState(() {
                                                selectUser = _filteredUsers[x];
                                              });
                                          },
                                          child: const Text('Selecionar Leitor', style: TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        if (selectUser != null)
                          SizedBox(
                            width: 1100,
                            child: Column(
                              children: [
                                Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 6.5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:  const Color.fromARGB(97, 104, 104, 104)
                                      ),
                                      color:   const Color.fromARGB(255, 214, 214, 214)
                                    ),
                                    child: Text(
                                      "Usuário Selecionado",
                                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                Table(
                                  border: TableBorder.all(color: const Color.fromARGB(97, 104, 104, 104)),
                                  columnWidths: const {
                                    0: FlexColumnWidth(0.50),
                                    1: FlexColumnWidth(0.15),
                                    2: FlexColumnWidth(0.15),
                                    3: FlexColumnWidth(0.35),
                                    4: FlexColumnWidth(0.15),
                                  },
                                  children: [
                                    const TableRow(
                                      decoration: BoxDecoration(color:Color.fromARGB(255, 214, 214, 214)),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Nome', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Turma', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Turno', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Email', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Tipo Usuário', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      decoration: const BoxDecoration(color: Color.fromRGBO(233, 235, 238, 75)),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.nome, textAlign: TextAlign.left),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.getTurma, textAlign: TextAlign.center),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.getTurno, textAlign: TextAlign.center),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.email, textAlign: TextAlign.left),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(selectUser!.getTipoDeUsuario, textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                
                                if(selectUser != null && selectUser!.livrosEmprestados.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 6.5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:  const Color.fromARGB(97, 104, 104, 104)
                                      ),
                                      color:   const Color.fromARGB(255, 214, 214, 214)
                                    ),
                                    child: Text(
                                      "Livros Emprestados",
                                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                if(selectUser != null && selectUser!.livrosEmprestados.isNotEmpty)
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(0.08),
                                      1: FlexColumnWidth(0.26),
                                      2: FlexColumnWidth(0.16),
                                      3: FlexColumnWidth(0.16),
                                      4: FlexColumnWidth(0.15),
                                      
                                    },
                                    border: TableBorder.all(color: const Color.fromARGB(97, 104, 104, 104)),
                                    children: [
                                      const TableRow(
                                          decoration: BoxDecoration(color: Color.fromARGB(255, 214, 214, 214)),
                                          children: [
                                             Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Codigo', textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Text('Nome', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Text('Data de Empréstimo', textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Text('Data de Devolução', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            SizedBox.shrink()
                                          ]
                                        ),
                                      for (int x = 0; x < selectUser!.livrosEmprestados.length; x++)
                                        TableRow(
                                          decoration: const BoxDecoration(color: Color.fromRGBO(233, 235, 238, 75)),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                              child: Text(selectUser!.livrosEmprestados[x].codigo, textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                              child: Text(selectUser!.livrosEmprestados[x].nome, textAlign: TextAlign.left),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                              child: Text(selectUser!.livrosEmprestados[x].dataEmprestimo, textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                              child: Text(selectUser!.livrosEmprestados[x].dataDevolucao, textAlign: TextAlign.center),
                                            ),
                                            Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                            child: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.orange[400],
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                selectUser!.livrosEmprestados[x].dataDevolucao = renovar(selectUser!.livrosEmprestados[x].dataDevolucao);
                                              });
                                              msgConfirm(context, 'Renovação', selectUser!.livrosEmprestados[x]);
                                            },
                                            child: const Text('Renovar', style: TextStyle(color:  Colors.white, fontSize: 12), textAlign: TextAlign.center),
                                          ),
                                        ),
                                          ]
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (showSearchBooks)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 50),
                                Text("Pesquisar Exemplar", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
                                const SizedBox(height: 40),
                                Row(
                                  children: [
                                    Flexible(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                        maxWidth: 900,
                                        maxHeight: 40,
                                        minWidth: 200
                                       ),
                                        child: TextField(
                                          controller: _searchControllerBooks,
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.search),
                                            labelText: "Insira os dados do livro",
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                          ),
                                          onSubmitted: (value){
                                            searchBooks();
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                          backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      onPressed: searchBooks,
                                      child: const Text("Pesquisar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                if(showBooks)
                                  if (selectbook == null)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Nenhum exemplar encontrado', style: TextStyle(fontSize: 16)),
                                    )
                                  else
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 1100,
                                          child: Table(
                                            border: TableBorder.all(color: const Color.fromARGB(97, 104, 104, 104)),
                                            columnWidths: const {
                                              0: FlexColumnWidth(0.10),
                                              1: FlexColumnWidth(0.25),
                                              2: FlexColumnWidth(0.14),
                                              3: FlexColumnWidth(0.15),
                                              4: FlexColumnWidth(0.09),
                                              5: FlexColumnWidth(0.13),
                                            },
                                            children: [
                                              const TableRow(
                                                decoration: BoxDecoration(color: Color.fromARGB(255, 214, 214, 214)),
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Tombamento', textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Titulo', textAlign: TextAlign.left, style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Ano de Publicação', textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Editora', textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Cativo', textAlign: TextAlign.center, style:TextStyle(fontWeight: FontWeight.bold)),
                                                  ),
                                                  SizedBox.shrink()
                                                ],
                                              ),
                                                TableRow(
                                                  decoration: const BoxDecoration(color: Color.fromRGBO(233, 235, 238, 75)),
                                                  children: [
                                                       Padding(
                                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                                        child: Text(selectbook!.id.toString(), textAlign: TextAlign.center),
                                                      ),
                                                    
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                                      child: Text(selectbook!.titulo, textAlign: TextAlign.left),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                                      child: Text(DateFormat('dd/MM/yyyy').format(selectbook!.anoPublicacao), textAlign: TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                                      child: Text(selectbook!.editora, textAlign: TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                                      child: Text(selectbook!.cativo?'Sim': 'Não', textAlign: TextAlign.center),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                                      child: TextButton(
                                                        style: TextButton.styleFrom(
                                                          backgroundColor: Colors.green[400],
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                        ),
                                                        onPressed: () {
                                                          showLivrosEmprestados = true;
                                                          getDate();
                                                          setState(() {
                                                            users[users.indexOf(selectUser!)].livrosEmprestados.add(EmprestimosModel(selectbook!.id.toString(),selectbook!.titulo, dataEmprestimo, dataDevolucao));
                                                          });
                                                          msgConfirm(context, 'Empréstimo', selectUser!.livrosEmprestados.last);
                                                        },
                                                        child: const Text('Emprestar', style: TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                const SizedBox(height: 150,)
                              ],
                            ),
                      ],
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

