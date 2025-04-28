import 'package:biblioteca/data/models/livro_model.dart';
import 'package:biblioteca/data/services/livro_service.dart';
import 'package:flutter/foundation.dart';

class LivroProvider extends ChangeNotifier {
  final LivroService _livroService = LivroService();
  bool _isLoading = false;
  String? _error;
  List<Livro> _livros = [];
  List<Map<String,dynamic>> _livrosEnvio = [];

  final num idDaSessao;
  final String usuarioLogado;

  LivroProvider(this.idDaSessao, this.usuarioLogado);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasErrors => _error != null;
  List<Livro> get livros => [..._livros];

  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Carregar todos os livros
  Future<void> loadLivros() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    

    try {
      final livrosAtingidos =
          await _livroService.fetchLivros(idDaSessao, usuarioLogado);
      if (!listEquals(_livros, livrosAtingidos.livrosAtingidos)) {
        _livros = livrosAtingidos.livrosAtingidos;
      }
    } catch (e) {
      _error = "Provider: Erro ao carregar os Livros:\n$e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh livros
  Future<void> refreshLivros() async {
    await loadLivros();
  }

  // Adicionar um novo livro
  Future<bool> addLivro(Map<String, dynamic> livro, List<String> autores, List<String> categorias) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_livros.any((l) => l.isbn == livro["Isbn"])) {
        throw Exception("Livro com ISBN ${livro["Isbn"]} já existe.");
      }

      await _livroService.addLivro(idDaSessao, usuarioLogado, livro, autores, categorias);
      _livrosEnvio.add(livro);
      return true;
    } catch (e) {
      _error = "Erro ao inserir novo Livro:\n$e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Editar um livro existente
  Future<void> editLivro(Map<String,dynamic> livro) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _livrosEnvio.indexWhere((l) => l["Isbn"] == livro["Isbn"]);
      if (index == -1) {
        throw Exception("Livro com ISBN ${livro["Isbn"]} não encontrado.");
      }

      await _livroService.alterLivro(livro);
      _livrosEnvio[index] = livro;
    } catch (e) {
      _error = "Erro ao alterar o Livro:\n$e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Deletar um livro
  Future<void> deleteLivro(int idLivro) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_livros.any((livro) => livro.idDoLivro == idLivro)) {
        throw Exception("Livro com ID $idLivro não encontrado.");
      }

      await _livroService.deleteLivro(idLivro);
      _livros.removeWhere((livro) => livro.idDoLivro == idLivro);
    } catch (e) {
      _error = "Erro ao deletar o Livro:\n$e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
