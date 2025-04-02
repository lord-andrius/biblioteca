// ignore_for_file: use_build_context_synchronously
import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/data/providers/usuario_provider.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';

class UserTablePage extends StatefulWidget {
  const UserTablePage({super.key});

  @override
  UserTablePageState createState() => UserTablePageState();
}

class UserTablePageState extends State<UserTablePage> {
  //TextEditingController _buscaController = TextEditingController();

  int rowsPerPage = 10; // Quantidade de linhas por página
  final List<int> rowsPerPageOptions = [5, 10, 15, 20];
  int currentPage = 1; // Página atual

  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<UsuarioProvider>(context).loadUsuarios().then((_) => {
            setState(() {
              _isLoading = false;
            })
          });
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : getPage();
  }

  Material getPage() {
    UsuarioProvider provider = Provider.of<UsuarioProvider>(context);
    List<Usuario> users = provider.users;
    int totalPages = (users.length / rowsPerPage).ceil();

    // Calcula o índice inicial e final dos usuários exibidos
    int startIndex = (currentPage - 1) * rowsPerPage;
    int endIndex = (startIndex + rowsPerPage) < users.length
        ? (startIndex + rowsPerPage)
        : users.length;

    // Seleciona os usuários que serão exibidos na página atual
    List<Usuario> paginatedUsers = users.sublist(startIndex, endIndex);

    // Lógica para definir os botões de página (máximo 10 botões)
    int startPage = currentPage - 4 < 1 ? 1 : currentPage - 4;
    int endPage = startPage + 8 > totalPages ? totalPages : startPage + 8;
    if (endPage - startPage < 8 && startPage > 1) {
      startPage = endPage - 8 < 1 ? 1 : endPage - 8;
    }

    return Material(
      child: Column(
        children: [
          // Barra de navegação
          const BreadCrumb(
              breadcrumb: ["Início", "Usuários"],
              icon: Icons.co_present_rounded),

          // Corpo da página
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
            child: Column(
              // Botão novo usuário
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.novoUsuario);
                      },
                      label: const Text(
                        'Novo Usuário',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      icon: const Icon(Icons.add),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.green.shade800),
                        foregroundColor:
                            const WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(15.0), // Padding personalizado
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),

                // Tabela de usuários
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    children: [
                      const Text('Exibir '),
                      DropdownButton<int>(
                        value: rowsPerPage,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              rowsPerPage = value;
                              currentPage =
                                  1; // Reinicia para a primeira página
                            });
                          }
                        },
                        items: rowsPerPageOptions.map((int value) {
                          return DropdownMenuItem<int>(
                              value: value, child: Text(value.toString()));
                        }).toList(),
                      ),
                      const Text(' registros por página'),
                    ],
                  ),
                ),
                Table(
                  border: TableBorder.all(
                      color: const Color.fromARGB(215, 200, 200, 200)),
                  columnWidths: const {
                    0: FlexColumnWidth(0.30),
                    1: FlexColumnWidth(0.17),
                    2: FlexColumnWidth(0.15),
                    3: FlexColumnWidth(0.15),
                    4: FlexColumnWidth(0.17),
                    5: IntrinsicColumnWidth(),
                  },
                  children: [
                    // Cabeçalho da tabela
                    const TableRow(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 44, 62, 80)
                      ),
                      children: [
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Nome',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15))),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Turma',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Turno',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Login',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tipo de Usuario',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Opções',
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
                        ),
                      ],
                    ),

                    // Linhas da tabela
                    for (int x = 0; x <paginatedUsers.length; x++)
                      TableRow(
                        decoration: BoxDecoration(
                          color: x % 2 == 0?Color.fromRGBO(233, 235, 238, 75): Color.fromRGBO(255, 255, 255, 1),
                        ),
                        children: [
                          Align(
                            alignment: Alignment
                                .centerLeft, // Alinha o texto à esquerda
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedUsers[x].nome,
                                  textAlign:
                                      TextAlign.left,
                                  style:  TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5),    
                                  ), // Alinhamento horizontal
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedUsers[x].getTurma,
                                  textAlign: TextAlign.left,
                                style:  TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedUsers[x].getTurno,
                                  textAlign: TextAlign.left,
                                  style:  TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5),
                                  
                                  ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  Text(paginatedUsers[x].login, 
                                    textAlign: TextAlign.left,
                                    style:  TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)

                                  ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(paginatedUsers[x].getTipoDeUsuario,
                                  textAlign: TextAlign.left,
                                  style:  TextStyle(fontWeight: FontWeight.w300, fontSize: 14.5)
                                  ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 128, 128, 128),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.library_books_rounded,
                                            color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Histórico',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.editarUsuario,
                                          arguments: paginatedUsers[x]);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 38, 42, 79),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Editar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Excluir Usuário'),
                                              content: const Text(
                                                  'Tem certeza que deseja excluir este usuário?'),
                                              actions: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              128,
                                                              128,
                                                              128),
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 5),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text('Cancelar')),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      provider.deleteUsuario(
                                                          paginatedUsers[x].idDoUsuario);
                                                      setState(() {
                                                        users.remove(paginatedUsers[x]);
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 5),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    child:
                                                        const Text('Confirmar'))
                                              ],
                                            );
                                          });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.delete, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Excluir',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Barra de navegação de páginas
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
                                  ? Colors.blueGrey
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4.0),
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
          ),
        ],
      ),
    );
  }
}
