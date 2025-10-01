import 'package:biblioteca/data/providers/auth_provider.dart';
import 'package:biblioteca/data/services/relatorio.dart';
import 'package:biblioteca/widgets/navegacao/bread_crumb.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart'; 
import 'dart:io';
import 'package:provider/provider.dart';

class TelaRelatorios extends StatefulWidget {
  const TelaRelatorios({super.key});

  @override
  State<TelaRelatorios> createState() => _TelaRelatoriosState();
}

class _TelaRelatoriosState extends State<TelaRelatorios> {
  final TextEditingController _searchController = TextEditingController();
  final RelatorioService relatorioService = RelatorioService();
  String? _selectedReport;
  bool _isLoading = false;
  late final AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }
 
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _baixarRelatorio() async {
    if (_selectedReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um relatório primeiro')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final pdfBytes = await relatorioService.baixarRelatorio(
        idDaSessao: authProvider.idDaSessao,
        loginDoUsuario: authProvider.usuarioLogado,
        dominioDoRelatorio: _getDominioFromReport(_selectedReport!),
        filtros: _searchController.text.isNotEmpty
            ? [{'Nome': _searchController.text}]
            : [],
      );

      debugPrint('📊 Bytes recebidos: ${pdfBytes.length}');
      
      if (pdfBytes.length < 100) {
        throw Exception('PDF muito pequeno (${pdfBytes.length} bytes)');
      }

      // PERMITE QUE O USUÁRIO ESCOLHA ONDE SALVAR
      final String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar Relatório PDF',
        fileName: 'Relatorio_${_selectedReport?.replaceAll(' ', '_')}_${DateTime.now().toString().substring(0, 10)}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        lockParentWindow: true,
      );

      if (savePath == null) {
        // Usuário cancelou a operação
        setState(() => _isLoading = false);
        return;
      }

      // SALVA O ARQUIVO NO LOCAL ESCOLHIDO
      final file = File(savePath);
      await file.writeAsBytes(pdfBytes);

      final fileSize = await file.length();
      
      debugPrint('💾 Arquivo salvo: $fileSize bytes');
      debugPrint('📁 Caminho completo: $savePath');
      
      if (fileSize < 100) {
        throw Exception('Arquivo salvo muito pequeno');
      }


      if (!mounted) return;
      
      // ABRE O ARQUIVO AUTOMATICAMENTE APÓS SALVAR
      _abrirArquivo(savePath);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório salvo e aberto com sucesso!'),
          duration: Duration(seconds: 3),
        ),
      );

    } catch (e) {
      debugPrint('❌ Erro ao baixar relatório: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha: ${e.toString().replaceAll('Exception: ', '')}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // MÉTODO PARA ABRIR O ARQUIVO COM open_file
  Future<void> _abrirArquivo(String filePath) async {
    try {
      debugPrint('📂 Tentando abrir arquivo: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Arquivo não encontrado');
      }

      // USA open_file PARA ABRIR DIRETAMENTE
      final result = await OpenFile.open(filePath);
      
      debugPrint('✅ Resultado da abertura: ${result.message}');
      
      if (result.type != ResultType.done) {
        debugPrint('⚠️ Não foi possível abrir: ${result.message}');
    
      }
      
    } catch (e) {
      debugPrint('❌ Erro ao abrir arquivo: $e');
  
    }
  }


  String _getDominioFromReport(String report) {
    final mapDominios = {
      'Relatório de Autores': 'autor',
      'Relatório de Categoria': 'categoria',
      'Relatório de Detalhes de Empréstimos': 'detalhe_emprestimo',
      'Relatório de Empréstimos': 'emprestimo',
      'Relatório de Exemplares': 'exemplar',
      'Relatório de Livros': 'livro',
      'Relatório de País': 'pais',
      'Relatório de Series': 'serie',
      'Relatório de SubCategorias': 'subcategoria',
      'Relatório de Turmas': 'turma',
      'Relatório de Turno': 'turno',
      'Relatório De Usuários': 'usuario',
    };
    return mapDominios[report] ?? '';
  }

  bool _deveMostrarCampoBusca() {
    return _selectedReport != null &&
        (_selectedReport!.contains('Usuários') ||
            _selectedReport!.contains('Livros') ||
            _selectedReport!.contains('Autores'));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const BreadCrumb(
                  breadcrumb: ['Início', 'Relatórios'],
                  icon: Icons.my_library_books_rounded,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 35, right: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Relatórios",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Flexible(
                            child: DropdownMenu<String>(
                              label: const Text('Selecione um relatório'),
                              inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              leadingIcon: const Icon(Icons.my_library_books_rounded),
                              width: 800,
                              menuHeight: 500,
                              onSelected: (String? value) {
                                setState(() {
                                  _selectedReport = value;
                                });
                              },
                              dropdownMenuEntries: const [
                                DropdownMenuEntry(value: "Relatório de Autores", label: "Relatório de Autores"),
                                DropdownMenuEntry(value: "Relatório de Categoria", label: "Relatório de Categoria"),
                                DropdownMenuEntry(value: "Relatório de Detalhes de Empréstimos", label: "Relatório de Detalhes de Empréstimos"),
                                DropdownMenuEntry(value: "Relatório de Empréstimos", label: "Relatório de Empréstimos"),
                                DropdownMenuEntry(value: "Relatório de Exemplares", label: "Relatório de Exemplares"),
                                DropdownMenuEntry(value: "Relatório de Livros", label: "Relatório de Livros"),
                                DropdownMenuEntry(value: "Relatório de País", label: "Relatório de País"),
                                DropdownMenuEntry(value: "Relatório de Series", label: "Relatório de Series"),
                                DropdownMenuEntry(value: "Relatório de SubCategorias", label: "Relatório de SubCategorias"),
                                DropdownMenuEntry(value: "Relatório de Turmas", label: "Relatório de Turmas"),
                                DropdownMenuEntry(value: "Relatório de Turno", label: "Relatório de Turno"),
                                DropdownMenuEntry(value: "Relatório De Usuários", label: "Relatório De Usuários"),
                              ],
                            ),
                          ),
                          const SizedBox(width: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 20),
                              backgroundColor: const Color.fromRGBO(38, 42, 79, 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isLoading ? null : _baixarRelatorio,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Row(
                                    children: [
                                      Icon(Icons.download, color: Colors.white),
                                      SizedBox(width: 3),
                                      Text("Baixar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.5)),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_searchController.text.isEmpty)
                        const Text('Opcional: pesquise por um termo específico', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      if (_deveMostrarCampoBusca())
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Filtrar por nome',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}