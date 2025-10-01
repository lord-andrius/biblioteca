import 'package:biblioteca/data/providers/auth_provider.dart';
import 'package:biblioteca/data/providers/autor_provider.dart';
import 'package:biblioteca/data/providers/categoria_provider.dart';
import 'package:biblioteca/data/providers/emprestimo_provider.dart';
import 'package:biblioteca/data/providers/exemplares_provider.dart';
import 'package:biblioteca/data/providers/login_provider.dart';
import 'package:biblioteca/data/providers/menu_provider.dart';
import 'package:biblioteca/data/providers/turmas_provider.dart';
import 'package:biblioteca/data/providers/usuario_provider.dart';
import 'package:biblioteca/data/providers/livro_provider.dart';
import 'package:biblioteca/data/providers/paises_provider.dart';
import 'package:biblioteca/data/providers/dashboard_provider.dart';
import 'package:biblioteca/screens/library_dashboard.dart';
import 'package:biblioteca/screens/login.dart';
import 'package:biblioteca/screens/pagina_inicial.dart';
import 'package:biblioteca/screens/pesquisar_livro.dart';
import 'package:biblioteca/screens/tela_devolucao.dart';

import 'package:biblioteca/screens/tela_emprestimo.dart';
import 'package:biblioteca/screens/tela_relatorios.dart';

import 'package:biblioteca/screens/telas_testes.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:biblioteca/utils/theme.dart';
import 'package:biblioteca/widgets/forms/form_user.dart';
import 'package:biblioteca/widgets/forms/form_user_edicao_adm.dart';
import 'package:biblioteca/widgets/tables/author_table_page.dart';
import 'package:biblioteca/widgets/tables/book_table_page.dart';
import 'package:biblioteca/widgets/tables/history_table.dart';
import 'package:biblioteca/widgets/tables/user_table_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  final caminhoPgCtl = Platform.isWindows
      ? Directory.current.path + r'\postgres\bin\pg_ctl.exe'
      : '${Directory.current.path}/postgres/bin/pg_ctl';
  final pastaBanco = Platform.isWindows
      ? Directory.current.path + r'\postgres\banco'
      : '${Directory.current.path}/postgres/banco';
  Process? processoApi;
  if (File(caminhoPgCtl).existsSync()) {
    if (Platform.isWindows) {
      Process.runSync("powershell ", [caminhoPgCtl, "start", "-D", pastaBanco]);
    } else {
      Process.runSync(caminhoPgCtl, ["start", "-D", pastaBanco]);
    }
  }

  final caminhoApi = Platform.isWindows ? r'.\api.exe' : './api';
  if (File(caminhoApi).existsSync()) {
    processoApi = await Process.start(caminhoApi, List.empty());
  }

  try {
    await dotenv.load(fileName: ".env");
  } on EmptyEnvFileError {
    print("O arquivo .env não existe ou está vazio");
  }
  Provider.debugCheckInvalidValueType = null;
  runApp( Myapp());

  if (processoApi != null) {
    processoApi.kill();
  }

  if (File(caminhoPgCtl).existsSync()) {
    if (Platform.isWindows) {
      Process.runSync("powershell ", [caminhoPgCtl, "stop", "-D", pastaBanco]);
    } else {
      Process.runSync(caminhoPgCtl, ["stop", "-D", pastaBanco]);
    }
  }
}

class Myapp extends StatelessWidget {
   Myapp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => MenuState()),
        ChangeNotifierProvider(create: (context) => AutorProvider()),
        ChangeNotifierProvider(create: (context) => TurmasProvider()),
        ProxyProvider<AuthProvider, CategoriaProvider>(
          create: (_) => CategoriaProvider(0, ''),
          update: (_, authProvider, usuarioProvider) => CategoriaProvider(
              authProvider.idDaSessao, authProvider.usuarioLogado),
          dispose: (_, usuarioProvider) => usuarioProvider.dispose(),
        ),
        ProxyProvider<AuthProvider, PaisesProvider>(
          create: (_) => PaisesProvider(0, ''),
          update: (_, authProvider, usuarioProvider) => PaisesProvider(
              authProvider.idDaSessao, authProvider.usuarioLogado),
          dispose: (_, usuarioProvider) => usuarioProvider.dispose(),
        ),
        ProxyProvider<AuthProvider, UsuarioProvider>(
          create: (_) => UsuarioProvider(0, ''),
          update: (_, authProvider, usuarioProvider) => UsuarioProvider(
              authProvider.idDaSessao, authProvider.usuarioLogado),
          dispose: (_, usuarioProvider) => usuarioProvider.dispose(),
        ),
        ProxyProvider<AuthProvider, ExemplarProvider>(
          create: (_) => ExemplarProvider(0, ''),
          update: (_, authProvider, exemplarprovider) => ExemplarProvider(
              authProvider.idDaSessao, authProvider.usuarioLogado),
          dispose: (_, exemplarProvider) => exemplarProvider.dispose(),
        ),
        ProxyProvider<AuthProvider, LivroProvider>(
          create: (_) => LivroProvider(0, ''),
          update: (_, authProvider, exemplarprovider) => LivroProvider(
              authProvider.idDaSessao, authProvider.usuarioLogado),
          dispose: (_, livroProvider) => livroProvider.dispose(),
        ),
        ProxyProvider<AuthProvider, EmprestimoProvider>(
          create: (_) => EmprestimoProvider(0, ''),
          update: (_, authProvider, exemplarprovider) => EmprestimoProvider(
              authProvider.idDaSessao, authProvider.usuarioLogado),
          dispose: (_, emprestimoProvider) => emprestimoProvider.dispose(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('pt', 'BR'),
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: AppTheme.colorScheme,
          scaffoldBackgroundColor: AppTheme.scaffoldBackgroundColor,
          textTheme: GoogleFonts.robotoTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(textStyle: GoogleFonts.roboto())),
        ),
        initialRoute: AppRoutes.login,
        //home: const TelaPaginaIncial(),
        routes: {
          AppRoutes.login: (ctx) => const TelaLogin(),
          AppRoutes.logout: (ctx) =>  Myapp(),
          AppRoutes.home: (ctx) => const TelaPaginaIncial(),
          AppRoutes.dashboard: (ctx) => const LibraryDashboard(),
          AppRoutes.usuarios: (ctx) => const UserTablePage(),
          AppRoutes.novoUsuario: (ctx) => const FormUser(),
          AppRoutes.editarUsuario: (ctx) => const FormUser(),
          AppRoutes.livros: (context) => const BookTablePage(),
          AppRoutes.autores: (context) => const AuthorTablePage(),
          AppRoutes.devolucao: (context) => const TelaDevolucao(),
          AppRoutes.pesquisarLivro: (context) => const PesquisarLivro(),
          AppRoutes.emprestimo: (context) => const PaginaEmprestimo(),
          AppRoutes.historico: (context) => const HistoryTablePage(),

          //paginas temporarias para teste
          AppRoutes.relatorios: (context) => const TelaRelatorios(),
          AppRoutes.nadaConsta: (context) => const NadaConsta(),
          AppRoutes.configuracoes: (context) => const Configuracoes(),
          
        },
      ),
    );
  }
}
