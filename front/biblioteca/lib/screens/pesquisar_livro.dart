import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
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
  late List<Exemplar> livros;
  late List<Exemplar> filteredBooks = []; 
  late Exemplar? selectBook =null;
  late bool search = false;
  @override
  void initState() {
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_){
      Provider.of<ExemplarProvider>(context,listen: false).loadExemplares().then((_){
        setState(() {
          livros = Provider.of<ExemplarProvider>(context,listen: false).exemplares;
        });
      });
    });
  }
  void searchBooks(){
    final seachQuery = _searchController.text.toLowerCase().trim();

    setState(() {
      search = true;
      filteredBooks = livros.where(
        (livro) => livro.isbn.contains(seachQuery)||livro.titulo.toLowerCase().contains(seachQuery)
      ).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          const BreadCrumb(breadcrumb: ['Início', 'Pesquisar Livro'], icon: Icons.search),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 35, right: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pesquisa De Livro", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
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
                  ]
                ),
                const SizedBox(height: 40),
                if(search)
                  if(filteredBooks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Nenhum livro encontrado', style: TextStyle(fontSize: 16)),
                    )
                  else 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectBook == null)
                          SizedBox(
                            width: 1050,
                            child: Table(
                              border: TableBorder.all(color: const Color.fromARGB(97, 104, 104, 104)),
                              columnWidths: const {
                                0: FlexColumnWidth(0.13),
                                1: FlexColumnWidth(0.28),
                                2: FlexColumnWidth(0.15),
                                3: FlexColumnWidth(0.14),
                                4: FlexColumnWidth(0.14),
                                5: FlexColumnWidth(0.14),
                              },
                              children: [
                                const TableRow(
                                  decoration: BoxDecoration(color:Color.fromARGB(255, 214, 214, 214)),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('ISBN', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Titulo', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Editora', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Ano de Publicação', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Qtd de Exemplares', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(width: 5),
                                  ],
                                ),
                                for (int x = 0; x < filteredBooks.length; x++)
                                  TableRow(
                                    decoration: const BoxDecoration(color: Color.fromRGBO(233, 235, 238, 75)),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text(filteredBooks[x].isbn, textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text(filteredBooks[x].titulo, textAlign: TextAlign.left),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text(filteredBooks[x].editora, textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text(DateFormat('dd/MM/yyyy').format(filteredBooks[x].anoPublicacao), textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 11.0,left: 8.0,),
                                        child: Text('2', textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                          ),
                                          onPressed: () {
                                              setState(() {
                                                selectBook = filteredBooks[x];
                                              });
                                          },
                                          child: const Text('Selecionar Livro', style: TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center,),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                      ]
                    ),

              ]
            )
          )
        ]
      )
    );
                

  }
}