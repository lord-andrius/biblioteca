import 'package:biblioteca/data/services/api_service.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class RelatorioService {
  final ApiService _api = ApiService();
  final String apiRoute = 'relatorio';

  // MÉTODO PARA REMOVER ZEROS DO FINAL (mantido para segurança)
  Uint8List _removerZerosDoFinal(Uint8List pdfBytes) {
    try {
      debugPrint('🧹 Removendo zeros do final...');
      
      final terminador = utf8.encode('%%EOF');
      int finalReal = pdfBytes.length;
      
      for (int i = pdfBytes.length - terminador.length; i >= 0; i--) {
        if (pdfBytes[i] == terminador[0] && 
            pdfBytes[i + 1] == terminador[1] &&
            pdfBytes[i + 2] == terminador[2] &&
            pdfBytes[i + 3] == terminador[3] &&
            pdfBytes[i + 4] == terminador[4]) {
          finalReal = i + terminador.length;
          debugPrint('✅ Terminador encontrado na posição: $i');
          break;
        }
      }
      
      if (finalReal < pdfBytes.length) {
        debugPrint('✂️ Cortando ${pdfBytes.length - finalReal} bytes do final');
        return Uint8List.sublistView(pdfBytes, 0, finalReal);
      }
      
      return pdfBytes;
    } catch (e) {
      debugPrint('❌ Erro ao remover zeros: $e');
      return pdfBytes;
    }
  }

  // NOVO MÉTODO PARA DECODIFICAR BASE64 CORRETAMENTE
  Uint8List _decodeBase64ParaBytes(String base64String) {
    try {
      debugPrint('🔍 Verificando se a string é Base64...');
      
      // Limpa a string se vier com prefixo (comum em alguns APIs)
      // Ex: "data:application/pdf;base64,JVBERi0xLjQK..."
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
        debugPrint('📋 Prefixo removido da string Base64');
      }

      debugPrint('🔄 Decodificando Base64...');
      final Uint8List pdfBytes = base64.decode(base64String);
      
      debugPrint('✅ Base64 decodificado com sucesso!');
      debugPrint('📊 Bytes resultantes: ${pdfBytes.length}');
      debugPrint('🔍 Primeiros bytes: ${pdfBytes.sublist(0, 4)}'); // Deve ser [37, 80, 68, 70] (%PDF)
      
      return pdfBytes;
    } catch (e) {
      debugPrint('❌ Erro ao decodificar Base64: $e');
      rethrow;
    }
  }

  Future<Uint8List> baixarRelatorio({
    required num idDaSessao,
    required String loginDoUsuario,
    required String dominioDoRelatorio,
    List<Map<String, String>> filtros = const [],
  }) async {
    try {
      final response = await _api.requisicaoPdf(
        apiRoute,
        'GET',
        {
          "IdDaSessao": idDaSessao,
          "loginDoUsuario": loginDoUsuario,
          "dominioDoRelatorio": dominioDoRelatorio,
          "filtros": filtros,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Status Code: 200');
        debugPrint('📦 Tipo dos dados: ${response.data.runtimeType}');
        
        if (response.data is String) {
          final String pdfData = response.data as String;
          debugPrint('📄 Tamanho da string: ${pdfData.length} caracteres');
          debugPrint('🔍 Primeiros caracteres: ${pdfData.substring(0, 30)}...');
          
          // CONVERSÃO CORRETA PARA BYTES VIA BASE64
          debugPrint('🔄 Convertendo Base64 para bytes...');
          final Uint8List pdfBytes = _decodeBase64ParaBytes(pdfData);
          
          // Verificação da assinatura PDF
          if (pdfBytes.length >= 4 &&
              pdfBytes[0] == 0x25 && // %
              pdfBytes[1] == 0x50 && // P
              pdfBytes[2] == 0x44 && // D
              pdfBytes[3] == 0x46) { // F
            debugPrint('✅ ASSINATURA PDF VÁLIDA DETECTADA!');
            
            // LIMPEZA DOS ZEROS DO FINAL (opcional, mas mantido)
            final Uint8List pdfBytesLimpo = _removerZerosDoFinal(pdfBytes);
            debugPrint('📊 Bytes após limpeza: ${pdfBytesLimpo.length}');
            
            return pdfBytesLimpo;
          } else {
            debugPrint('❌ Assinatura PDF não encontrada nos bytes decodificados');
            debugPrint('🔍 Bytes iniciais recebidos: ${pdfBytes.sublist(0, 10)}');
            throw Exception('Assinatura PDF não encontrada após decodificação Base64');
          }
        }
        else if (response.data is Uint8List) {
          debugPrint('✅ Dados recebidos como Uint8List (bytes brutos)');
          final Uint8List pdfBytes = response.data as Uint8List;
          
          // Verifica assinatura mesmo para bytes brutos
          if (pdfBytes.length >= 4 &&
              pdfBytes[0] == 0x25 &&
              pdfBytes[1] == 0x50 &&
              pdfBytes[2] == 0x44 &&
              pdfBytes[3] == 0x46) {
            debugPrint('✅ ASSINATURA PDF VÁLIDA EM BYTES BRUTOS!');
            return _removerZerosDoFinal(pdfBytes);
          } else {
            throw Exception('Assinatura PDF não encontrada em bytes brutos');
          }
        }
        else {
          debugPrint('❌ Formato não suportado: ${response.data.runtimeType}');
          throw Exception('Formato de resposta não suportado: ${response.data.runtimeType}');
        }
      } else {
        debugPrint('❌ Erro HTTP: ${response.statusCode}');
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao processar PDF: $e');
      rethrow;
    }
  }

  // Método antigo removido pois era a causa do problema
  // Uint8List _stringToBytesMelhorado(String data) {
  //   try {
  //     final List<int> codeUnits = data.codeUnits;
  //     return Uint8List.fromList(codeUnits);
  //   } catch (e) {
  //     debugPrint('❌ Erro na conversão: $e');
  //     return Uint8List.fromList(latin1.encode(data));
  //   }
  // }
}