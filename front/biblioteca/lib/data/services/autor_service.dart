
import 'package:biblioteca/data/models/api_response_model.dart';
import 'package:biblioteca/data/models/autor_model.dart';
import 'package:biblioteca/data/services/api_service.dart';

class AutorService {
  final ApiService _api = ApiService();
  final String apiRoute = 'autor';

  //Retorna todos os usuários
  Future<ApiResponse> fetchAutor() async {
    List<Autor> autores = [];
    final Map<String, dynamic> body = {};

    final response = await _api.requisicao(
      apiRoute,
      'GET',
      body,
    );
    
    if (response.statusCode! >= 200 || response.statusCode! < 300) {
      autores = List<Autor>.from(response.data.map((x) => Autor.fromJson(x)));
    }

    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.statusCode == 200 ? autores : response.data);
  }

  //Criar novo Autor
  Future<ApiResponse> addAutor(Autor autor) async {
    final Map<String, dynamic> body = autor.toJson();

    final response = await _api.requisicao(
      apiRoute,
      'POST',
      body,
    );
    
    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.data);
  }

  //Alterar Autor
  Future<ApiResponse> alterAutor(Autor autor) async {
    final Map<String, dynamic> body = autor.toJson();

    final response = await _api.requisicao(
      apiRoute,
      'PUT',
      body,
    );
    
    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.data);
  }

  //Deletar Autor
  Future<ApiResponse> deleteAutor(int id) async {
    final Map<String, dynamic> body = {
      "id": id
    };

    final response = await _api.requisicao(
      apiRoute,
      'DELETE',
      body,
    );
    
    return ApiResponse(
        responseCode: response.statusCode!,
        body: response.data);
  }
}
