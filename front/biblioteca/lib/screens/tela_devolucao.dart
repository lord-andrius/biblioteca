import 'package:biblioteca/data/models/emprestimos_model.dart';
import 'package:biblioteca/data/providers/emprestimo_provider.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TelaDevolucao extends StatefulWidget {
  const TelaDevolucao({super.key});

  @override
  State<TelaDevolucao> createState() => _TelaDevolucaoState();
}

class _TelaDevolucaoState extends State<TelaDevolucao> {
  TextEditingController _searchControllerBooks = TextEditingController();
  bool showBooks = false;
  late ExemplarProvider exemplarProvider;
  late List<EmprestimosModel> exemplares;
  List<EmprestimosModel> selectedBoxExemplar = [];
  @override
  void initState() {
    super.initState();
    exemplarProvider = Provider.of<ExemplarProvider>(context, listen: false);
    
  }

  void msgSnackBar(String msg, int tipoCor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: tipoCor == 0 ? Colors.red : Colors.amber,
      content: Text(
        msg,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> searchBooks() async{
    showBooks = true;
    List<EmprestimosModel> selectbook;
    final searchQuery = _searchControllerBooks.text.trim();
      if (searchQuery.isEmpty) {
        selectbook = [];
        return;
      }
        try {
          selectbook = await Provider.of<EmprestimoProvider>(context, listen: false).fetchEmprestimoExemplar(int.parse(searchQuery));
        } catch (e) {
          selectbook = [];
          msgSnackBar('Erro ao fazer a pesquisa, tente novamente mais tarde', 0);
        }
        if(selectbook.isEmpty){
          msgSnackBar('Exemplar não se encontra na situação emprestado.', 0);
        }else{
          if (selectedBoxExemplar.any((item)=> item.IdDoEmprestimo == selectbook[0].IdDoEmprestimo)) {
            msgSnackBar('Exemplar já adicionado na lista', 1);
          } else {
            selectedBoxExemplar.add(selectbook[0]);
          }
        }
    setState(() {
      
    });
  }
  Future<void> msgConfirmEmprestimo(List<EmprestimosModel> exemplaresEmpres) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title:  Text(
                 'Confirmação de Devolução',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                  border: TableBorder.all(
                      color: const Color.fromARGB(215, 200, 200, 200)),
                  children: [
                    const TableRow(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 44, 62, 80)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Tombamento",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Título",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Data de Devolução",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Situação",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15)),
                          )
                        ]),
                    for (EmprestimosModel exemplar in exemplaresEmpres)
                      TableRow(
                          decoration: const BoxDecoration(
                              color: Color.fromRGBO(233, 235, 238, 75)),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(exemplar.exemplarMap['IdDoExemplarLivro'].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(exemplar.exemplarMap['Livro']['Titulo'],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                  exemplar.dataPrevistaEntrega,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Devolução Realizada',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      color: Colors.green[400])),
                            )
                          ])
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
                                borderRadius: BorderRadius.circular(8))),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(fontSize: 15.5),
                        )),
                  ],
                )
              ],
            ));
  }
  Future<void> DevolverExemplares(List<EmprestimosModel> emprestimosRenov) async{
    final copia = List.from(emprestimosRenov);
    for(EmprestimosModel item in copia){
      print('Item: ${item.IdDoEmprestimo}');
      await Provider.of<EmprestimoProvider>(context, listen: false).Devolver(item.IdDoEmprestimo);
    }
    
  }
  @override
  Widget build(BuildContext context) {
    exemplares = Provider.of<ExemplarProvider>(context, listen: true).listaEmprestados;
    return Material(
      child: Column(
        children: [
          BreadCrumb(
              breadcrumb: ['Início', 'Devolução'],
              icon: Icons.my_library_books_rounded),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 35, right: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pesquisar Exemplar",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 26)),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: 800, maxHeight: 40, minWidth: 200),
                        child: TextField(
                          controller: _searchControllerBooks,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            labelText: "Insira o número do tombamento",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
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
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: searchBooks,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text("Adicionar",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.5)),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 40),
                if (showBooks)
                  if (selectedBoxExemplar.isNotEmpty)
                    Column(
                      children: [
                        SizedBox(
                          width: 1150,
                          child: Row(
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 15),
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.green[400],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  onPressed: () {
                                    List<EmprestimosModel> listaParaDevolucao  = [];
                                    for(EmprestimosModel item in selectedBoxExemplar){
                                      if(item.selecionadoRenov == true){
                                        listaParaDevolucao.add(item);
                                      }
                                    }
                                    if(listaParaDevolucao.isEmpty){
                                      msgSnackBar('Nenhum exemplar selecionado', 1);
                                    }else{
                                      DevolverExemplares(listaParaDevolucao);
                                      msgConfirmEmprestimo(listaParaDevolucao).then((_){
                                     for (EmprestimosModel exemplar
                                        in List.from(selectedBoxExemplar)) {
                                      if (exemplar.selecionadoRenov == true) {
                                        selectedBoxExemplar.remove(exemplar);
                                      }
                                    }
                                    setState(() {});
                                    });
                                    }
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.outbox,
                                        color: Colors.white,
                                        size: 23,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Devolver',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 20),
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.red[400],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  onPressed: () {
                                    for (EmprestimosModel exemplar
                                        in List.from(selectedBoxExemplar)) {
                                      if (exemplar.selecionadoRenov == true) {
                                        selectedBoxExemplar.remove(exemplar);
                                      }
                                    }
                                    setState(() {});
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 23,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Remover',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      )
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: 1150,
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(0.08),
                              1: FlexColumnWidth(0.26),
                              2: FlexColumnWidth(0.14),
                              3: FlexColumnWidth(0.14),
                              4: FlexColumnWidth(0.10),
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
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(7.0),
                                      child: Text('Nome',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(7.0),
                                      child: Text('Data de Empréstimo',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(7.0),
                                      child: Text('Data de Devoluçao',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(7.0),
                                      child: Text('Ação',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15)),
                                    ),
                                  ]),
                              for (int x = 0;
                                  x < selectedBoxExemplar.length;
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
                                            vertical: 9.4, horizontal: 8),
                                        child: Text(
                                            selectedBoxExemplar[x].exemplarMap['IdDoExemplarLivro'].toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14.5)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 9.4, horizontal: 8),
                                        child: Text(selectedBoxExemplar[x].exemplarMap['Livro']['Titulo'],
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14.5)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 9.4, horizontal: 8),
                                        child: Text(
                                            selectedBoxExemplar[x]
                                                .dataEmprestimo,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,   
                                                fontSize: 14.5)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 9.4, horizontal: 8),
                                        child: Text(
                                            selectedBoxExemplar[x]
                                                .dataPrevistaEntrega,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14.5)),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 37,
                                          ),
                                          child: Checkbox(
                                              value: selectedBoxExemplar[x]
                                                  .selecionadoRenov,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedBoxExemplar[x]
                                                          .selecionadoRenov =
                                                      value as bool;
                                                });
                                              }))
                                    ]),
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
          ),
        ],
      ),
    );
  }
}
