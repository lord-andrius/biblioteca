import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio = Dio();
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  String _getBaseUrl() {
    if (!dotenv.isEveryDefined(['PORTA_API'])) {
      FlutterError.reportError(FlutterErrorDetails(
          exception:
              Exception("Variável de ambiente 'PORTA_API' não foi definida")));
    }

    final String porta = dotenv.env['PORTA_API']!;

    return "http://localhost:$porta";
  }

  Future<Response> requisicao(
      String route, String method, Map<String, dynamic> body) async {
    final String baseUrl = _getBaseUrl();
    final String url = "$baseUrl/$route";
    print('Body da requisicao: ${body}');
    return await _dio.request(
      url,
      options: Options(
        validateStatus: (status) => true,
        method: method,
        headers: _headers,
      ),
      data: jsonEncode(body),
    );
  }
  Future<Response> requisicaoPdf(
      String route, String method, Map<String, dynamic> body) async {
    final String baseUrl = _getBaseUrl();
    final String url = "$baseUrl/$route";
    final header ={
      'Content-Type': 'application/pdf'
    };
    print('Body da requisicao: ${body}');
    return await _dio.request(
      url,
      options: Options(
        validateStatus: (status) => true,
        method: method,
        headers: header,
        responseType: ResponseType.bytes
      ),
      data: jsonEncode(body),
    );
  }
}