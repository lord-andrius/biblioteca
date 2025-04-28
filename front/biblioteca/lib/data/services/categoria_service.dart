import 'dart:convert';

import 'package:biblioteca/data/models/api_response_model.dart';
import 'package:biblioteca/data/models/categorias_model.dart';
import 'package:biblioteca/data/services/api_service.dart';

class CategoriaService {
  final ApiService _api = ApiService();
  final String apiRoute = 'categoria';

  Future<ApiResponse> fetchCategorias(
      num idDaSessao, String loginDoUsuarioRequerente) async {
    List<Categoria> categorias = [];

    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao, 
      "LoginDoUsuarioRequerente": loginDoUsuarioRequerente,
      "TextoDeBusca": "_"
    };

    final response = await _api.requisicao(apiRoute, 'GET', body);

    final json = jsonDecode(response.data);
    

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      categorias = List<Categoria>.from(json["CategoriasAtingidas"]
          .map((x) => Categoria.fromJson(x)));
    }

    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.statusCode == 200 ? categorias : response.data);
  }

  Future<ApiResponse> addCategoria(
      num idDaSessao, 
      String loginDoUsuarioRequerente,
      String descricao
    ) async {

    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuarioRequerente": loginDoUsuarioRequerente,
      "Descricao": descricao
    };

    final response = await _api.requisicao(apiRoute, 'POST', body);

    late final Categoria categoria;

    if(response.statusCode == 200){

      final json = jsonDecode(response.data)["CategoriasAtingidas"];

      categoria = Categoria.fromJson(json);

    }

    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.statusCode == 200 ? categoria : response.data
      );
  }

  Future<ApiResponse> alterCategoria(
      num idDaSessao, 
      String loginDoUsuarioRequerente,
      Categoria categoria
    ) async {

    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuarioRequerente": loginDoUsuarioRequerente,
      "Id": categoria.idDaCategoria,
      "Descricao": categoria.descricao
    };

    final response = await _api.requisicao(apiRoute, 'PUT', body);



    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.data);
  }

  Future<ApiResponse> deleteCategoria(
      num idDaSessao, 
      String loginDoUsuarioRequerente,
      num idDaCategoria
    ) async {

    final Map<String, dynamic> body = {
      "IdDaSessao": idDaSessao,
      "LoginDoUsuarioRequerente": loginDoUsuarioRequerente,
      "Id": idDaCategoria
    };

    final response = await _api.requisicao(apiRoute, 'DELETE', body);

    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.data);
        
  }
}
