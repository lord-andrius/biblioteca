import 'dart:convert';

import 'package:biblioteca/data/models/sexo_model.dart';

Autor autorFromJson(String str) => Autor.fromJson(json.decode(str));

String autorToJson(Autor data) => json.encode(data.toJson());

class Autor {
  int id;
  String nome;
  int? anoNascimento;
  String nacionalidade;
  int? nacionalidadeCodigo;
  String? sexoCodigo;

  String get sexo => sexoCodigo != null && sexoCodigo!.isNotEmpty
      ? sexos
          .firstWhere(
            (s) => s.codigo == sexoCodigo,
            orElse: () => Sexo(codigo: '', sexo: ''),
          )
          .sexo
      : '';

  Autor({
    this.id = 0,
    required this.nome,
    this.anoNascimento,
    this.nacionalidade = '',
    this.nacionalidadeCodigo,
    this.sexoCodigo,
  });

  factory Autor.fromJson(Map<String, dynamic> json) => Autor(
        id: json["id"],
        nome: json["nome"],
        anoNascimento: json["ano_nascimento"],
        nacionalidade: json["Nacionalidade"] ?? '',
        nacionalidadeCodigo: json["nacionalidade_codigo"],
        sexoCodigo: json["sexo_codigo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nome": nome,
        "ano_nascimento": anoNascimento,
        "Nacionalidade": nacionalidadeCodigo,
        "sexo": sexoCodigo,
      };
}
