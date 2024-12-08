// import 'dart:io';

import 'package:biblioteca/screens/pagina_inicial.dart';
import 'package:biblioteca/screens/redefinir_senha.dart';
import 'package:biblioteca/screens/telas_testes.dart';
import 'package:biblioteca/utils/routes.dart';
import 'package:biblioteca/utils/theme.dart';
import 'package:biblioteca/widgets/tables/user_table_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  /* if (Platform.isLinux || Platform.isWindows) {
    var dir = Directory.current.path;
    dir = dir.substring(1, dir.indexOf("front"));
    Process.run("go", ["run", dir]);
  }*/

  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            style: ElevatedButton.styleFrom(
              textStyle: GoogleFonts.roboto()
            )
          ),
        ),
      // initialRoute: AppRoutes.login,
      home: const TelaPaginaIncial(),
      routes: {
        // AppRoutes.login: (ctx) => const TelaLogin(),
        AppRoutes.home: (ctx) => const TelaPaginaIncial(),
        AppRoutes.redefinirSenha: (ctx) => const TelaRedefinirSenha(),
        AppRoutes.usuarios: (ctx) => const UserTablePage(),

        //paginas temporarias para teste
        AppRoutes.pesquisarLivro: (context) => const PesquisarLivro(),
        AppRoutes.emprestimo: (context) => const Emprestimo(),
        AppRoutes.devolucao: (context) => const Devolucao(),
        AppRoutes.livros: (context) => const Livros(),
        AppRoutes.relatorios: (context) => const Relatorios(),
        AppRoutes.nadaConsta: (context) => const NadaConsta(),
        AppRoutes.configuracoes: (context) => const Configuracoes(),

      },
    );
  }
}
