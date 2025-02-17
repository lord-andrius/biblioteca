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
  late List<Exemplar> exemplaresSelecionadosEmprestimo =[];

  late List<Usuario> users;
  late List<Exemplar> exemplares;

  late List<Exemplar> selectedBoxExemplar = [];
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchControllerBooks = TextEditingController();
    providerExemplar = Provider.of<ExemplarProvider>(context, listen: false);
    providerUsers = Provider.of<UsuarioProvider>(context, listen: false);
    _filteredUsers = [];

    // Carregar usuários
    if (providerUsers.users.isEmpty) {
      Provider.of<UsuarioProvider>(context, listen: false)
          .loadUsuarios()
          .then((_) {
        setState(() {});
      });
    }
    if (providerExemplar.exemplares.isEmpty) {
      Provider.of<ExemplarProvider>(context, listen: false)
          .loadExemplares()
          .then((_) {
        setState(() {});
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
    if (showSearchBooks) {
      showBooks = false;
      showSearchBooks = false;
      selectbook = null;
      _searchControllerBooks.text = '';
    }
    setState(() {
      search = true;
      _filteredUsers = users.where((usuario) {
        return usuario.nome.toLowerCase().contains(searchQuery) ||
            usuario.login.contains(searchQuery);
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Exemplar não encontrado!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
              ),
              duration: Duration(seconds: 2),
            )
          );
        }
        
        if(selectbook!=null){
          if(selectUser!.livrosEmprestados.any((e)=> e.codigo == selectbook!.id.toString() )){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  "Exemplar já emprestado para o aluno!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 2),
              )
            );
          }else if(!selectedBoxExemplar.contains(selectbook)){
            if(selectbook!.statusCodigo !=1){
              msgIndisponivel(selectbook!);
            }else{
              setState(() {
                selectedBoxExemplar.add(selectbook!);
              });
            }
          }else{
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content:  Text(
                  'Exemplar já adicionado!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              duration: Duration(seconds: 2),
              )
            );
          }
        }
      }
    });
  }
  Future<void> msgIndisponivel(Exemplar exemplar){
    return showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
        title: const Text(
          'Exemplar indisponível para empréstimo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        content: Container(
          width: 800,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(0.08),
              1: FlexColumnWidth(0.15),
              2: FlexColumnWidth(0.10),
              3: FlexColumnWidth(0.11)
            },
            border:TableBorder.all(
              color: const Color.fromARGB(215, 200, 200, 200)
            ),
            children: [
              const TableRow(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 44, 62, 80)
                ),
                children:[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Tombamento",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Título",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Ano de Publicação",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Situação",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                    ), 
                  )
                ]
              ),
              TableRow(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(233, 235, 238, 75)
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      exemplar.id.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      exemplar.titulo,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14)
                    ),
                  )
                  ,Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      DateFormat('dd/MM/YYYY').format(exemplar.anoPublicacao),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14) 
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                        exemplar.statusCodigo == 1? Icons.check_circle: Icons.cancel, 
                        color: exemplar.statusCodigo == 1? Colors.green: Colors.red,
                        ),
                        SizedBox(width: 5,),
                        Text(
                          exemplar.getStatus,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14)
                        ),
                      ],
                    ),
                  )
                ]
              )
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(11),
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                }, 
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                   fontSize: 15.5
                  ),
                )
             ),
             if(exemplar.statusCodigo == 1)
                Row(
                  children: [
                    SizedBox(width: 20),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(11),
                        backgroundColor: Colors.green[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                        )
                      ),
                      onPressed: (){
                        setState(() {
                          selectedBoxExemplar.add(exemplar);
                        });
                        Navigator.of(context).pop();  
                      }, 
                      child: const Text(
                        'Selecionar',
                        style: TextStyle(
                          fontSize: 15.5   
                        )
                      )
                    )
                  ],
                )
            ],
          )
        ],
      )
    );
  }
  Future<void> msgConfirm(
      BuildContext context, String msg, EmprestimosModel livro) {
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
                  padding: EdgeInsets.only(top: 10),
                  width: 800,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cabeçalho
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        child: Text(
                          'Confirmação de $msg',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Corpo do diálogo
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
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
                                color: const Color.fromARGB(215, 200, 200, 200),
                              ),
                              children: [
                                // Linha de Cabeçalho
                                const TableRow(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 44, 62, 80),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Código',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Nome',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Devolução Prevista',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Situação',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                            ),
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
                // Positioned(
                //   right: 0,
                //   child: IconButton(
                //     icon: const Icon(Icons.close, color: Colors.red),
                //     onPressed: () {
                //       Navigator.of(context).pop(); // Fecha o diálogo
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> msgConfirmEmprestimo(List<Exemplar> exemplaresEmpres){
    return showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
        title: const Text(
          'Confirmação de Empréstimo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        content: Container(
          width: 800,
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(0.08),
              1: FlexColumnWidth(0.15),
              2: FlexColumnWidth(0.10),
              3: FlexColumnWidth(0.11)
            },
            border:TableBorder.all(
              color: const Color.fromARGB(215, 200, 200, 200)
            ),
            children: [
              const TableRow(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 44, 62, 80)
                ),
                children:[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Tombamento",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Título",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Ano de Publicação",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Situação",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                    ), 
                  )
                ]
              ),
              for(Exemplar exemplar in exemplaresEmpres)
                TableRow(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(233, 235, 238, 75)
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        exemplar.id.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14)
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        exemplar.titulo,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14)
                      ),
                    )
                    ,Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('dd/MM/YYYY').format(exemplar.anoPublicacao),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14) 
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: 
                          Text(
                            'Empréstimo realizado!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Colors.green[400])
                          ),
                    )
                  ]
                )
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(11),
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                }, 
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                   fontSize: 15.5
                  ),
                )
             ),
            ],
          )
        ],
      )
    );
  }
  void getDate() {
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

  @override
  Widget build(BuildContext context) {
    exemplares = providerExemplar.exemplares;
    users = providerUsers.users;
    return Material(
      child: Column(
        children: [
          const BreadCrumb(
              breadcrumb: ['Início', 'Empréstimo'],
              icon: Icons.my_library_books_rounded),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 35, right: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pesquisa De Aluno",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold, 
                        fontSize: 26)
                    ),
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
                            labelText: "Insira o nome do aluno",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onSubmitted: (value) {
                            searchUsers();
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
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: searchUsers,
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.white,),
                          SizedBox(width: 3,),
                          Text(
                            "Pesquisar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.5
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                if (search)
                  if (_filteredUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nenhum usuário encontrado',
                          style: TextStyle(fontSize: 16)),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectUser == null)
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 1210,
                              minHeight: 800
                            ),
                            child: Table(
                              border: TableBorder.all(
                                  color:const Color.fromARGB(215, 200, 200, 200)
                              ),
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
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 44, 62, 80)
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                          'Nome',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                                            ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Turma',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Turno',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Email',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Tipo Usuário',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Ação',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                    )
                                  ],
                                ),
                                for (int x = 0; x < _filteredUsers.length; x++)
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: x % 2 == 0?Color.fromRGBO(233, 235, 238, 75): Color.fromRGBO(255, 255, 255, 1)
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                        child: Text(_filteredUsers[x].nome,
                                              textAlign: TextAlign.left, 
                                              style: TextStyle(
                                              fontWeight: FontWeight.w300, 
                                              fontSize: 14.5
                                             )
                                            ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                        child: Text(
                                              _filteredUsers[x].getTurma,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)
                                            ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                        child: Text(
                                              _filteredUsers[x].getTurno,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)
                                            ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                        child: Text(
                                              _filteredUsers[x].email,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)
                                            ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                        child: Text(
                                              _filteredUsers[x].getTipoDeUsuario,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)
                                            
                                            ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 14,
                                        ),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 45, 106, 79),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                          ),
                                          onPressed: () {
                                            showSearchBooks = true;
                                            setState(() {
                                              selectUser = _filteredUsers[x];
                                            });
                                          },
                                          child: const Text('Selecionar',
                                              style: TextStyle(
                                                color: const Color.fromARGB(255, 250, 244, 244),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        if (selectUser != null)
                          SizedBox(
                            width: 1150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.5),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(230,227, 242, 253),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4),
                                          child: Row(
                                            children: [
                                              Icon(Icons.person, color: Color.fromARGB(255,46, 125, 50), size: 26,),
                                              SizedBox(width: 7,),
                                              Text(
                                                "Usuário Selecionado",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium!
                                                    .copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 21,
                                                      color: Colors.black,
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(thickness: 2, color: Colors.grey[400]),
                                        const SizedBox(height: 10,),
                                        Table(
                                          border: TableBorder.all(
                                            color: const Color.fromARGB(215, 200, 200, 200)
                                          ),
                                          columnWidths: const {
                                            0: FlexColumnWidth(0.50),
                                            1: FlexColumnWidth(0.15),
                                            2: FlexColumnWidth(0.15),
                                            3: FlexColumnWidth(0.35),
                                            4: FlexColumnWidth(0.15),
                                          },
                                          children: [
                                            const TableRow(
                                              decoration: BoxDecoration(
                                                  color: Color.fromARGB(255, 44, 62, 80)
                                              ),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Nome',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Turma',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Turno',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Email',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Tipo Usuário',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                              ],
                                            ),
                                            TableRow(
                                              decoration: const BoxDecoration(
                                                  color: Color.fromRGBO(233, 235, 238, 75)),
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                  child: Text(
                                                        selectUser!.nome,
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5)
                                                      ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                  child: Text(
                                                        selectUser!.getTurma,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5)
                                                      ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                  child: Text(
                                                        selectUser!.getTurno,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5)
                                                      ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                  child: Text(selectUser!.email,
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5)
                                                      ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                        selectUser!.getTipoDeUsuario,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5)
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (selectUser != null && selectUser!.livrosEmprestados.isNotEmpty)
                                  Column(
                                    children: [
                                      const SizedBox(height: 60),
                                      Padding(
                                              padding: const EdgeInsets.only(left: 4),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.library_books, color: Color.fromARGB(255,46, 125, 50), size: 25,),
                                                  SizedBox(width: 8,),
                                                  Text(
                                                    "Exemplares Emprestados",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20.3,
                                                          color: Colors.black,
                                                        ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                if (selectUser != null && selectUser!.livrosEmprestados.isNotEmpty)
                                  Column(
                                    children: [
                                      Divider(thickness: 2, color: Colors.grey[400]),
                                      SizedBox(height: 10),
                                      Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(0.08),
                                          1: FlexColumnWidth(0.26),
                                          2: FlexColumnWidth(0.14),
                                          3: FlexColumnWidth(0.14),
                                          4: FlexColumnWidth(0.15),
                                        },
                                        border: TableBorder.all(
                                          color: const Color.fromARGB(215, 200, 200, 200),
                                        ),
                                        children: [
                                          const TableRow(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(255, 44, 62, 80),
                                              ),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Tombamento',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(7.0),
                                                  child: Text('Nome',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(7.0),
                                                  child: Text('Data de Empréstimo',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                                
                                                Padding(
                                                  padding: EdgeInsets.all(7.0),
                                                  child: Text('Data de Devoluçao',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                                
                                                Padding(
                                                  padding: EdgeInsets.all(7.0),
                                                  child: Text('Ação',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                                                ),
                                              ]),
                                          for (int x = 0; x <selectUser!.livrosEmprestados.length; x++)
                                            TableRow(
                                                decoration: BoxDecoration(
                                                  color: x % 2 == 0?Color.fromRGBO(233, 235, 238, 75): Color.fromRGBO(255, 255, 255, 1),
                                                ),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 9.4, horizontal: 8),
                                                    child: Text(
                                                        selectUser!
                                                            .livrosEmprestados[x]
                                                            .codigo,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(fontWeight: FontWeight.w300,fontSize: 14.5)
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 9.4, horizontal: 8),
                                                    child: Text(
                                                        selectUser!
                                                            .livrosEmprestados[x]
                                                            .nome,
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(fontWeight: FontWeight.w300,fontSize: 14.5)
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 9.4, horizontal: 8),
                                                    child: Text(
                                                        selectUser!
                                                            .livrosEmprestados[x]
                                                            .dataEmprestimo,
                                                        textAlign:
                                                            TextAlign.center,
                                                            style: TextStyle(fontWeight: FontWeight.w300,fontSize: 14.5)
                                                            ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 9.4, horizontal: 8),
                                                    child: Text(
                                                        selectUser!
                                                            .livrosEmprestados[x]
                                                            .dataDevolucao,
                                                        textAlign:
                                                            TextAlign.center,
                                                            style: TextStyle(fontWeight: FontWeight.w300,fontSize: 14.5)
                                                            ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                     vertical: 6,
                                                      horizontal: 37,
                                                    ),
                                                   
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                    
                                                    backgroundColor:
                                                        Colors.orange[400],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      selectUser!
                                                              .livrosEmprestados[x]
                                                              .dataDevolucao =
                                                          renovar(selectUser!
                                                              .livrosEmprestados[
                                                                  x]
                                                              .dataDevolucao);
                                                    });
                                                    msgConfirm(
                                                        context,
                                                        'Renovação',
                                                        selectUser!
                                                            .livrosEmprestados[x]);
                                                    
                                                  },
                                                  child: const Text('Renovar',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w400
                                                          ),
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                              )
                                                ]),
                                        ],
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
                              const Divider(),
                              const SizedBox(height: 50),
                              Text("Pesquisar Exemplar",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26)),
                              const SizedBox(height: 40),
                              Row(
                                children: [
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth: 900,
                                          maxHeight: 40,
                                          minWidth: 200),
                                      child: TextField(
                                        controller: _searchControllerBooks,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.search),
                                          labelText: "Insira o número do tombamento",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
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
                                        backgroundColor:
                                            const Color.fromRGBO(38, 42, 79, 1),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onPressed: searchBooks,
                                    child: const Row(
                                      children: [
                                        Icon(Icons.add, color: Colors.white,),
                                        SizedBox(width: 3,),
                                        Text(
                                          "Adicionar",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.5
                                          )
                                        ),
                                      ],
                                    )
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              if (showBooks)
                                if(selectedBoxExemplar.isNotEmpty)
                                  Column(
                                    children: [
                                          SizedBox(
                                            width: 1150,
                                            child: Row(
                                              children: [
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                      horizontal: 15
                                                    ),
                                                    foregroundColor: Colors.white,
                                                    backgroundColor: Colors.green[400],
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)
                                                    )
                                                  ),
                                                  onPressed: (){
                                                    getDate();
                                                    showLivrosEmprestados;
                                                    for (Exemplar exemplar in List.from(selectedBoxExemplar)){
                                                      if(exemplar.checkbox == true){
                                                        exemplaresSelecionadosEmprestimo.add(exemplar);
                                                        selectUser!.livrosEmprestados.add(EmprestimosModel(exemplar.id.toString(), exemplar.titulo, dataEmprestimo, dataDevolucao));
                                                        selectedBoxExemplar.remove(exemplar);
                                                      }
                                                    }
                                                    setState(() {
                                                      
                                                    });
                                                    msgConfirmEmprestimo(exemplaresSelecionadosEmprestimo);
                                                    exemplaresSelecionadosEmprestimo = [];
                                                  }, 
                                                  child: const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.outbox,
                                                        color: Colors.white,
                                                        size: 23,
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Text(
                                                        'Emprestar',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w400
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ),
                                                const SizedBox(width: 15,),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding:const  EdgeInsets.symmetric(
                                                      vertical: 14,
                                                      horizontal: 20
                                                    ),
                                                    foregroundColor: Colors.white,
                                                    backgroundColor: Colors.red[400],
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)
                                                    )
                                                  ),
                                                  onPressed: (){
                                                    for(Exemplar exemplar in List.from(selectedBoxExemplar)){
                                                      if(exemplar.checkbox == true){
                                                        selectedBoxExemplar.remove(exemplar);
                                                      }
                                                    }
                                                    setState(() {

                                                    });
                                                  }, 
                                                  child: const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                        size: 23,
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Text(
                                                        'Remover',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w400
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ),
                                              ],
                                            ),
                                          ),
                                      SizedBox(height: 30,),
                                      SizedBox(
                                        width: 1150,
                                        child: Table(
                                          border: TableBorder.all(
                                            color:const Color.fromARGB(215, 200, 200, 200)
                                          ),
                                          columnWidths: const {
                                            0:FlexColumnWidth(0.05),
                                            1: FlexColumnWidth(0.08),
                                            2: FlexColumnWidth(0.25),
                                            3: FlexColumnWidth(0.12),
                                            4: FlexColumnWidth(0.14),
                                            5: FlexColumnWidth(0.10),
                                          },
                                          children: [
                                            const TableRow(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(255, 44, 62, 80)
                                              ),
                                              children: [
                                                SizedBox.shrink(),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Tombamento',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Titulo',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Ano de Publicação',
                                                    textAlign:TextAlign.center,
                                                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Editora',
                                                    textAlign:
                                                    TextAlign.center,
                                                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Cativo',
                                                    textAlign:
                                                    TextAlign.center,
                                                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)
                                                  ),
                                                ),
                                              ],
                                            ),
                                            for(int x=0; x < selectedBoxExemplar.length; x++)
                                              TableRow(
                                                decoration: BoxDecoration(
                                                  color: x % 2 == 0?Color.fromRGBO(233, 235, 238, 75): Color.fromRGBO(255, 255, 255, 1)
                                                ),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8),
                                                    child: Checkbox(
                                                      value: selectedBoxExemplar[x].checkbox, 
                                                      onChanged: (value){
                                                        setState(() {
                                                          selectedBoxExemplar[x].checkbox = value!;
                                                        });
                                                      }
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:13, bottom: 9, left:8, right:8),
                                                    child: Text(
                                                        selectedBoxExemplar[x].id.toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:13, bottom: 9, left:8, right:8),
                                                    child: Text(
                                                        selectedBoxExemplar[x].titulo,
                                                        textAlign:
                                                            TextAlign.left,
                                                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:13, bottom: 9, left:8, right:8),
                                                    child: Text(
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(selectedBoxExemplar[x]
                                                                .anoPublicacao),
                                                        textAlign:
                                                            TextAlign.center,
                                                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:13, bottom: 9, left:8, right:8),
                                                    child: Text(
                                                        selectedBoxExemplar[x].editora,
                                                        textAlign:
                                                            TextAlign.center,
                                                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)
                                                            ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top:13, bottom: 9, left:8, right:8),
                                                    child: Text(
                                                        selectedBoxExemplar[x].cativo
                                                            ? 'Sim'
                                                            : 'Não',
                                                        textAlign:
                                                            TextAlign.center,
                                                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)    
                                                        ),
                                                  ),
                                                ],
                                              ),
                                          ],  
                                        ),
                                      ),
                                    ],
                                  ),
                              const SizedBox(
                                height: 150,
                              )
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


                                              
                                            