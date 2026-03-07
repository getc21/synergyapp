import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SupplierProvider {
  static String get baseUrl => ApiConfig.baseUrl;
  final String token;

  SupplierProvider(this.token);

  Map<String, String> get _headers => <String, String>{
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, String> get _authHeaders => <String, String>{
    'Authorization': 'Bearer $token',
  };

  // Obtener todos los proveedores
  Future<Map<String, dynamic>> getSuppliers({String? storeId}) async {
    try {
      // ⭐ MULTI-TENANT: el backend filtra por brandId del JWT automáticamente
      final queryParams = <String, String>{};
      if (storeId != null) queryParams['storeId'] = storeId;
      
      final uri = Uri.parse('$baseUrl/suppliers').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final http.Response response = await http.get(
        uri,
        headers: _headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final suppliers = data['data']['suppliers'];
        if (suppliers is List) {
          return <String, dynamic>{'success': true, 'data': suppliers};
        } else {
          return <String, dynamic>{'success': false, 'message': 'Formato de respuesta inválido'};
        }
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error obteniendo proveedores'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener proveedor por ID
  Future<Map<String, dynamic>> getSupplierById(String id) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$baseUrl/suppliers/$id'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return <String, dynamic>{'success': true, 'data': data['data']['supplier']};
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error obteniendo proveedor'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Crear proveedor
  Future<Map<String, dynamic>> createSupplier({
    required String name,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? address,
    File? imageFile,
    String? brandId, // ⭐ MULTI-TENANT
  }) async {
    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/suppliers'),
      );

      request.headers.addAll(_authHeaders);
      request.fields['name'] = name;
      if (contactName != null) request.fields['contactName'] = contactName;
      if (contactEmail != null) request.fields['contactEmail'] = contactEmail;
      if (contactPhone != null) request.fields['contactPhone'] = contactPhone;
      if (address != null) request.fields['address'] = address;
      // ⭐ MULTI-TENANT: enviar brandId al crear
      if (brandId != null) request.fields['brandId'] = brandId;

      if (imageFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('foto', imageFile.path));
      }

      final http.StreamedResponse streamedResponse = await request.send();
      final http.Response response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return <String, dynamic>{'success': true, 'data': data['data']};
      } else {
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error creando proveedor'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar proveedor
  Future<Map<String, dynamic>> updateSupplier({
    required String id,
    String? name,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? address,
    File? imageFile,
  }) async {
    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/suppliers/$id'),
      );

      request.headers.addAll(_authHeaders);
      if (name != null) request.fields['name'] = name;
      if (contactName != null) request.fields['contactName'] = contactName;
      if (contactEmail != null) request.fields['contactEmail'] = contactEmail;
      if (contactPhone != null) request.fields['contactPhone'] = contactPhone;
      if (address != null) request.fields['address'] = address;

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
          'message': data['message'] ?? 'Error actualizando proveedor'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Eliminar proveedor
  Future<Map<String, dynamic>> deleteSupplier(String id) async {
    try {
      final http.Response response = await http.delete(
        Uri.parse('$baseUrl/suppliers/$id'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return <String, dynamic>{'success': true};
      } else {
        final data = jsonDecode(response.body);
        return <String, dynamic>{
          'success': false,
          'message': data['message'] ?? 'Error eliminando proveedor'
        };
      }
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
