import 'package:biblioteca/data/models/usuario_model.dart';
import 'package:biblioteca/screens/library_dashboard.dart';
import 'package:biblioteca/data/models/autor_model.dart';
import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/providers/auth_provider.dart';
import 'package:biblioteca/screens/pesquisar_livro.dart';
import 'package:biblioteca/screens/tela_devolucao.dart';
import 'package:biblioteca/screens/tela_emprestimo.dart';
import 'package:biblioteca/screens/tela_relatorios.dart';
import 'package:biblioteca/screens/telas_testes.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:biblioteca/widgets/forms/form_user.dart';
import 'package:biblioteca/widgets/forms/form_book.dart';
import 'package:biblioteca/widgets/forms/form_author.dart';
import 'package:biblioteca/widgets/forms/form_user_edicao_adm.dart';
import 'package:biblioteca/widgets/tables/author_table_page.dart';
import 'package:biblioteca/widgets/tables/book_table_page.dart';
import 'package:biblioteca/widgets/tables/categories_table_page.dart';
import 'package:biblioteca/widgets/tables/exemplar_table_page.dart';
import 'package:biblioteca/widgets/tables/history_table.dart';
import 'package:biblioteca/widgets/tables/turmas_table_page.dart';
import 'package:biblioteca/widgets/tables/user_table_page.dart';
import 'package:biblioteca/widgets/navegacao/menu_navegacao.dart';
import 'package:biblioteca/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class TelaPaginaIncial extends StatefulWidget {
  const TelaPaginaIncial({super.key});

  @override
  State<TelaPaginaIncial> createState() => _TelaPaginaIncialState();
}

class _TelaPaginaIncialState extends State<TelaPaginaIncial> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  String _selectedRoute = '/inicio';
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }
  void _toggleOverlay(BuildContext context) {
  // Fecha o overlay se estiver aberto
  if (_isExpanded) {
    _removeOverlay();
    return;
  }

  // Cria o overlay
  _overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: kToolbarHeight,
      right: 3,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 210,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings, size: 21),
                title: const Text("Configurações", style: TextStyle(fontSize: 14)),
                onTap: () {
                  _removeOverlay();
                  _navigateToPerfil();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, size: 21),
                title: const Text("Sair", style: TextStyle(fontSize: 14)),
                onTap: () {
                  _removeOverlay();
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.logout,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // Adiciona o overlay garantindo que o contexto está válido
  if (mounted) {
    Overlay.of(context).insert(_overlayEntry!);
    _isExpanded = true;
  }
}

void _removeOverlay() {
  if (_overlayEntry != null) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isExpanded = false;
  }
}

void _navigateToPerfil() {
  if (!mounted) return;
  
  _removeOverlay();
  _navigatorKey.currentState?.pushNamed('/perfil');
}

@override
void dispose() {
  _removeOverlay();
  super.dispose();
}
  

  

  void _onPageSelected(String route) {
    if (_selectedRoute != route) {
      setState(() {
        _selectedRoute = route;
      });
      _navigatorKey.currentState!.pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return paginaInicialContent(context);
  }

  Scaffold paginaInicialContent(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          MenuNavegacao(onPageSelected: _onPageSelected),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppTheme.appBarBackGroundColor,
                actions: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/usericon.png',
                      width: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.usuario.nome,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromRGBO(40, 40, 49, 30),
                            ),
                      ),
                      Text(
                        authProvider.usuario.getTipoDeUsuario,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromRGBO(40, 40, 49, 40),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => _toggleOverlay(context),
                    icon: const Icon(
                      Icons.expand_more,
                      color: Color.fromARGB(255, 119, 119, 119),
                    ),
                  ),
                  const SizedBox(width: 17),
                ],
              ),
              body: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 56,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.drawerBackgroundColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Navigator(
                    key: _navigatorKey,
                    initialRoute: _selectedRoute,
                    onGenerateRoute: (RouteSettings settings) {
                      Widget page;
                      switch (settings.name) {
                        case '/inicio':
                          page = const LibraryDashboard();
                          break;
                        case '/pesquisar_livro':
                          page = const PesquisarLivro();
                          break;
                        case '/emprestimo':
                          page = const PaginaEmprestimo();
                          break;
                        case '/devolucao':
                          page = const TelaDevolucao();
                          break;
                        case AppRoutes.autores:
                          page = const AuthorTablePage();
                          break;
                        case '/livros':
                          page = const BookTablePage();
                          break;
                        case '/relatorios':
                          page = const TelaRelatorios();
                          break;
                        case '/nada_consta':
                          page = const NadaConsta();
                          break;
                        case AppRoutes.usuarios:
                          page = const UserTablePage();
                          break;
                        case '/configuracoes':
                          page = const Configuracoes();
                          break;
                        case '/novo_usuario':
                          page = const FormUser();
                          break;
                        case '/perfil':
                          final usuario = authProvider.usuario;
                          return MaterialPageRoute(
                            builder: (context) => ConfigPerfil(usuario: usuario),
                          );
                        case AppRoutes.editarUsuario:
                          final user = settings.arguments as Usuario;
                          return MaterialPageRoute(
                            builder: (context) => FormUser(usuario: user),
                          );
                        case '/novo_autor':
                          page = const FormAutor();
                          break;
                        case '/categorias':
                          page = const CategoriesTablePage();
                          break;
                        case AppRoutes.editarAutor:
                          final autor = settings.arguments as Autor;
                          return MaterialPageRoute(
                            builder: (context) => FormAutor(autor: autor),
                          );
                        case '/novo_livro':
                          page = const FormBook();
                          break;
                        case AppRoutes.exemplares:
                          final book = settings.arguments as Livro;
                          final ultimaPagina = settings.arguments as String;
                          page = ExemplaresPage(
                            book: book,
                            ultimaPagina: ultimaPagina,
                          );
                          break;
                        case AppRoutes.historico:
                          final usuario = settings.arguments as Usuario;
                          page = HistoryTablePage(usuario: usuario);
                          break;
                        case AppRoutes.turmas:
                          page = const TurmasTablePage();
                          break;
                        default:
                          page = const LibraryDashboard();
                      }
                      return MaterialPageRoute(
                        settings: settings,
                        builder: (_) => page,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}








