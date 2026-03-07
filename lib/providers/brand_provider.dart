import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Provider HTTP para la gestión de marcas (brands).
/// Solo utilizado por superadmin.
class BrandProvider {
  static String get baseUrl => ApiConfig.baseUrl;
  final String token;

  BrandProvider(this.token);

  Map<String, String> get _headers => <String, String>{
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, String> get _authHeaders => <String, String>{
    'Authorization': 'Bearer $token',
  };

  /// GET /api/brands — Lista de marcas (superadmin ve todas, admin solo la suya)
  Future<Map<String, dynamic>> getBrands({int? page, int? limit}) async {
    try {
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/brands')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri, headers: _headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final brands = data['data']['brands'];
        if (brands is List) {
          return <String, dynamic>{
            'success': true,
            'data': brands,
            'pagination': data['pagination'],
          };
        }
        return <String, dynamic>{
          'success': false,
          'message': 'Formato de respuesta inválido',
        };
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error obteniendo marcas',
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// GET /api/brands/:id
  Future<Map<String, dynamic>> getBrandById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/brands/$id'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return <String, dynamic>{'success': true, 'data': data['data']['brand']};
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error obteniendo marca',
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// GET /api/brands/:id/stats
  Future<Map<String, dynamic>> getBrandStats(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/brands/$id/stats'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return <String, dynamic>{'success': true, 'data': data['data']};
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error obteniendo estadísticas',
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// POST /api/brands — Crear marca + admin (multipart con logo opcional)
  /// Body: { brand: {...}, admin: {...} }
  Future<Map<String, dynamic>> createBrand({
    required Map<String, dynamic> brandData,
    required Map<String, dynamic> adminData,
    File? logoFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/brands'),
      );
      request.headers.addAll(_authHeaders);

      // Enviar como campos JSON stringificados (el backend usa parseMultipartBrandData)
      request.fields['brand'] = jsonEncode(brandData);
      request.fields['admin'] = jsonEncode(adminData);

      if (logoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('logo', logoFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return <String, dynamic>{'success': true, 'data': data['data']};
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error creando marca',
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// PATCH /api/brands/:id — Actualizar marca
  Future<Map<String, dynamic>> updateBrand(
    String id,
    Map<String, dynamic> data, {
    File? logoFile,
  }) async {
    try {
      if (logoFile != null) {
        // Multipart cuando hay imagen
        final request = http.MultipartRequest(
          'PATCH',
          Uri.parse('$baseUrl/brands/$id'),
        );
        request.headers.addAll(_authHeaders);

        data.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value is Map || value is List
                ? jsonEncode(value)
                : value.toString();
          }
        });

        request.files.add(
          await http.MultipartFile.fromPath('logo', logoFile.path),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return <String, dynamic>{'success': true, 'data': responseData['data']};
        } else {
          return <String, dynamic>{
            'success': false,
            'message': responseData['message'] ?? 'Error actualizando marca',
          };
        }
      } else {
        // JSON simple sin imagen
        final response = await http.patch(
          Uri.parse('$baseUrl/brands/$id'),
          headers: _headers,
          body: jsonEncode(data),
        );
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return <String, dynamic>{'success': true, 'data': responseData['data']};
        } else {
          return <String, dynamic>{
            'success': false,
            'message': responseData['message'] ?? 'Error actualizando marca',
          };
        }
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// DELETE /api/brands/:id — Desactivar marca (soft delete)
  Future<Map<String, dynamic>> deleteBrand(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/brands/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          return <String, dynamic>{
            'success': true,
            'message': data['message'] ?? 'Marca desactivada exitosamente',
          };
        }
        return <String, dynamic>{
          'success': true,
          'message': 'Marca desactivada exitosamente',
        };
      } else {
        final data = jsonDecode(response.body);
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error desactivando marca',
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
