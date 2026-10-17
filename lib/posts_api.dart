import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'post.dart';
import 'tareas_api.dart';

class PostsApi {
  final http.Client _client;
  static const _host = 'jsonplaceholder.typicode.com';
  static const _timeout = Duration(seconds: 10);

  PostsApi(this._client);

  Future<List<Post>> fetchPosts({int page = 1, int limit = 15}) async {
    final uri = Uri.https(_host, '/posts', {
      '_page': page.toString(),
      '_limit': limit.toString(),
    });

    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw ApiException('Error del servidor (${response.statusCode})', codigo: response.statusCode);
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ApiException('Respuesta de servidor inválida.');
      }

      return decoded.map((item) => Post.fromJson(item as Map<String, dynamic>)).toList();
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder.');
    } on http.ClientException {
      throw const ApiException('No fue posible conectar. Revisa tu conexión a internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }
}
