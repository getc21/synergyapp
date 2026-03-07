import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';

class CategoryProvider {
  static String get baseUrl => ApiConfig.baseUrl;
  final String token;

  CategoryProvider(this.token);

  Map<String, String> get _headers => <String, String>{
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, String> get _authHeaders => <String, String>{
    'Authorization': 'Bearer $token',
  };

  // Obtener todas las categorías
  Future<Map<String, dynamic>> getCategories({String? storeId}) async {
    try {
      // ⭐ MULTI-TENANT: el backend filtra por brandId del JWT automáticamente
      // storeId se pasa como query param opcional para filtrado adicional
      final queryParams = <String, String>{};
      if (storeId != null) queryParams['storeId'] = storeId;
      
      final uri = Uri.parse('$baseUrl/categories').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final http.Response response = await http.get(
        uri,
        headers: _headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final categories = data['data']['categories'];
        if (categories is List) {
          return <String, dynamic>{'success': true, 'data': categories};
        } else {
          return <String, dynamic>{'success': false, 'message': 'Formato de respuesta inválido'};
        }
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error obteniendo categorías'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener categoría por ID
  Future<Map<String, dynamic>> getCategoryById(String id) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$baseUrl/categories/$id'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return <String, dynamic>{'success': true, 'data': data['data']['category']};
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error obteniendo categoría'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Crear categoría
  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    File? imageFile,
    String? brandId, // ⭐ MULTI-TENANT
  }) async {
    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/categories'),
      );

      request.headers.addAll(_authHeaders);
      request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;
      // ⭐ MULTI-TENANT: enviar brandId al crear
      if (brandId != null) request.fields['brandId'] = brandId;

      if (imageFile != null) {
        // Determinar el tipo MIME basado en la extensión
        String mimeType = 'image/jpeg'; // Default
        final String extension = imageFile.path.split('.').last.toLowerCase();
        
        switch (extension) {
          case 'png':
            mimeType = 'image/png';
            break;
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
        }        
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto', 
            imageFile.path,
            contentType: MediaType.parse(mimeType),
          )
        );
      }

      final http.StreamedResponse streamedResponse = await request.send();
      final http.Response response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return <String, dynamic>{'success': true, 'data': data['data']};
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error creando categoría'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar categoría
  Future<Map<String, dynamic>> updateCategory({
    required String id,
    String? name,
    String? description,
    File? imageFile,
  }) async {
    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/categories/$id'),
      );

      request.headers.addAll(_authHeaders);
      if (name != null) request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;

      if (imageFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('foto', imageFile.path));
      }

      final http.StreamedResponse streamedResponse = await request.send();
      final http.Response response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return <String, dynamic>{'success': true, 'data': data['data']};
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error actualizando categoría'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Eliminar categoría
  Future<Map<String, dynamic>> deleteCategory(String id) async {
    try {
      final http.Response response = await http.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return <String, dynamic>{'success': true};
      } else {
        final data = jsonDecode(response.body);
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error eliminando categoría'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
