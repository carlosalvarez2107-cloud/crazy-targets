import 'dart:convert';
import 'dart:developer' as developer;
import '../models/game_state.dart';

class ScoreRepository {
  // URL base de la backend
  final String baseUrl;

  ScoreRepository({this.baseUrl = 'https://api.crazytargets.com/v1'});

  /// Envía el puntaje del jugador al servidor (se invoca en Mission Passed o Game Over)
  Future<bool> saveGlobalScore(GameState state) async {
    final payload = state.toJson();

    // Log para verificar el cuerpo de la petición en la consola de Flutter
    developer.log(
      'Enviando datos al Backend: ${jsonEncode(payload)}',
      name: 'ScoreRepository',
    );

    try {
      // AQUÍ IRÁ LA PETICIÓN HTTP REAL:
      // final response = await http.post(
      //   Uri.parse('$baseUrl/scores'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(payload),
      // );
      // return response.statusCode == 200 || response.statusCode == 201;

      // Simulación de respuesta exitosa por ahora:
      await Future.delayed(const Duration(milliseconds: 600));
      return true;
    } catch (e) {
      developer.log(
        'Error al enviar puntaje: $e',
        name: 'ScoreRepository',
        error: e,
      );
      return false;
    }
  }
}
