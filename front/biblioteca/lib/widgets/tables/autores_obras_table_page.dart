import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/models/autor_model.dart';
import 'package:biblioteca/data/models/exemplar_model.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
import 'package:biblioteca/data/providers/livro_provider.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ObrasPage extends StatefulWidget {
  final Autor autor;
  const ObrasPage({super.key, required this.autor});

  @override
  State<ObrasPage> createState() => _ObrasPageState();
}

class _ObrasPageState extends State<ObrasPage> {
  bool isLoading = true;
  List<Livro> livrosDoAutor = [];
  List<Exemplar> exemplaresFiltrados = [];

  @override
  void initState() {
    super.initState();
    _loadDados();
  }

  Future<void> _loadDados() async {
    final livrosProvider = Provider.of<LivroProvider>(context, listen: false);
    final exemplaresProvider =
        Provider.of<ExemplarProvider>(context, listen: false);

    await livrosProvider.loadLivros();
    await exemplaresProvider.loadExemplares();

    livrosDoAutor = livrosProvider.livros
        .where((livro) => livro.autores.any((autor) =>
            autor is Map<String, dynamic> &&
            autor['nome'] == widget.autor.nome))
        .toList();

    final idsLivros = livrosDoAutor.map((livro) => livro.idDoLivro).toSet();

    exemplaresFiltrados = exemplaresProvider.exemplares
        .where((exemplar) => idsLivros.contains(exemplar.idLivro))
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  String _getLivroTitulo(int idLivro) {
    return livrosDoAutor
            .firstWhere((livro) => livro.idDoLivro == idLivro,
                orElse: () => Livro(
                    idDoLivro: 0,
                    isbn: '',
                    titulo: '',
                    anoPublicacao: DateTime.now(),
                    editora: '',
                    pais: {},
                    categorias: [],
                    autores: []))
            .titulo ??
        '';
  }

  String _getLivroCategoria(int idLivro) {
    final livro = livrosDoAutor.firstWhere(
      (livro) => livro.idDoLivro == idLivro,
      orElse: () => Livro(
        idDoLivro: 0,
        isbn: '',
        titulo: '',
        anoPublicacao: DateTime.now(),
        editora: '',
        pais: {},
        categorias: [],
        autores: [],
      ),
    );

    if (livro.categorias.isEmpty) return 'Sem categoria';

    final primeira = livro.categorias.first;

    if (primeira is Map<String, dynamic> && primeira.containsKey('Descricao')) {
      return primeira['Descricao'];
    }

    return 'Sem categoria';
  }

  @override
  Widget build(BuildContext context) {
    final exemplarProvider = Provider.of<ExemplarProvider>(context);

    return Material(
      child: Column(
        children: [
          BreadCrumb(
            breadcrumb: ['Inicio', 'Autores', 'Obras: ${widget.autor.nome}'],
            icon: Icons.menu_book_outlined,
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
              child: Column(
                children: [
                  Table(
                    border: TableBorder.all(
                        color: const Color.fromARGB(215, 200, 200, 200)),
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
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
                              'Código',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Título',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Disponibilidade',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Categoria',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      for (var exemplar in exemplaresFiltrados)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${exemplar.id}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(_getLivroTitulo(exemplar.idLivro)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(exemplar.getStatus),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(_getLivroCategoria(exemplar.idLivro)),
                            ),
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
