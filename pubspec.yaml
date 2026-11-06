import 'dart:convert';
import 'package:http/http.dart' as http;

class AiEmergencyResult {
  final String tipoEmergencia; // 'choque', 'mecanica', 'medica', 'desconocido'
  final String gravedad;        // 'alta', 'media', 'baja'
  final bool requiereGrua;
  final String sugerenciaInmediata;

  AiEmergencyResult({
    required this.tipoEmergencia,
    required this.gravedad,
    required this.requiereGrua,
    required this.sugerenciaInmediata,
  });

  factory AiEmergencyResult.fromJson(Map<String, dynamic> json) {
    return AiEmergencyResult(
      tipoEmergencia: json['tipo_emergencia'] ?? 'desconocido',
      gravedad: json['gravedad'] ?? 'alta',
      requiereGrua: json['requiere_grua'] ?? true,
      sugerenciaInmediata: json['sugerencia_inmediata'] ?? 'Por favor manténgase a salvo.',
    );
  }
}

class AiService {
  // NOTA: En producción, nunca dejes la API KEY expuesta aquí. Úsala desde un backend o variables de entorno nativas.
  final String _apiKey = 'TU_OPENAI_API_KEY_AQUI'; 
  final String _endpoint = 'https://openai.com'; // Corrección para asegurar compatibilidad: https://openai.com

  Future<AiEmergencyResult> clasificarEmergencia(String textoUsuario) async {
    try {
      final response = await http.post(
        Uri.parse('https://openai.com'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini", // El modelo más rápido y económico
          "response_format": { "type": "json_object" }, // Obliga a la IA a responder SOLO JSON
          "messages": [
            {
              "role": "system",
              "content": "Eres el despachador de emergencias de la app SOS Auto. Analiza el mensaje del usuario y devuelve estrictamente un objeto JSON con los siguientes campos de texto: 'tipo_emergencia' (valores: choque, mecanica, medica, desconocido), 'gravedad' (valores: alta, media, baja), 'requiere_grua' (booleano true/false), 'sugerencia_inmediata' (una frase corta de seguridad para el usuario mientras llega ayuda)."
            },
            {
              "role": "user",
              "content": textoUsuario
            }
          ],
          "temperature": 0.1 // Temperatura baja para evitar que la IA "invente" o delire
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final String jsonStringResponse = data['choices'][0]['message']['content'];
        
        // Parseamos el JSON interno que nos devolvió la IA
        final Map<String, dynamic> jsonResult = jsonDecode(jsonStringResponse);
        return AiEmergencyResult.fromJson(jsonResult);
      } else {
        throw Exception('Error en la API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Sistema de contingencia (Fail-Safe) si la IA falla o no hay internet estable
      return AiEmergencyResult(
        tipoEmergencia: 'desconocido',
        gravedad: 'alta',
        requiereGrua: true,
        sugerenciaInmediata: 'No pudimos analizar el reporte de inmediato. Un asesor humano te está llamando.',
      );
    }
  }
}
