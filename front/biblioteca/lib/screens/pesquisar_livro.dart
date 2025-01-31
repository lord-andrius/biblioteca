import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
import 'package:biblioteca/data/providers/livro_provider.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PesquisarLivro extends StatefulWidget {
  const PesquisarLivro({super.key});

  @override
  State<PesquisarLivro> createState() => _PesquisarLivroState();
}

class _PesquisarLivroState extends State<PesquisarLivro> {
  late TextEditingController _searchController;
  late List<Livro> livros;
  late List<Livro> filteredBooks = [];
  late Livro? selectBook = null;
  late bool search = false;
  late ExemplarProvider providerExemplar;
  late LivroProvider providerLivro;
  late List<Exemplar> exemplares;
  late List<Exemplar> filteredExemplares;

  @override
  void initState(){
    super.initState();
    providerExemplar = Provider.of<ExemplarProvider>(context, listen: false);
    providerLivro = Provider.of<LivroProvider>(context, listen: false);
    _searchController = TextEditingController();
    if(providerLivro.livros.isEmpty){
      Provider.of<LivroProvider>(context, listen: false).loadLivros().then((_) {
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
  void SearchExemplares(int idDoLivro){
    filteredExemplares = exemplares.where((exemplar)=> exemplar.idLivro == idDoLivro).toList();
    filteredExemplares.sort((a,b)=> a.id.compareTo(b.id));
  }
  void searchBooks() {
    final seachQuery = _searchController.text.toLowerCase().trim();
    selectBook = null;
    setState(() {
      search = true;
      filteredBooks = livros
          .where((livro) => livro.isbn.contains(seachQuery) ||
              livro.titulo.toLowerCase().contains(seachQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    livros = providerLivro.livros;
    exemplares = providerExemplar.exemplares;
    return Material(
      child: Column(
        children: [
          const BreadCrumb(breadcrumb: ['Início', 'Pesquisar Livro'], icon: Icons.search),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 35, right: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pesquisa De Livro",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
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
                          Icon(Icons.search, color: Colors.white,),
                          SizedBox(width: 3,),
                          Text(
                         "Pesquisar",
                         style: TextStyle(
                           color: Colors.white,
                           fontWeight: FontWeight.w600,
                           fontSize: 16,
                         ),
                      ),
                        ],
                      )
                    ),
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
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectBook == null)
                          
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 1210,
                                minWidth: 800,
                              ),
                              child: Table(
                                border: TableBorder.all(
                                  color: const Color.fromARGB(215, 200, 200, 200),
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(0.13),
                                  1: FlexColumnWidth(0.30),
                                  2: FlexColumnWidth(0.15),
                                  3: FlexColumnWidth(0.14),
                                  4: FlexColumnWidth(0.10),
                                  5: FlexColumnWidth(0.12),
                                },
                                children: [
                                  const TableRow(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 44, 62, 80),
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'ISBN',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Titulo',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white,fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Editora',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white,fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Ano de Publicação',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white,fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Exemplares',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white,fontSize: 14.5),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Ação',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white,fontSize: 14.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  for (int x = 0; x < filteredBooks.length; x++)
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: x % 2 == 0?Color.fromRGBO(233, 235, 238, 75): Color.fromRGBO(255, 255, 255, 1),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                          child: Text(
                                            filteredBooks[x].isbn,
                                            textAlign: TextAlign.center,
                                             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                          child: Text(
                                            filteredBooks[x].titulo,
                                            textAlign: TextAlign.left,
                                             style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13.5),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                          child: Text(
                                            filteredBooks[x].editora,
                                            textAlign: TextAlign.center,
                                             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                          child: Text(
                                            DateFormat('dd/MM/yyyy').format(
                                              filteredBooks[x].anoPublicacao,
                                            ),
                                            textAlign: TextAlign.center,
                                             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                          child: Text(
                                            '${providerExemplar.QtdExemplaresLivro(filteredBooks[x].idDoLivro)}',
                                            textAlign: TextAlign.center,
                                             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
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
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                selectBook = filteredBooks[x];
                                                SearchExemplares(selectBook!.idDoLivro);
                                              });
                                            },
                                            child: const Text(
                                              'Selecionar',
                                              style: TextStyle(
                                                color: const Color.fromARGB(255, 250, 244, 244),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13.5,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              
                                ],
                              ),
                            )
                        else
                          SizedBox(
                            width: 1100,
                            child: Column(
                              children: [
                                Text(
                                   "Livro Selecionado",
                                   style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                     fontWeight: FontWeight.bold,
                                     fontSize: 20.3,
                                     color: Colors.black,
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                                Divider(thickness: 2, color: Colors.grey[300]),
                                SizedBox(height: 10,),
                                Table(
                                  border: TableBorder.all(
                                    color: const Color.fromARGB(215, 200, 200, 200),
                                  ),
                                  columnWidths: const{
                                    0: FlexColumnWidth(0.07),
                                    1: FlexColumnWidth(0.13),
                                    2: FlexColumnWidth(0.30),
                                    3: FlexColumnWidth(0.15),
                                    4: FlexColumnWidth(0.14),
                                    5: FlexColumnWidth(0.10),
                                  },
                                  children: [
                                    const TableRow(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 44, 62, 80),
                                      ),
                                      children: [
                                        SizedBox.shrink(),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'ISBN',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14.5),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Titulo',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14.5),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Editora',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14.5),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Ano de Publicação',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14.5),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Exemplares',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14.5),
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
                                          padding:EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          child: Icon(Icons.menu_book_outlined, ),
                                        ),
                                        Padding(
                                           padding:EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          child: Text(
                                            selectBook!.isbn,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                                          ),
                                        ),
                                        Padding(
                                           padding:EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          child: Text(
                                            selectBook!.titulo,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                                          ),
                                        ),
                                        Padding(
                                           padding:EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          child: Text(
                                            selectBook!.editora,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                                          ),
                                        ),
                                        Padding(
                                           padding:EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          child: Text(
                                            DateFormat('dd/MM/yyyy').format(
                                              selectBook!.anoPublicacao,
                                            ),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),  

                                          ),
                                        ),
                                        Padding(
                                           padding:EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          child: Text(
                                            '${providerExemplar.QtdExemplaresLivro(selectBook!.idDoLivro)}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30,),
                                Text(
                                   "Detalhes Dos Exemplares",
                                   style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                     fontWeight: FontWeight.bold,
                                     fontSize: 20.3,
                                     color: Colors.black,
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                              Divider(thickness: 2, color: Colors.grey[300]),
                              SizedBox(height: 10,),
                              Table(
                              border: TableBorder.all(
                                color: const Color.fromARGB(215, 200, 200, 200),
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(0.10),
                                1: FlexColumnWidth(0.30),
                                2: FlexColumnWidth(0.16),
                                3: FlexColumnWidth(0.15),
                              },
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 44, 62, 80),
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Tombamento',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white,fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Titulo',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white,fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Situação',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white,fontSize: 14.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Estado Físico',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white,fontSize: 14.5),
                                      ),
                                    ),
                                  ],
                                ),
                                for (int x = 0; x < filteredExemplares.length; x++)
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color:  x % 2 == 0?Color.fromRGBO(233, 235, 238, 75): Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Text(
                                          filteredExemplares[x].id.toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Text(
                                          filteredExemplares[x].titulo,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Text(
                                          filteredExemplares[x].getStatus,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Text(
                                          filteredExemplares[x].getEstado,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                     
                                    ],
                                  ),

                              ],
                            ),


                              ],
                            ),
                          )
                      ],
                    )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
