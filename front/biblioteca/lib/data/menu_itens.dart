
import 'package:biblioteca/data/models/modelo_menu.dart';
import 'package:flutter/material.dart';

List<MenuModelo> menuitens = [
  MenuModelo("Inicio", Icons.home, [], route: "/inicio"),
  MenuModelo("Pesquisar Livro", Icons.search, [], route: "/pesquisar_livro"),
  MenuModelo("Circulação", Icons.my_library_books_rounded, [
    SubMenuModelo("Empréstimo", "/emprestimo"),
    SubMenuModelo("Devolução", "/devolucao")
  ]),
  MenuModelo("Catalogação", Icons.menu_book_outlined, [
    SubMenuModelo("Autores", "/autores"),
    SubMenuModelo("Livros", "/livros"),
    SubMenuModelo("Categorias", "/categorias"),
  ]),
  MenuModelo("Documentação", Icons.list_alt_sharp, [
    SubMenuModelo("Relatórios", "/relatorios"),
    SubMenuModelo("Nada Consta", "/nada_consta")
  ]),
  MenuModelo("Controle de Usuários", Icons.co_present_rounded, [], route: '/usuarios')
];

