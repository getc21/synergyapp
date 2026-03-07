import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../providers/brand_provider.dart';
import 'auth_controller.dart';

/// Controller GetX para gestión de marcas (brands).
/// Solo usado por superadmin para CRUD de marcas.
class BrandController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  BrandProvider get _brandProvider => BrandProvider(_authController.token);

  // Estados observables
  final RxList<Map<String, dynamic>> _brands = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> _filteredBrands = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> _brandStats = Rx<Map<String, dynamic>?>(null);

  // Getters
  List<Map<String, dynamic>> get brands => _brands;
  List<Map<String, dynamic>> get filteredBrands =>
      _searchQuery.value.isEmpty ? _brands : _filteredBrands;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  Map<String, dynamic>? get brandStats => _brandStats.value;

  @override
  void onInit() {
    super.onInit();
    if (_authController.isSuperAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => loadBrands());
    }
    ever(_searchQuery, (_) => _filterBrands());
  }

  // Filtrar marcas por búsqueda
  void _filterBrands() {
    if (_searchQuery.value.isEmpty) {
      _filteredBrands.value = _brands;
      return;
    }
    final query = _searchQuery.value.toLowerCase();
    _filteredBrands.value = _brands.where((brand) {
      final name = (brand['name'] ?? '').toString().toLowerCase();
      final slug = (brand['slug'] ?? '').toString().toLowerCase();
      final email = (brand['contactEmail'] ?? '').toString().toLowerCase();
      return name.contains(query) ||
          slug.contains(query) ||
          email.contains(query);
    }).toList();
  }

  void searchBrands(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  /// Cargar todas las marcas
  Future<void> loadBrands() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final result = await _brandProvider.getBrands();

      if (result['success']) {
        _brands.value = List<Map<String, dynamic>>.from(result['data']);
        _filterBrands();
      } else {
        _errorMessage.value = result['message'] ?? 'Error cargando marcas';
        Get.snackbar(
          'Error',
          _errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _errorMessage.value = 'Error de conexión: $e';
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Cargar estadísticas de una marca
  Future<void> loadBrandStats(String brandId) async {
    try {
      final result = await _brandProvider.getBrandStats(brandId);
      if (result['success']) {
        _brandStats.value = result['data'];
      }
    } catch (_) {
      // Error silencioso en stats
    }
  }

  /// Crear marca + admin
  Future<bool> createBrand({
    required Map<String, dynamic> brandData,
    required Map<String, dynamic> adminData,
    File? logoFile,
  }) async {
    _isLoading.value = true;

    try {
      final result = await _brandProvider.createBrand(
        brandData: brandData,
        adminData: adminData,
        logoFile: logoFile,
      );

      if (result['success']) {
        Get.snackbar(
          'Éxito',
          'Marca creada correctamente',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadBrands();
        return true;
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Error creando marca',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error de conexión: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Actualizar marca existente
  Future<bool> updateBrand({
    required String id,
    required Map<String, dynamic> data,
    File? logoFile,
  }) async {
    _isLoading.value = true;

    try {
      final result = await _brandProvider.updateBrand(id, data, logoFile: logoFile);

      if (result['success']) {
        Get.snackbar(
          'Éxito',
          'Marca actualizada correctamente',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadBrands();
        return true;
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Error actualizando marca',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error de conexión: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Desactivar (soft delete) una marca
  Future<bool> deleteBrand(String id) async {
    _isLoading.value = true;

    try {
      final result = await _brandProvider.deleteBrand(id);

      if (result['success']) {
        Get.snackbar(
          'Éxito',
          result['message'] ?? 'Marca desactivada correctamente',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _brands.removeWhere((b) => b['_id'] == id);
        _filterBrands();
        return true;
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Error desactivando marca',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error de conexión: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refrescar lista
  Future<void> refreshBrands() async {
    await loadBrands();
  }

  void clearError() {
    _errorMessage.value = '';
  }
}
